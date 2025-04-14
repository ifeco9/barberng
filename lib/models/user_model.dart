import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String fullName;
  final String email;
  final String? phoneNumber;
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
  final bool isApproved;

  UserModel({
    required this.uid,
    required String name,
    String? fullName,
    required this.email,
    this.phoneNumber,
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
    this.isApproved = false,
  }) : this.name = name,
        this.fullName = fullName ?? name;

  bool isValid() {
    // Basic validation for all users
    if (uid.isEmpty) {
      print('UserModel: Invalid uid');
      return false;
    }
    if (email.isEmpty) {
      print('UserModel: Invalid email');
      return false;
    }
    if (name.isEmpty) {
      print('UserModel: Invalid name');
      return false;
    }

    // Additional validation for service providers
    if (isServiceProvider) {
      if (address == null || address!.isEmpty) {
        print('UserModel: Service provider missing address');
        return false;
      }
      if (services == null || services!.isEmpty) {
        print('UserModel: Service provider missing services');
        return false;
      }
    }

    return true;
  }

  bool canAccessBarberFeatures() {
    return isServiceProvider && isApproved;
  }

  bool canAccessCustomerFeatures() {
    return !isServiceProvider;
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    if (!data.containsKey('isServiceProvider') ||
        data['isServiceProvider'] == null ||
        !(data['isServiceProvider'] is bool)) {
      throw Exception('Invalid user type data');
    }

    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
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
      isApproved: data['isApproved'] ?? false,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      // Validate critical fields
      if (!map.containsKey('uid') || map['uid'] == null) {
        print('UserModel: UID is missing or null in Firestore data');
        throw Exception('UID is missing or null in Firestore data');
      }
      if (!map.containsKey('email') || map['email'] == null) {
        print('UserModel: Email is missing or null in Firestore data');
        throw Exception('Email is missing or null in Firestore data');
      }
      if (!map.containsKey('isServiceProvider')) {
        print('UserModel: isServiceProvider is missing in Firestore data');
        throw Exception('isServiceProvider is missing in Firestore data');
      }
      if (!map.containsKey('name') && !map.containsKey('fullName')) {
        print('UserModel: Both name and fullName are missing in Firestore data');
        throw Exception('Both name and fullName are missing in Firestore data');
      }

      return UserModel(
        uid: map['uid'] as String,
        name: map['name'] as String? ??
            map['fullName'] as String? ?? 'Unknown',
        fullName: map['fullName'] as String? ??
            map['name'] as String? ?? 'Unknown',
        email: map['email'] as String,
        phoneNumber: map['phoneNumber'] as String?,
        isServiceProvider: map['isServiceProvider'] as bool,
        profileImageUrl: map['profileImageUrl'],
        address: map['address'],
        services: map['services'] != null ? List<String>.from(map['services']) : null,
        rating: map['rating']?.toDouble(),
        totalReviews: map['totalReviews'],
        bio: map['bio'],
        workingHours: map['workingHours'] != null
            ? Map<String, Map<String, String>>.from(
            map['workingHours'].map((key, value) => MapEntry(
                key,
                Map<String, String>.from(value)
            ))
        )
            : null,
        latitude: map['latitude']?.toDouble(),
        longitude: map['longitude']?.toDouble(),
        createdAt: map['createdAt'] != null
            ? (map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.parse(map['createdAt'].toString()))
            : DateTime.now(),
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] is Timestamp
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.parse(map['updatedAt'].toString()))
            : null,
        isApproved: map['isApproved'] ?? false,
      );
    } catch (e) {
      print('UserModel: Error creating UserModel from map: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'fullName': fullName,
      'email': email,
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
      'isApproved': isApproved,
    };
  }

  // Added to resolve toJson error
  Map<String, dynamic> toJson() {
    return toMap();
  }

  // Added to resolve fromJson error
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromMap(json);
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? fullName,
    String? email,
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
    bool? isApproved,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
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
      isApproved: isApproved ?? this.isApproved,
    );
  }
}