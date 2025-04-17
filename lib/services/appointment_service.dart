import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Appointment>> watchBarberAppointments(String barberId) {
    return _firestore
        .collection('appointments')
        .where('barberId', isEqualTo: barberId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<Appointment>> watchCustomerAppointments(String customerId) {
    return _firestore
        .collection('appointments')
        .where('customerId', isEqualTo: customerId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<List<Appointment>> getBarberAppointments(String barberId) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('barberId', isEqualTo: barberId)
          .orderBy('dateTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting barber appointments: $e');
      return [];
    }
  }

  Future<List<Appointment>> getCustomerAppointments(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('customerId', isEqualTo: customerId)
          .orderBy('dateTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting customer appointments: $e');
      return [];
    }
  }

  Future<bool> createAppointment(Appointment appointment) async {
    try {
      final docRef = await _firestore.collection('appointments').add(appointment.toMap());
      await _firestore.collection('notifications').add({
        'userId': appointment.customerId,
        'type': 'appointment_created',
        'appointmentId': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error creating appointment: $e');
      return false;
    }
  }

  Future<bool> updateAppointmentStatus(String appointmentId, String status, {String? cancelReason}) async {
    try {
      final data = {'status': status};
      if (cancelReason != null) {
        data['cancelReason'] = cancelReason;
      }
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update(data);
      return true;
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }

  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
      return true;
    } catch (e) {
      print('Error deleting appointment: $e');
      return false;
    }
  }
}