import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_link/models/review_model.dart';
import 'package:service_link/util/logger.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get provider name
  Future<String> getProviderName() async {
    try {
      if (currentUserId == null) return 'User';

      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (userDoc.exists) {
        return userDoc.get('fullName') ?? 'User';
      }
      return 'User';
    } catch (e, stackTrace) {
      AppLogger.error('Error getting provider name', e, stackTrace);
      return 'User';
    }
  }

  // Get total earnings
  Future<double> getTotalEarnings() async {
    try {
      if (currentUserId == null) return 0.0;

      // Get all completed bookings for this provider
      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('providerId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'completed')
          .get();

      double totalEarnings = 0.0;
      for (var doc in bookingsSnapshot.docs) {
        totalEarnings += (doc.data()['totalPrice'] ?? 0.0).toDouble();
      }

      return totalEarnings;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting total earnings', e, stackTrace);
      return 0.0;
    }
  }

  // Get total services count
  Future<int> getTotalServicesCount() async {
    try {
      if (currentUserId == null) return 0;

      // Count all services for this provider
      final servicesSnapshot = await _firestore
          .collection('services')
          .where('providerId', isEqualTo: currentUserId)
          .count()
          .get();

      return servicesSnapshot.count ?? 0;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting total services count', e, stackTrace);
      return 0;
    }
  }

  // Get upcoming services count
  Future<int> getUpcomingServicesCount() async {
    try {
      if (currentUserId == null) return 0;

      // Get current date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayTimestamp = Timestamp.fromDate(today);

      // Split the query to work with existing indexes
      // First, get all bookings for this provider
      final query = _firestore
          .collection('bookings')
          .where('providerId', isEqualTo: currentUserId);
          
      // Then manually filter the results
      final bookingsSnapshot = await query.get();
      
      // Count bookings that match our criteria
      int count = 0;
      for (var doc in bookingsSnapshot.docs) {
        final status = doc.data()['status'] as String?;
        final scheduledDate = doc.data()['scheduledDate'] as Timestamp?;
        
        if (scheduledDate != null && 
            scheduledDate.compareTo(todayTimestamp) >= 0 &&
            (status == 'pending' || status == 'confirmed')) {
          count++;
        }
      }

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting upcoming services count', e, stackTrace);
      return 0;
    }
  }

  // Get today's services count
  Future<int> getTodayServicesCount() async {
    try {
      if (currentUserId == null) return 0;

      // Get current date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayTimestamp = Timestamp.fromDate(today);
      final tomorrowTimestamp = Timestamp.fromDate(today.add(const Duration(days: 1)));

      // Using the existing index: providerId Ascending, createdAt Descending
      // First, get all bookings for this provider
      final query = _firestore
          .collection('bookings')
          .where('providerId', isEqualTo: currentUserId);
          
      // Then manually filter the results
      final bookingsSnapshot = await query.get();
      
      // Count bookings that match our criteria
      int count = 0;
      for (var doc in bookingsSnapshot.docs) {
        final scheduledDate = doc.data()['scheduledDate'] as Timestamp?;
        
        if (scheduledDate != null && 
            scheduledDate.compareTo(todayTimestamp) >= 0 &&
            scheduledDate.compareTo(tomorrowTimestamp) < 0) {
          count++;
        }
      }

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting today\'s services count', e, stackTrace);
      return 0;
    }
  }

  // Get recent reviews
  Future<List<ReviewModel>> getRecentReviews({int limit = 4}) async {
    try {
      if (currentUserId == null) return [];

      // Based on the existing index: clientId Ascending, createdAt Descending
      // We need to modify our approach since we don't have a providerId+createdAt index
      
      // First, get all reviews for this provider without ordering
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('providerId', isEqualTo: currentUserId)
          .get();

      // Convert to ReviewModel objects
      List<ReviewModel> reviews = reviewsSnapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
          
      // Sort manually by createdAt
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Limit to requested number
      if (reviews.length > limit) {
        reviews = reviews.sublist(0, limit);
      }

      return reviews;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting recent reviews', e, stackTrace);
      return [];
    }
  }

  // Get user data by ID
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting user data', e, stackTrace);
      return null;
    }
  }
}
