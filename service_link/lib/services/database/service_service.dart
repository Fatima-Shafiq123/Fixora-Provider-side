import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_link/models/service_model.dart';
import 'package:service_link/util/logger.dart';

class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get all services for the current provider
  Future<List<ServiceModel>> getProviderServices() async {
    try {
      if (currentUserId == null) {
        AppLogger.warning('Cannot fetch services: User ID is null');
        return [];
      }

      AppLogger.debug('Fetching services for provider: $currentUserId');
      
      // Using client-side filtering instead of complex queries to avoid index issues
      final snapshot = await _firestore
          .collection('services')
          .where('providerId', isEqualTo: currentUserId)
          .get();
          
      // Sort the results client-side
      snapshot.docs.sort((a, b) {
        final aTimestamp = a.data()['createdAt'] as Timestamp?;
        final bTimestamp = b.data()['createdAt'] as Timestamp?;
        if (aTimestamp == null || bTimestamp == null) return 0;
        return bTimestamp.compareTo(aTimestamp); // Descending order
      });
      
      AppLogger.debug('Firestore query returned ${snapshot.docs.length} documents');
      
      final services = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
          
      return services;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting provider services', e, stackTrace);
      return [];
    }
  }

  // Get a single service by ID
  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      final doc = await _firestore.collection('services').doc(serviceId).get();
      if (doc.exists) {
        return ServiceModel.fromFirestore(doc);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting service by ID', e, stackTrace);
      return null;
    }
  }

  // Add a new service
  Future<String?> addService(ServiceModel service) async {
    try {
      final docRef = await _firestore.collection('services').add(service.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      AppLogger.error('Error adding service', e, stackTrace);
      return null;
    }
  }

  // Update an existing service (full model)
  Future<bool> updateService(ServiceModel service) async {
    try {
      if (service.serviceId == null) return false;
      
      await _firestore
          .collection('services')
          .doc(service.serviceId)
          .update(service.toMap());
      
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error updating service', e, stackTrace);
      return false;
    }
  }

  // Update service with partial data (Map)
  Future<bool> updateServiceData(String serviceId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _firestore
          .collection('services')
          .doc(serviceId)
          .update(data);
      
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error updating service', e, stackTrace);
      return false;
    }
  }

  // Delete a service
  Future<bool> deleteService(String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).delete();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting service', e, stackTrace);
      return false;
    }
  }

  Future<bool> updateAvailability(String serviceId, bool isAvailable) async {
    try {
      await _firestore
          .collection('services')
          .doc(serviceId)
          .update({'isAvailable': isAvailable, 'updatedAt': Timestamp.now()});
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error updating availability', e, stackTrace);
      return false;
    }
  }

  // Get total bookings count for a service
  Future<int> getServiceBookingsCount(String serviceId) async {
    try {
      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('serviceId', isEqualTo: serviceId)
          .count()
          .get();
      
      return bookingsSnapshot.count ?? 0;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting service bookings count', e, stackTrace);
      return 0;
    }
  }

  // Get average rating for a service
  Future<double> getServiceAverageRating(String serviceId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('serviceId', isEqualTo: serviceId)
          .get();
      
      if (reviewsSnapshot.docs.isEmpty) return 0.0;
      
      double totalRating = 0.0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 0).toDouble();
      }
      
      return totalRating / reviewsSnapshot.docs.length;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting service average rating', e, stackTrace);
      return 0.0;
    }
  }
  
  // Get reviews for a specific service
  Future<List<Map<String, dynamic>>> getReviewsByServiceId(String serviceId) async {
    try {
      // Using client-side filtering instead of complex queries to avoid index issues
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('serviceId', isEqualTo: serviceId)
          .get();
          
      // Sort and limit the results client-side
      final sortedDocs = reviewsSnapshot.docs;
      sortedDocs.sort((a, b) {
        final aTimestamp = a.data()['createdAt'] as Timestamp?;
        final bTimestamp = b.data()['createdAt'] as Timestamp?;
        if (aTimestamp == null || bTimestamp == null) return 0;
        return bTimestamp.compareTo(aTimestamp); // Descending order
      });
      
      // Limit to 5 reviews
      final limitedDocs = sortedDocs.length > 5 ? sortedDocs.sublist(0, 5) : sortedDocs;
      
      List<Map<String, dynamic>> reviews = [];
      
      for (var doc in limitedDocs) {
        final reviewData = doc.data();
        final clientId = reviewData['clientId'] ?? '';
        
        // Get client data
        String clientName = 'Client';
        String clientImage = 'assets/profiles/profile1.png';
        bool isAssetImage = true;
        
        if (clientId.isNotEmpty) {
          final clientDoc = await _firestore.collection('users').doc(clientId).get();
          if (clientDoc.exists) {
            clientName = clientDoc.data()?['fullName'] ?? 'Client';
            // If client has a profile image, use it
            // clientImage = clientDoc.data()?['profileImage'] ?? clientImage;
            // isAssetImage = clientImage.startsWith('assets/');
          }
        }
        
        // Format date
        final createdAt = reviewData['createdAt'] as Timestamp?;
        String date = 'Recent';
        if (createdAt != null) {
          final dateTime = createdAt.toDate();
          date = '${dateTime.day} ${_getMonthName(dateTime.month)}';
        }
        
        reviews.add({
          'name': clientName,
          'date': date,
          'rating': (reviewData['rating'] ?? 0).toDouble(),
          'text': reviewData['comment'] ?? '',
          'imageUrl': clientImage,
          'isAssetImage': isAssetImage,
        });
      }
      
      return reviews;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting reviews for service', e, stackTrace);
      return [];
    }
  }
  
  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
