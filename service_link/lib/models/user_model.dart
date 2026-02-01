import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType {
  client,
  provider,
}

class UserModel {
  final String userId;
  final String fullName;
  final String userName;
  final String email;
  final String contactNumber;
  final UserType userType;
  final int createdAt;

  // Provider-specific fields
  final String? experience;
  final String? serviceCategory;
  final String? hourlyRate;
  final double? rating;
  final int? totalReviews;

  // Profile image
  final String? profileImage; // URL
  final String? profileImageBase64; // Base64 image

  UserModel({
    required this.userId,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.contactNumber,
    required this.userType,
    required this.createdAt,
    this.experience,
    this.serviceCategory,
    this.hourlyRate,
    this.rating,
    this.totalReviews,
    this.profileImage,
    this.profileImageBase64, // Add this
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      userType:
          map['userType'] == 'provider' ? UserType.provider : UserType.client,
      createdAt: map['createdAt'] ?? 0,
      experience: map['experience'],
      serviceCategory: map['serviceCategory'],
      hourlyRate: map['hourlyRate'],
      rating: map['rating']?.toDouble(),
      totalReviews: map['totalReviews'],
      profileImage: map['profileImage'],
      profileImageBase64: map['profileImageBase64'], // Add this
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'fullName': fullName,
      'userName': userName,
      'email': email,
      'userType': userType == UserType.provider ? 'provider' : 'client',
      'contactNumber': contactNumber,
      'createdAt': createdAt,
    };

    // Only add provider-specific fields if the user is a provider
    if (userType == UserType.provider) {
      if (experience != null) map['experience'] = experience!;
      if (serviceCategory != null) map['serviceCategory'] = serviceCategory!;
      if (hourlyRate != null) map['hourlyRate'] = hourlyRate!;
      map['rating'] = rating ?? 0.0;
      map['totalReviews'] = totalReviews ?? 0;
    }

    // Add profile images if available
    if (profileImage != null) map['profileImage'] = profileImage!;
    if (profileImageBase64 != null) {
      map['profileImageBase64'] = profileImageBase64!;
    }

    return map;
  }
}
