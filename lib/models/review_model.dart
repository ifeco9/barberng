import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String barberId;
  final String customerId;
  final String appointmentId;
  final String? serviceId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.barberId,
    required this.customerId,
    required this.appointmentId,
    this.serviceId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'barberId': barberId,
      'customerId': customerId,
      'appointmentId': appointmentId,
      'serviceId': serviceId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      barberId: map['barberId'] ?? '',
      customerId: map['customerId'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      serviceId: map['serviceId'],
      rating: map['rating']?.toInt() ?? 0,
      comment: map['comment'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  ReviewModel copyWith({
    String? id,
    String? barberId,
    String? customerId,
    String? appointmentId,
    String? serviceId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      barberId: barberId ?? this.barberId,
      customerId: customerId ?? this.customerId,
      appointmentId: appointmentId ?? this.appointmentId,
      serviceId: serviceId ?? this.serviceId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}