import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String? serviceId;
  final String providerId;
  final String title;
  final String description;
  final String category;
  final double price;
  final String priceType; // 'hourly' or 'fixed'
  final List<String> images;
  final String? location;
  final bool isAvailable;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final double rating;
  final int totalReviews;

  ServiceModel({
    this.serviceId,
    required this.providerId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.priceType,
    required this.images,
    this.location,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.rating = 0.0,
    this.totalReviews = 0,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceModel(
      serviceId: id,
      providerId: map['providerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      priceType: map['priceType'] ?? 'hourly',
      images: List<String>.from(map['images'] ?? []),
      location: map['location'],
      isAvailable: map['isAvailable'] ?? true,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      rating: (map['rating'] ?? 0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
    );
  }

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ServiceModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'priceType': priceType,
      'images': images,
      'location': location,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'rating': rating,
      'totalReviews': totalReviews,
    };
  }

  ServiceModel copyWith({
    String? serviceId,
    String? providerId,
    String? title,
    String? description,
    String? category,
    double? price,
    String? priceType,
    List<String>? images,
    String? location,
    bool? isAvailable,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    double? rating,
    int? totalReviews,
  }) {
    return ServiceModel(
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      images: images ?? this.images,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }
}
