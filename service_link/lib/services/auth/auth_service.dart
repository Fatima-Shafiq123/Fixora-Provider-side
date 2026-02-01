import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_link/models/user_model.dart';
import 'package:service_link/util/logger.dart';

class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? userData;

  AuthResult(this.success, this.message, {this.userData});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<AuthResult> signInWithEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      final userData = await _firestore
          .collection('providers')
          .doc(userCredential.user!.uid)
          .get();

      if (userData.exists) {
        return AuthResult(
          true,
          'Login successful',
          userData: userData.data(),
        );
      } else {
        return AuthResult(true, 'Login successful');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return AuthResult(false, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        return AuthResult(false, 'Wrong password provided for that user.');
      } else {
        return AuthResult(false, 'Error: ${e.message}');
      }
    } catch (e) {
      return AuthResult(false, 'Error: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('providers').doc(userId).get();

      if (docSnapshot.exists) {
        return UserModel.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting user data', e, stackTrace);
      return null;
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    final userId = currentUserId;
    if (userId == null) return null;

    return await getUserData(userId);
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(true, 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult(false, 'Error: ${e.message}');
    } catch (e) {
      return AuthResult(false, 'Error: $e');
    }
  }
}
