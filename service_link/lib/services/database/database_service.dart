import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Get a collection reference
  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  // Get a document reference
  DocumentReference document(String path) {
    return _firestore.doc(path);
  }

  // Add a document to a collection
  Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
    return await _firestore.collection(collection).add(data);
  }

  // Set a document with a specific ID
  Future<void> setDocument(String collection, String documentId, Map<String, dynamic> data, {bool merge = false}) async {
    return await _firestore.collection(collection).doc(documentId).set(data, SetOptions(merge: merge));
  }

  // Update a document
  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data) async {
    return await _firestore.collection(collection).doc(documentId).update(data);
  }

  // Delete a document
  Future<void> deleteDocument(String collection, String documentId) async {
    return await _firestore.collection(collection).doc(documentId).delete();
  }

  // Get a document
  Future<DocumentSnapshot> getDocument(String collection, String documentId) async {
    return await _firestore.collection(collection).doc(documentId).get();
  }

  // Get a collection
  Stream<QuerySnapshot> getCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }

  // Get a filtered collection
  Stream<QuerySnapshot> getFilteredCollection(
    String collectionPath, {
    required String field,
    required dynamic isEqualTo,
  }) {
    return _firestore
        .collection(collectionPath)
        .where(field, isEqualTo: isEqualTo)
        .snapshots();
  }

  // Get a collection with ordering
  Stream<QuerySnapshot> getOrderedCollection(
    String collectionPath, {
    required String orderBy,
    bool descending = false,
  }) {
    return _firestore
        .collection(collectionPath)
        .orderBy(orderBy, descending: descending)
        .snapshots();
  }

  // Get a filtered and ordered collection
  Stream<QuerySnapshot> getFilteredOrderedCollection(
    String collectionPath, {
    required String field,
    required dynamic isEqualTo,
    required String orderBy,
    bool descending = false,
  }) {
    return _firestore
        .collection(collectionPath)
        .where(field, isEqualTo: isEqualTo)
        .orderBy(orderBy, descending: descending)
        .snapshots();
  }

  // Run a transaction
  Future<T> runTransaction<T>(Future<T> Function(Transaction) transactionHandler) {
    return _firestore.runTransaction(transactionHandler);
  }

  // Run a batch write
  Future<void> runBatchWrite(Function(WriteBatch) batchHandler) async {
    final batch = _firestore.batch();
    batchHandler(batch);
    return batch.commit();
  }
}
