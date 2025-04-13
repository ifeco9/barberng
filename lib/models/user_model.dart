import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final bool isServiceProvider;
  final String? profileImageUrl;
  final String? address;
  final List<String>? services;
  final double? rating;
  final int? totalReviews;
  final String? bio;
  final Map<String, Map<String, String>>? workingHours;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.isServiceProvider,
    this.profileImageUrl,
    this.address,
    this.services,
    this.rating,
    this.totalReviews,
    this.bio,
    this.workingHours,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      isServiceProvider: data['isServiceProvider'] ?? false,
      profileImageUrl: data['profileImageUrl'],
      address: data['address'],
      services: data['services'] != null ? List<String>.from(data['services']) : null,
      rating: data['rating']?.toDouble(),
      totalReviews: data['totalReviews'],
      bio: data['bio'],
      workingHours: data['workingHours'] != null 
          ? Map<String, Map<String, String>>.from(
              data['workingHours'].map((key, value) => MapEntry(
                key, 
                Map<String, String>.from(value)
              ))
            )
          : null,
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      isServiceProvider: data['isServiceProvider'] ?? false,
      profileImageUrl: data['profileImageUrl'],
      address: data['address'],
      services: data['services'] != null ? List<String>.from(data['services']) : null,
      rating: data['rating']?.toDouble(),
      totalReviews: data['totalReviews'],
      bio: data['bio'],
      workingHours: data['workingHours'] != null 
          ? Map<String, Map<String, String>>.from(
              data['workingHours'].map((key, value) => MapEntry(
                key, 
                Map<String, String>.from(value)
              ))
            )
          : null,
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] is Timestamp 
              ? (data['createdAt'] as Timestamp).toDate() 
              : DateTime.parse(data['createdAt'].toString()))
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] is Timestamp 
              ? (data['updatedAt'] as Timestamp).toDate() 
              : DateTime.parse(data['updatedAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'isServiceProvider': isServiceProvider,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'services': services,
      'rating': rating,
      'totalReviews': totalReviews,
      'bio': bio,
      'workingHours': workingHours,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    bool? isServiceProvider,
    String? profileImageUrl,
    String? address,
    List<String>? services,
    double? rating,
    int? totalReviews,
    String? bio,
    Map<String, Map<String, String>>? workingHours,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isServiceProvider: isServiceProvider ?? this.isServiceProvider,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      services: services ?? this.services,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      bio: bio ?? this.bio,
      workingHours: workingHours ?? this.workingHours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 