import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  noShow
}

class AppointmentModel {
  final String id;
  final String userId;
  final String barberId;
  final String serviceId;
  final DateTime date;
  final String status;
  final double price;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.barberId,
    required this.serviceId,
    required this.date,
    required this.status,
    required this.price,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      barberId: map['barberId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: map['status'] ?? AppointmentStatus.pending.toString(),
      price: (map['price'] ?? 0.0).toDouble(),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'barberId': barberId,
      'serviceId': serviceId,
      'date': Timestamp.fromDate(date),
      'status': status,
      'price': price,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? barberId,
    String? serviceId,
    DateTime? date,
    String? status,
    double? price,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      barberId: barberId ?? this.barberId,
      serviceId: serviceId ?? this.serviceId,
      date: date ?? this.date,
      status: status ?? this.status,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == AppointmentStatus.pending.toString();
  bool get isConfirmed => status == AppointmentStatus.confirmed.toString();
  bool get isCompleted => status == AppointmentStatus.completed.toString();
  bool get isCancelled => status == AppointmentStatus.cancelled.toString();
  bool get isNoShow => status == AppointmentStatus.noShow.toString();
}