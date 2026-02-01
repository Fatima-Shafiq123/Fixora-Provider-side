import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

enum PaymentStatus {
  pending,
  completed,
}

class BookingModel {
  final String? bookingId;
  final String serviceId;
  final String providerId;
  final String clientId;
  final BookingStatus status;
  final Timestamp scheduledDate;
  final String scheduledTime;
  final int duration; // in hours
  final double totalPrice;
  final String clientAddress;
  final String? clientNotes;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final PaymentStatus paymentStatus;
  final String? paymentMethod;

  BookingModel({
    this.bookingId,
    required this.serviceId,
    required this.providerId,
    required this.clientId,
    this.status = BookingStatus.pending,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.duration,
    required this.totalPrice,
    required this.clientAddress,
    this.clientNotes,
    required this.createdAt,
    required this.updatedAt,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      bookingId: id,
      serviceId: map['serviceId'] ?? '',
      providerId: map['providerId'] ?? '',
      clientId: map['clientId'] ?? '',
      status: _getBookingStatus(map['status']),
      scheduledDate: map['scheduledDate'] ?? Timestamp.now(),
      scheduledTime: map['scheduledTime'] ?? '',
      duration: map['duration'] ?? 1,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      clientAddress: map['clientAddress'] ?? '',
      clientNotes: map['clientNotes'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      paymentStatus: _getPaymentStatus(map['paymentStatus']),
      paymentMethod: map['paymentMethod'],
    );
  }

  static BookingStatus _getBookingStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }

  static PaymentStatus _getPaymentStatus(String? status) {
    return status == 'completed' ? PaymentStatus.completed : PaymentStatus.pending;
  }

  static String bookingStatusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.pending:
        return 'pending';
    }
  }

  static String paymentStatusToString(PaymentStatus status) {
    return status == PaymentStatus.completed ? 'completed' : 'pending';
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BookingModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'providerId': providerId,
      'clientId': clientId,
      'status': bookingStatusToString(status),
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'duration': duration,
      'totalPrice': totalPrice,
      'clientAddress': clientAddress,
      'clientNotes': clientNotes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'paymentStatus': paymentStatusToString(paymentStatus),
      'paymentMethod': paymentMethod,
    };
  }
}
