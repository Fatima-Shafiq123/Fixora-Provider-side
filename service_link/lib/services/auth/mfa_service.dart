/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:service_link/util/logger.dart';
import 'package:totp/totp.dart';
import 'dart:math';
import 'package:base32/base32.dart';
import 'package:totp/totp.dart';
import 'package:totp/secret.dart';

class MfaService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if MFA is enabled for the current user
  Future<bool> isMfaEnabled() async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final doc = await _firestore
          .collection('providers')
          .doc(userId)
          .collection('security')
          .doc('mfa')
          .get();

      return doc.exists && (doc.data()?['enabled'] == true);
    } catch (e, stackTrace) {
      AppLogger.error('Error checking MFA status', e, stackTrace);
      return false;
    }
  }

  /// Generate a Base32 TOTP secret
  Future<String> generateSecret() async {
    final random = Random.secure();
    final secretBytes = List<int>.generate(20, (_) => random.nextInt(256));
    return base32.encode(secretBytes);
  }

  /// Generate otpauth URL for Google Authenticator
  String generateTotpUri(String secret, String issuer, String accountName) {
    return 'otpauth://totp/$issuer:$accountName?secret=$secret&issuer=$issuer&algorithm=SHA1&digits=6&period=30';
  }

  /// Verify the 6-digit TOTP code
  Future<bool> verifyCode(String secret, String code) async {
    if (code.length != 6) return false;

    try {
      final totp = Totp(
        Secret.fromBase32(secret),
        digits: 6,
        step: 30,
        algorithm: Algorithm.sha1,
      );

      return totp.verify(code);
    } catch (e, stackTrace) {
      AppLogger.error('Error verifying TOTP code', e, stackTrace);
      return false;
    }
  }

  /// Enable MFA for the current user
  Future<void> enableMfa(String secret) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('providers')
          .doc(userId)
          .collection('security')
          .doc('mfa')
          .set({
        'enabled': true,
        'secret': secret, // Should be encrypted in production
        'enabledAt': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mfa_enabled', true);
    } catch (e, stackTrace) {
      AppLogger.error('Error enabling MFA', e, stackTrace);
      rethrow;
    }
  }

  /// Disable MFA for the current user
  Future<void> disableMfa() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('providers')
          .doc(userId)
          .collection('security')
          .doc('mfa')
          .update({
        'enabled': false,
        'disabledAt': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mfa_enabled', false);
    } catch (e, stackTrace) {
      AppLogger.error('Error disabling MFA', e, stackTrace);
      rethrow;
    }
  }

  /// Require MFA before performing sensitive actions
  Future<bool> requireMfaVerification(String code) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final isEnabled = await isMfaEnabled();
      if (!isEnabled) return true; // No MFA → allow action

      final doc = await _firestore
          .collection('providers')
          .doc(userId)
          .collection('security')
          .doc('mfa')
          .get();

      if (!doc.exists) return true;

      final secret = doc.data()?['secret'] as String?;
      if (secret == null) return false;

      return await verifyCode(secret, code);
    } catch (e, stackTrace) {
      AppLogger.error('Error verifying MFA', e, stackTrace);
      return false;
    }
  }
}
*/
