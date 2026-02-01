import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_link/services/auth/auth_service.dart';
import 'package:service_link/util/logger.dart';

class ProviderAuthService extends AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to validate CNIC with or without dash
  bool isValidCnic(String cnic) {
    return RegExp(r'^(\d{5}-\d{7}-\d{1}|\d{13})$').hasMatch(cnic);
  }

  /// Sign up a provider with email & password
  Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String userName,
    required String contactNumber,
    required String experience,
    required String serviceCategory,
    String? hourlyRate,
    String? cnic,
    List<String>? subcategories,
  }) async {
    try {
      // --- VALIDATION CHECKS ---
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        return AuthResult(false, 'Invalid email format.');
      }

      if (password.length < 6) {
        return AuthResult(false, 'Password must be at least 6 characters.');
      }

      if (!RegExp(r'^\d{11}$').hasMatch(contactNumber)) {
        return AuthResult(
            false, 'Contact number must contain exactly 11 digits.');
      }

      if (fullName.isEmpty || userName.isEmpty) {
        return AuthResult(false, 'Full name and username cannot be empty.');
      }

      if (cnic != null && !isValidCnic(cnic)) {
        return AuthResult(false,
            'CNIC must be 13 digits (1234512345671) or formatted with dashes (12345-1234567-1).');
      }

      // --- CREATE USER ---
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Prepare user data
      final userData = {
        'userId': userId,
        'fullName': fullName,
        'userName': userName,
        'contactNumber': contactNumber,
        'email': email,
        'experience': experience,
        'serviceCategory': serviceCategory,
        if (subcategories != null && subcategories.isNotEmpty) 'subcategories': subcategories,
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
        if (cnic != null) 'cnic': cnic,
        'userType': 'provider',
        'createdAt': FieldValue.serverTimestamp(),
        'rating': 0.0,
        'totalReviews': 0,
        'kycStatus': 'pending',
        'documentsUploaded': false,
      };

      // Save to Firestore
      await _firestore.collection('providers').doc(userId).set(userData);

      return AuthResult(true, 'Signup successful', userData: userData);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return AuthResult(false, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return AuthResult(false, 'The account already exists for that email.');
      } else {
        return AuthResult(false, 'FirebaseAuth Error: ${e.message}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('SignUp Error', e, stackTrace);
      return AuthResult(false, 'Error signing up. Please try again.');
    }
  }

  /// Update provider profile
  Future<AuthResult> updateProviderProfile({
    required String fullName,
    required String userName,
    required String contactNumber,
    required String experience,
    required String serviceCategory,
    String? hourlyRate,
    String? profileImage,
    String? cnic,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return AuthResult(false, 'User not authenticated');
      }

      // --- VALIDATION CHECKS ---
      if (fullName.isEmpty || userName.isEmpty) {
        return AuthResult(false, 'Full name and username cannot be empty.');
      }

      if (!RegExp(r'^\d{11}$').hasMatch(contactNumber)) {
        return AuthResult(
            false, 'Contact number must contain exactly 11 digits.');
      }

      if (cnic != null && !isValidCnic(cnic)) {
        return AuthResult(false,
            'CNIC must be 13 digits (1234512345671) or formatted with dashes (12345-1234567-1).');
      }

      // --- UPDATE DATA ---
      final updateData = {
        'fullName': fullName,
        'userName': userName,
        'contactNumber': contactNumber,
        'experience': experience,
        'serviceCategory': serviceCategory,
        'updatedAt': FieldValue.serverTimestamp(),
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
        if (profileImage != null) 'profileImage': profileImage,
        if (cnic != null) 'cnic': cnic,
      };

      // Update Firestore document
      await _firestore.collection('users').doc(userId).update(updateData);

      // Fetch latest data after update
      final updatedDoc = await _firestore.collection('users').doc(userId).get();

      return AuthResult(
        true,
        'Profile updated successfully',
        userData: updatedDoc.data(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Update Profile Error', e, stackTrace);
      return AuthResult(false, 'Error updating profile. Please try again.');
    }
  }
}
