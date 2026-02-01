import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_link/util/AppRoute.dart';

enum DocumentType {
  cnicFront,
  cnicBack,
  profilePhoto,
  affidavit,
  guarantee,
  academicCertificate,
  otherCertificate,
}

class UploadResult {
  final bool success;
  final String message;

  UploadResult({required this.success, required this.message});
}

class DocumentUploadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery or camera
  Future<XFile?> pickImage({required ImageSource source}) async {
    try {
      return await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
    } catch (e) {
      return null;
    }
  }

  /// Upload document (stores as Base64 in Firestore for web/mobile)
  Future<UploadResult> uploadDocument({
    required XFile file,
    required DocumentType documentType,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return UploadResult(success: false, message: 'User not logged in');
    }

    try {
      String base64Image;

      if (kIsWeb) {
        // For web: read bytes directly
        final bytes = await file.readAsBytes();
        base64Image = base64Encode(bytes);
      } else {
        // For mobile: read file from path
        final bytes = await File(file.path).readAsBytes();
        base64Image = base64Encode(bytes);
      }

      // Save document info in Firestore
      await _firestore
          .collection('providers')
          .doc(user.uid)
          .collection('documents')
          .doc(documentType.name)
          .set({
        'fileBase64': base64Image,
        'fileName': file.name,
        'uploadedAt': FieldValue.serverTimestamp(),
        'status': 'uploaded',
      });

      return UploadResult(
          success: true, message: 'Document uploaded successfully');
    } catch (e) {
      return UploadResult(success: false, message: 'Upload failed: $e');
    }
  }

  /// Get all uploaded documents for the logged-in user
  Future<Map<DocumentType, Map<String, dynamic>>> getUploadedDocuments() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final Map<DocumentType, Map<String, dynamic>> docMap = {};
    final snapshot = await _firestore
        .collection('providers')
        .doc(user.uid)
        .collection('documents')
        .get();

    for (var doc in snapshot.docs) {
      final type = DocumentType.values.firstWhere((e) => e.name == doc.id);
      docMap[type] = doc.data();
    }
    return docMap;
  }

  /// Submit documents for review
  Future<bool> submitDocumentsForReview() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.collection('providers').doc(user.uid).update({
        'document_submission_status': 'pending_review',
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
