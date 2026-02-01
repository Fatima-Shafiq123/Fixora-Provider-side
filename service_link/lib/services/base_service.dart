import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_link/util/logger.dart';

/// Base service class to reduce code duplication
/// Provides common functionality for all services
abstract class BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Get Auth instance
  FirebaseAuth get auth => _auth;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get a collection reference
  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  /// Get a document reference
  DocumentReference document(String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId);
  }

  /// Get a document
  Future<DocumentSnapshot> getDocument(String collection, String documentId) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting document from $collection/$documentId', e, stackTrace);
      rethrow;
    }
  }

  /// Set a document
  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(documentId)
          .set(data, SetOptions(merge: merge));
    } catch (e, stackTrace) {
      AppLogger.error('Error setting document in $collection/$documentId', e, stackTrace);
      rethrow;
    }
  }

  /// Update a document
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e, stackTrace) {
      AppLogger.error('Error updating document in $collection/$documentId', e, stackTrace);
      rethrow;
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting document from $collection/$documentId', e, stackTrace);
      rethrow;
    }
  }

  /// Query a collection
  Future<QuerySnapshot> queryCollection(
    String collection, {
    String? whereField,
    dynamic whereValue,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      if (whereField != null && whereValue != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return await query.get();
    } catch (e, stackTrace) {
      AppLogger.error('Error querying collection $collection', e, stackTrace);
      rethrow;
    }
  }

  /// Validate user authentication
  void requireAuthentication() {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }
  }
}

