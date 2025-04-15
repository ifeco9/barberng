import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart';
import '../models/appointment.dart';
import '../models/service_model.dart';
import 'dart:async';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch customer name from users collection
  Future<String> getUserName(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['name'] ?? 'Unknown';
    } catch (e) {
      print('Error getting user name: $e');
      return 'Unknown';
    }
  }

  // Fetch service name from services collection
  Future<String> getServiceName(String serviceId) async {
    try {
      final serviceDoc = await _firestore.collection('services').doc(serviceId).get();
      return serviceDoc.data()?['name'] ?? 'Unknown';
    } catch (e) {
      print('Error getting service name: $e');
      return 'Unknown';
    }
  }

  // Convert AppointmentModel to Appointment
  Future<Appointment> _convertToAppointment(AppointmentModel model) async {
    final customerName = await getUserName(model.userId);
    final serviceName = await getServiceName(model.serviceId);
    return Appointment(
      id: model.id,
      customerId: model.userId,
      customerName: customerName,
      barberId: model.barberId,
      serviceId: model.serviceId,
      serviceName: serviceName,
      dateTime: model.date,
      price: model.price,
      status: model.status,
      notes: model.notes,
    );
  }

  // Get user appointments as Stream<List<Appointment>>
  Stream<List<Appointment>> getUserAppointments(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final models = snapshot.docs
          .map((doc) => AppointmentModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      final appointments = await Future.wait(models.map(_convertToAppointment));
      return appointments;
    });
  }

  // Get barber appointments as Stream<List<Appointment>>
  Stream<List<Appointment>> getBarberAppointments(String barberId) {
    return _firestore
        .collection('appointments')
        .where('barberId', isEqualTo: barberId)
        .snapshots()
        .asyncMap((snapshot) async {
      final models = snapshot.docs
          .map((doc) => AppointmentModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      final appointments = await Future.wait(models.map(_convertToAppointment));
      return appointments;
    });
  }

  // Create appointment
  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      final docRef = await _firestore.collection('appointments').add(appointment.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating appointment status: $e');
      rethrow;
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': AppointmentStatus.cancelled.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error cancelling appointment: $e');
      rethrow;
    }
  }

  // Get appointment by ID
  Future<AppointmentModel?> getAppointmentById(String appointmentId) async {
    try {
      final doc = await _firestore.collection('appointments').doc(appointmentId).get();
      if (doc.exists) {
        return AppointmentModel.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting appointment: $e');
      rethrow;
    }
  }

  // Check if time slot is available
  Future<bool> isTimeSlotAvailable(
      String barberId,
      DateTime date,
      int duration,
      ) async {
    try {
      final startTime = date;
      final endTime = date.add(Duration(minutes: duration));

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('barberId', isEqualTo: barberId)
          .where('date', isGreaterThanOrEqualTo: startTime)
          .where('date', isLessThan: endTime)
          .where('status', whereIn: [
        AppointmentStatus.pending.toString(),
        AppointmentStatus.confirmed.toString(),
      ])
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking time slot availability: $e');
      rethrow;
    }
  }

  // Get available time slots for a barber
  Future<List<DateTime>> getAvailableTimeSlots(
      String barberId,
      DateTime date,
      List<ServiceModel> services,
      ) async {
    try {
      final List<DateTime> availableSlots = [];
      final startOfDay = DateTime(date.year, date.month, date.day, 9); // 9 AM
      final endOfDay = DateTime(date.year, date.month, date.day, 17); // 5 PM

      for (var time = startOfDay;
      time.isBefore(endOfDay);
      time = time.add(const Duration(minutes: 30))) {
        bool isAvailable = true;
        for (var service in services) {
          if (!await isTimeSlotAvailable(barberId, time, service.duration)) {
            isAvailable = false;
            break;
          }
        }
        if (isAvailable) {
          availableSlots.add(time);
        }
      }

      return availableSlots;
    } catch (e) {
      print('Error getting available time slots: $e');
      rethrow;
    }
  }
}