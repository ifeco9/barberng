import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/service_model.dart';

class BarberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAvailableBarbers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('isServiceProvider', isEqualTo: true)
          .where('isApproved', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting available barbers: $e');
      return [];
    }
  }

  Future<List<ServiceModel>> getBarberServices(String barberId) async {
    try {
      final snapshot = await _firestore
          .collection('services')
          .where('barberId', isEqualTo: barberId)
          .where('isAvailable', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ServiceModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting barber services: $e');
      return [];
    }
  }

  Future<bool> updateBarberAvailability(String barberId, bool isAvailable) async {
    try {
      await _firestore
          .collection('users')
          .doc(barberId)
          .update({'isAvailable': isAvailable});
      return true;
    } catch (e) {
      print('Error updating barber availability: $e');
      return false;
    }
  }
}