import 'package:flutter/foundation.dart';

/// Production-ready logging utility
/// Replaces print() statements with proper logging
class AppLogger {
  static const bool _enableDebugLogs = false; // Set to false in production

  /// Log debug messages (only in debug mode)
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enableDebugLogs) {
      _log('DEBUG', message, error, stackTrace);
    }
  }

  /// Log info messages
  static void info(String message) {
    _log('INFO', message);
  }

  /// Log warning messages
  static void warning(String message, [Object? error]) {
    _log('WARNING', message, error);
  }

  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  /// Internal logging method
  static void _log(
    String level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message';
    
    // In production, send to crash reporting service
    // For now, only log in debug mode
    if (_enableDebugLogs) {
      debugPrint(logMessage);
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }
}

