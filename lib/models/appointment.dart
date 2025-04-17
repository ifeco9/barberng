class Appointment {
  final String id;
  final String customerId;
  final String barberId;
  final DateTime dateTime;
  final String status;
  final String? serviceId;
  final double? price;
  final String? notes;

  Appointment({
    required this.id,
    required this.customerId,
    required this.barberId,
    required this.dateTime,
    required this.status,
    this.serviceId,
    this.price,
    this.notes,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      barberId: map['barberId'] ?? '',
      dateTime: map['dateTime']?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'pending',
      serviceId: map['serviceId'],
      price: map['price']?.toDouble(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'barberId': barberId,
      'dateTime': dateTime,
      'status': status,
      'serviceId': serviceId,
      'price': price,
      'notes': notes,
    };
  }
}