import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Security utilities for secure storage, rate limiting, and input validation
class SecurityUtils {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Rate limiting keys
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _loginAttemptsTimestampKey = 'login_attempts_timestamp';
  static const int _maxLoginAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);

  /// Store sensitive data securely
  static Future<void> storeSecureData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      if (kDebugMode) print('Error storing secure data: $e');
      rethrow;
    }
  }

  /// Retrieve sensitive data securely
  static Future<String?> getSecureData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      if (kDebugMode) print('Error retrieving secure data: $e');
      return null;
    }
  }

  /// Delete sensitive data
  static Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      if (kDebugMode) print('Error deleting secure data: $e');
    }
  }

  /// Check login rate limit
  static Future<bool> checkLoginRateLimit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attempts = prefs.getInt(_loginAttemptsKey) ?? 0;
      final timestamp = prefs.getInt(_loginAttemptsTimestampKey) ?? 0;

      if (timestamp > 0) {
        final lockoutTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(lockoutTime) > _lockoutDuration) {
          await prefs.remove(_loginAttemptsKey);
          await prefs.remove(_loginAttemptsTimestampKey);
          return true;
        }
      }

      return attempts < _maxLoginAttempts;
    } catch (e) {
      if (kDebugMode) print('Error checking rate limit: $e');
      return true;
    }
  }

  /// Record failed login
  static Future<void> recordFailedLoginAttempt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attempts = (prefs.getInt(_loginAttemptsKey) ?? 0) + 1;
      await prefs.setInt(_loginAttemptsKey, attempts);

      if (attempts >= _maxLoginAttempts) {
        await prefs.setInt(
          _loginAttemptsTimestampKey,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Error recording failed login attempt: $e');
    }
  }

  /// Reset login attempts
  static Future<void> resetLoginAttempts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_loginAttemptsKey);
      await prefs.remove(_loginAttemptsTimestampKey);
    } catch (e) {
      if (kDebugMode) print('Error resetting login attempts: $e');
    }
  }

  /// Get remaining attempts
  static Future<int> getRemainingLoginAttempts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attempts = prefs.getInt(_loginAttemptsKey) ?? 0;
      return _maxLoginAttempts - attempts;
    } catch (e) {
      return _maxLoginAttempts;
    }
  }

  /// Check if account is locked
  static Future<bool> isAccountLocked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attempts = prefs.getInt(_loginAttemptsKey) ?? 0;
      final timestamp = prefs.getInt(_loginAttemptsTimestampKey) ?? 0;

      if (attempts >= _maxLoginAttempts && timestamp > 0) {
        final lockoutTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return DateTime.now().difference(lockoutTime) < _lockoutDuration;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get lockout remaining time
  static Future<Duration?> getLockoutRemainingTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_loginAttemptsTimestampKey) ?? 0;

      if (timestamp > 0) {
        final lockoutTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final remaining =
            _lockoutDuration - DateTime.now().difference(lockoutTime);
        return remaining.isNegative ? null : remaining;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Generate secure random token
  static String generateSecureToken({int length = 32}) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (i) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Password strength checker
  static PasswordStrength validatePasswordStrength(String password) {
    if (password.length < 8) return PasswordStrength.weak;

    bool hasUpper = false,
        hasLower = false,
        hasDigit = false,
        hasSpecial = false;

    for (var char in password.runes) {
      if (char >= 65 && char <= 90) hasUpper = true;
      if (char >= 97 && char <= 122) hasLower = true;
      if (char >= 48 && char <= 57) hasDigit = true;
      if ((char >= 33 && char <= 47) ||
          (char >= 58 && char <= 64) ||
          (char >= 91 && char <= 96) ||
          (char >= 123 && char <= 126)) {
        hasSpecial = true;
      }
    }

    int strength =
        [hasUpper, hasLower, hasDigit, hasSpecial].where((b) => b).length;
    if (password.length >= 12) strength++;

    if (strength <= 2) return PasswordStrength.weak;
    if (strength <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// ✅ FIX: Sanitize input (this was missing)
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    const blacklist = '<>"\'`;'; // characters we want to remove
    var sanitized = input;
    for (final ch in blacklist.split('')) {
      sanitized = sanitized.replaceAll(ch, '');
    }
    return sanitized.trim();
  }

  /// Email validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Phone validation
  static bool isValidPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 && digits.length <= 15;
  }
}

enum PasswordStrength { weak, medium, strong }
