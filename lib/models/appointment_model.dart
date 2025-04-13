import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String userId;
  final String barberId;
  final String barberName;
  final String customerName;
  final String serviceName;
  final DateTime date;
  final String time;
  final String service;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.barberId,
    required this.barberName,
    required this.customerName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.service,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'barberId': barberId,
      'barberName': barberName,
      'customerName': customerName,
      'serviceName': serviceName,
      'date': Timestamp.fromDate(date),
      'time': time,
      'service': service,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      barberId: map['barberId'] ?? '',
      barberName: map['barberName'] ?? '',
      customerName: map['customerName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      service: map['service'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? barberId,
    String? barberName,
    String? customerName,
    String? serviceName,
    DateTime? date,
    String? time,
    String? service,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      barberId: barberId ?? this.barberId,
      barberName: barberName ?? this.barberName,
      customerName: customerName ?? this.customerName,
      serviceName: serviceName ?? this.serviceName,
      date: date ?? this.date,
      time: time ?? this.time,
      service: service ?? this.service,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 