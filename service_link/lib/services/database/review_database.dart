import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_link/models/review_model.dart';
import 'package:service_link/services/database/database_service.dart';

class ReviewDatabase extends DatabaseService {
  final String _collection = 'reviews';

  // Add a new review
  Future<DocumentReference> addReview(ReviewModel review) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    final data = review.toMap();
    // Add server timestamp for created
    data['createdAt'] = FieldValue.serverTimestamp();

    // Create the review document
    final reviewRef = await addDocument(_collection, data);

    // Update service rating and review count
    await _updateServiceRating(review.serviceId);
    
    // Update provider rating and review count
    await _updateProviderRating(review.providerId);

    return reviewRef;
  }

  // Get reviews for a specific service
  Stream<List<ReviewModel>> getServiceReviews(String serviceId) {
    return getFilteredOrderedCollection(
      _collection,
      field: 'serviceId',
      isEqualTo: serviceId,
      orderBy: 'createdAt',
      descending: true,
    ).map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get reviews for a specific provider
  Stream<List<ReviewModel>> getProviderReviews(String providerId) {
    // Using only the filter without ordering to avoid requiring a composite index
    return getFilteredCollection(
      _collection,
      field: 'providerId',
      isEqualTo: providerId,
    ).map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
      
      // Sort the reviews by createdAt on the client side
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  // Get reviews by current provider
  Stream<List<ReviewModel>> getCurrentProviderReviews() {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    return getProviderReviews(currentUserId!);
  }

  // Get reviews by current client
  Stream<List<ReviewModel>> getClientReviews() {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    return getFilteredOrderedCollection(
      _collection,
      field: 'clientId',
      isEqualTo: currentUserId,
      orderBy: 'createdAt',
      descending: true,
    ).map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    });
  }

  // Update service rating and review count
  Future<void> _updateServiceRating(String serviceId) async {
    // Get all reviews for this service
    final reviewsSnapshot = await collection(_collection)
        .where('serviceId', isEqualTo: serviceId)
        .get();

    if (reviewsSnapshot.docs.isEmpty) return;

    // Calculate average rating
    double totalRating = 0;
    for (var doc in reviewsSnapshot.docs) {
      totalRating += (doc.data() as Map<String, dynamic>)['rating'] as double;
    }
    final avgRating = totalRating / reviewsSnapshot.docs.length;

    // Update service document
    await updateDocument('services', serviceId, {
      'rating': avgRating,
      'totalReviews': reviewsSnapshot.docs.length,
    });
  }

  // Update provider rating and review count
  Future<void> _updateProviderRating(String providerId) async {
    // Get all reviews for this provider
    final reviewsSnapshot = await collection(_collection)
        .where('providerId', isEqualTo: providerId)
        .get();

    if (reviewsSnapshot.docs.isEmpty) return;

    // Calculate average rating
    double totalRating = 0;
    for (var doc in reviewsSnapshot.docs) {
      totalRating += (doc.data() as Map<String, dynamic>)['rating'] as double;
    }
    final avgRating = totalRating / reviewsSnapshot.docs.length;

    // Update provider document
    await updateDocument('users', providerId, {
      'rating': avgRating,
      'totalReviews': reviewsSnapshot.docs.length,
    });
  }
}
