import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_link/models/booking_model.dart';
import 'package:service_link/services/database/database_service.dart';

class BookingDatabase extends DatabaseService {
  final String _collection = 'bookings';

  // Create a new booking
  Future<DocumentReference> createBooking(BookingModel booking) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    final data = booking.toMap();
    // Add server timestamps for created and updated
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    return await addDocument(_collection, data);
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    final data = {
      'status': BookingModel.bookingStatusToString(status),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    return await updateDocument(_collection, bookingId, data);
  }

  // Get a specific booking
  Future<BookingModel?> getBooking(String bookingId) async {
    final doc = await getDocument(_collection, bookingId);
    if (doc.exists) {
      return BookingModel.fromFirestore(doc);
    }
    return null;
  }

  // Get bookings for current provider
  Stream<List<BookingModel>> getProviderBookings({BookingStatus? status}) {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    Query query = collection(_collection).where('providerId', isEqualTo: currentUserId);

    if (status != null) {
      query = query.where('status', isEqualTo: BookingModel.bookingStatusToString(status));
    }

    return query
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get bookings for current client
  Stream<List<BookingModel>> getClientBookings({BookingStatus? status}) {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    Query query = collection(_collection).where('clientId', isEqualTo: currentUserId);

    if (status != null) {
      query = query.where('status', isEqualTo: BookingModel.bookingStatusToString(status));
    }

    return query
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get upcoming bookings for provider (scheduled for today or future)
  Stream<List<BookingModel>> getUpcomingProviderBookings() {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    final today = Timestamp.fromDate(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );

    return collection(_collection)
        .where('providerId', isEqualTo: currentUserId)
        .where('scheduledDate', isGreaterThanOrEqualTo: today)
        .where('status', whereIn: [
          BookingModel.bookingStatusToString(BookingStatus.pending),
          BookingModel.bookingStatusToString(BookingStatus.confirmed),
        ])
        .orderBy('scheduledDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get booking statistics for provider
  Future<Map<String, int>> getProviderBookingStats() async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    final stats = {
      'pending': 0,
      'confirmed': 0,
      'completed': 0,
      'cancelled': 0,
      'total': 0,
    };

    final snapshot = await collection(_collection)
        .where('providerId', isEqualTo: currentUserId)
        .get();

    for (var doc in snapshot.docs) {
      final status = doc.get('status') as String;
      stats[status] = (stats[status] ?? 0) + 1;
      stats['total'] = stats['total']! + 1;
    }

    return stats;
  }
}
