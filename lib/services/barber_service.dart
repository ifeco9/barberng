import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service_model.dart';
import '../models/product_model.dart';
import '../models/appointment_model.dart';

class BarberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Service Management
  Future<List<ServiceModel>> getBarberServices(String barberId) async {
    try {
      final querySnapshot = await _firestore
          .collection('services')
          .where('barberId', isEqualTo: barberId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting barber services: $e');
      rethrow;
    }
  }

  Future<ServiceModel> createService(ServiceModel service) async {
    try {
      final serviceRef = _firestore.collection('services').doc();
      final serviceWithId = service.copyWith(id: serviceRef.id);
      await serviceRef.set(serviceWithId.toMap());
      return serviceWithId;
    } catch (e) {
      print('Error creating service: $e');
      rethrow;
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      await _firestore
          .collection('services')
          .doc(service.id)
          .update(service.toMap());
    } catch (e) {
      print('Error updating service: $e');
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).delete();
    } catch (e) {
      print('Error deleting service: $e');
      rethrow;
    }
  }

  // Product Management
  Future<List<ProductModel>> getBarberProducts(String barberId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('barberId', isEqualTo: barberId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting barber products: $e');
      rethrow;
    }
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final productRef = _firestore.collection('products').doc();
      final productWithId = product.copyWith(id: productRef.id);
      await productRef.set(productWithId.toMap());
      return productWithId;
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getBarberStatistics(
    String barberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final appointmentsQuery = await _firestore
          .collection('appointments')
          .where('barberId', isEqualTo: barberId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();

      final appointments = appointmentsQuery.docs
          .map((doc) => AppointmentModel.fromMap(doc.data()))
          .toList();

      int totalAppointments = appointments.length;
      int completedAppointments =
          appointments.where((a) => a.isCompleted).length;
      int cancelledAppointments =
          appointments.where((a) => a.isCancelled).length;
      double totalEarnings = appointments
          .where((a) => a.isCompleted)
          .fold(0, (sum, a) => sum + a.price);

      return {
        'totalAppointments': totalAppointments,
        'completedAppointments': completedAppointments,
        'cancelledAppointments': cancelledAppointments,
        'totalEarnings': totalEarnings,
        'averageRating': 0.0, // TODO: Implement rating system
      };
    } catch (e) {
      print('Error getting barber statistics: $e');
      rethrow;
    }
  }

  // Working Hours
  Future<void> updateWorkingHours(
    String barberId,
    Map<String, Map<String, dynamic>> workingHours,
  ) async {
    try {
      await _firestore
          .collection('barbers')
          .doc(barberId)
          .update({'workingHours': workingHours});
    } catch (e) {
      print('Error updating working hours: $e');
      rethrow;
    }
  }

  Future<Map<String, Map<String, dynamic>>> getWorkingHours(
    String barberId,
  ) async {
    try {
      final doc = await _firestore.collection('barbers').doc(barberId).get();
      return Map<String, Map<String, dynamic>>.from(
        doc.data()?['workingHours'] ?? {},
      );
    } catch (e) {
      print('Error getting working hours: $e');
      rethrow;
    }
  }

  // Profile Management
  Future<void> updateBarberProfile(
    String barberId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await _firestore
          .collection('barbers')
          .doc(barberId)
          .update(profileData);
    } catch (e) {
      print('Error updating barber profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBarberProfile(String barberId) async {
    try {
      final doc = await _firestore.collection('barbers').doc(barberId).get();
      return doc.data() ?? {};
    } catch (e) {
      print('Error getting barber profile: $e');
      rethrow;
    }
  }
} 