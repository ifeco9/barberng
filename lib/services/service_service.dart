import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ServiceModel>> getBarberServices(String barberId) async {
    try {
      final snapshot = await _firestore
          .collection('services')
          .where('barberId', isEqualTo: barberId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ServiceModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting barber services: $e');
      return [];
    }
  }

  Stream<List<ServiceModel>> watchBarberServices(String barberId) {
    return _firestore
        .collection('services')
        .where('barberId', isEqualTo: barberId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<bool> createService(ServiceModel service) async {
    try {
      await _firestore.collection('services').add(service.toMap());
      return true;
    } catch (e) {
      print('Error creating service: $e');
      return false;
    }
  }

  Future<bool> updateService(ServiceModel service) async {
    try {
      await _firestore
          .collection('services')
          .doc(service.id)
          .update(service.toMap());
      return true;
    } catch (e) {
      print('Error updating service: $e');
      return false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).delete();
      return true;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  Future<bool> toggleServiceAvailability(String serviceId, bool isAvailable) async {
    try {
      await _firestore
          .collection('services')
          .doc(serviceId)
          .update({'isAvailable': isAvailable});
      return true;
    } catch (e) {
      print('Error toggling service availability: $e');
      return false;
    }
  }
}