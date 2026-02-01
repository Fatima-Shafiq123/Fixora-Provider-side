import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_link/models/user_model.dart';
import 'package:service_link/services/database/database_service.dart';

class UserDatabase extends DatabaseService {
  final String _collection = 'providers';

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    final doc = await getDocument(_collection, userId);
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    if (!isAuthenticated) {
      return null;
    }
    return await getUser(currentUserId!);
  }

  // Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    // Only allow updating the current user's profile
    if (userId != currentUserId) {
      throw Exception('Not authorized to update this user profile');
    }

    // Add updated timestamp
    data['updatedAt'] = FieldValue.serverTimestamp();

    return await updateDocument(_collection, userId, data);
  }

  // Get all providers
  Stream<List<UserModel>> getAllProviders() {
    return getFilteredOrderedCollection(
      _collection,
      field: 'userType',
      isEqualTo: 'provider',
      orderBy: 'createdAt',
      descending: true,
    ).map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  // Get providers by category
  Stream<List<UserModel>> getProvidersByCategory(String category) {
    return collection(_collection)
        .where('userType', isEqualTo: 'provider')
        .where('serviceCategory', isEqualTo: category)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  // Search providers by name
  Future<List<UserModel>> searchProviders(String query) async {
    // Firestore doesn't support direct text search, so we'll fetch all providers
    // and filter them on the client side
    final snapshot = await collection(_collection)
        .where('userType', isEqualTo: 'provider')
        .get();

    final searchTerms = query.toLowerCase().split(' ');

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where((user) {
      final fullName = user.fullName.toLowerCase();
      final userName = user.userName.toLowerCase();

      // Check if any search term is contained in name or username
      return searchTerms
          .any((term) => fullName.contains(term) || userName.contains(term));
    }).toList();
  }

  // Get top rated providers
  Future<List<UserModel>> getTopRatedProviders({int limit = 10}) async {
    final snapshot = await collection(_collection)
        .where('userType', isEqualTo: 'provider')
        .orderBy('rating', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }
}
