import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String? reviewId;
  final String serviceId;
  final String providerId;
  final String clientId;
  final String? bookingId;
  final double rating;
  final String comment;
  final Timestamp createdAt;
  final List<String>? images;

  ReviewModel({
    this.reviewId,
    required this.serviceId,
    required this.providerId,
    required this.clientId,
    this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      reviewId: id,
      serviceId: map['serviceId'] ?? '',
      providerId: map['providerId'] ?? '',
      clientId: map['clientId'] ?? '',
      bookingId: map['bookingId'],
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      images: map['images'] != null ? List<String>.from(map['images']) : null,
    );
  }

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReviewModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'providerId': providerId,
      'clientId': clientId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'images': images,
    };
  }
}
