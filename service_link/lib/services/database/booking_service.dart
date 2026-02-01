import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_link/models/booking_model.dart';
import 'package:service_link/util/logger.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get all bookings for the current provider
  Future<List<BookingModel>> getProviderBookings({String? statusFilter}) async {
    try {
      if (currentUserId == null) return [];

      // Using a simple query with only providerId to avoid index issues
      final query = _firestore
          .collection('bookings')
          .where('providerId', isEqualTo: currentUserId);

      final snapshot = await query.get();
      
      // Filter and sort client-side
      var filteredDocs = snapshot.docs;
      
      // Apply status filter if provided
      if (statusFilter != null && statusFilter != 'All') {
        filteredDocs = filteredDocs.where((doc) {
          final status = doc.data()['status'] as String?;
          return status == statusFilter.toLowerCase();
        }).toList();
      }
      
      // Sort by scheduledDate descending
      filteredDocs.sort((a, b) {
        final aDate = a.data()['scheduledDate'] as Timestamp?;
        final bDate = b.data()['scheduledDate'] as Timestamp?;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate); // Descending order
      });
      
      return filteredDocs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting provider bookings', e, stackTrace);
      return [];
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': BookingModel.bookingStatusToString(status),
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error updating booking status', e, stackTrace);
      return false;
    }
  }

  // Get service details for a booking
  Future<Map<String, dynamic>?> getServiceDetails(String serviceId) async {
    try {
      final serviceDoc = await _firestore.collection('services').doc(serviceId).get();
      if (serviceDoc.exists) {
        return serviceDoc.data();
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting service details', e, stackTrace);
      return null;
    }
  }

  // Get client details for a booking
  Future<Map<String, dynamic>?> getClientDetails(String clientId) async {
    try {
      final clientDoc = await _firestore.collection('users').doc(clientId).get();
      if (clientDoc.exists) {
        return clientDoc.data();
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting client details', e, stackTrace);
      return null;
    }
  }

  // Format date for display
  String formatBookingDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final day = date.day.toString().padLeft(2, '0');
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = months[date.month - 1];
    final year = date.year;
    
    return '$day $month, $year';
  }
}
