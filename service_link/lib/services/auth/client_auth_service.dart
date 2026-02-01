import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_link/services/auth/auth_service.dart';

class ClientAuthService extends AuthService {
  // Sign up with email and password for client
  Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String userName,
    required String contactNumber,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user ID
      final userId = userCredential.user!.uid;

      // Create client user data
      final userData = {
        'userId': userId,
        'fullName': fullName,
        'userName': userName,
        'contactNumber': contactNumber,
        'email': email,
        'userType': 'client',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Save client data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set(userData);

      return AuthResult(true, 'Signup successful', userData: userData);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return AuthResult(false, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return AuthResult(false, 'The account already exists for that email.');
      } else {
        return AuthResult(false, 'Error: ${e.message}');
      }
    } catch (e) {
      return AuthResult(false, 'Error: $e');
    }
  }

  // Update client profile
  Future<AuthResult> updateClientProfile({
    required String fullName,
    required String userName,
    required String contactNumber,
    String? profileImage,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return AuthResult(false, 'User not authenticated');
      }

      final updateData = {
        'fullName': fullName,
        'userName': userName,
        'contactNumber': contactNumber,
        'profileImage': profileImage,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await FirebaseFirestore.instance.collection('users').doc(userId).update(updateData);

      return AuthResult(true, 'Profile updated successfully', userData: updateData);
    } catch (e) {
      return AuthResult(false, 'Error updating profile: $e');
    }
  }
}
