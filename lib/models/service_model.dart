import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String barberId;
  final String name;
  final double price;
  final int durationMinutes;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.barberId,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.description,
    this.imageUrl,
    required this.isAvailable,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'barberId': barberId,
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      barberId: map['barberId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      durationMinutes: map['durationMinutes']?.toInt() ?? 30,
      description: map['description'],
      imageUrl: map['imageUrl'],
      isAvailable: map['isAvailable'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  ServiceModel copyWith({
    String? id,
    String? barberId,
    String? name,
    double? price,
    int? durationMinutes,
    String? description,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      barberId: barberId ?? this.barberId,
      name: name ?? this.name,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}