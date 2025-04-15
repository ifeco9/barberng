class Appointment {
  final String id;
  final String customerId;
  final String customerName;
  final String barberId;
  final String serviceId;
  final String serviceName;
  final DateTime dateTime;
  final double price;
  final String status; // pending, accepted, completed, rejected
  final String? notes;

  Appointment({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.barberId,
    required this.serviceId,
    required this.serviceName,
    required this.dateTime,
    required this.price,
    required this.status,
    this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      barberId: json['barberId'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'barberId': barberId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'dateTime': dateTime.toIso8601String(),
      'price': price,
      'status': status,
      'notes': notes,
    };
  }

  Appointment copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? barberId,
    String? serviceId,
    String? serviceName,
    DateTime? dateTime,
    double? price,
    String? status,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      barberId: barberId ?? this.barberId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      dateTime: dateTime ?? this.dateTime,
      price: price ?? this.price,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
} 