import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User-related methods
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      return await getUserById(user.uid);
    } catch (e) {
      print('Error getting current user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> createUserDocument(UserModel user) async {
    try {
      final userData = user.toMap();
      await _firestore.collection('users').doc(user.uid).set(userData);
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }

  Future<void> updateUserDocument(UserModel user) async {
    try {
      final userData = user.toMap();
      await _firestore.collection('users').doc(user.uid).update(userData);
    } catch (e) {
      print('Error updating user document: $e');
      rethrow;
    }
  }

  Future<void> deleteUserDocument(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      print('Error deleting user document: $e');
      rethrow;
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    try {
      final query = await _firestore.collection('users')
          .where('email', isEqualTo: email)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email registration: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> getBarberProfiles() async {
    try {
      final query = await _firestore.collection('users')
          .where('isServiceProvider', isEqualTo: true)
          .get();
      return query.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting barber profiles: $e');
      rethrow;
    }
  }

  // Appointment-related methods
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final userData = await getUserById(user.uid);
      if (userData == null) return [];

      final query = _firestore.collection('appointments')
          .where(userData.isServiceProvider ? 'barberId' : 'userId', isEqualTo: user.uid)
          .orderBy('date', descending: true);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting appointments: $e');
      rethrow;
    }
  }

  Stream<List<AppointmentModel>> getBarberAppointments(String barberId) {
    return _firestore.collection('appointments')
        .where('barberId', isEqualTo: barberId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<AppointmentModel>> getCustomerAppointments(String userId) {
    return _firestore.collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> createAppointment(AppointmentModel appointment) async {
    try {
      await _firestore.collection('appointments').doc(appointment.id).set(appointment.toMap());
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }

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

  // Barber methods
  Future<List<UserModel>> getAllBarbers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isServiceProvider', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return UserModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting all barbers: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> searchBarbers(String query) async {
    try {
      final barbers = await getAllBarbers();
      return barbers.where((barber) {
        final name = barber.name.toLowerCase();
        final address = barber.address?.toLowerCase() ?? '';
        final services = barber.services?.join(' ').toLowerCase() ?? '';
        final bio = barber.bio?.toLowerCase() ?? '';
        
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) ||
            address.contains(searchQuery) ||
            services.contains(searchQuery) ||
            bio.contains(searchQuery);
      }).toList();
    } catch (e) {
      print('Error searching barbers: $e');
      return [];
    }
  }

  // Profile methods
  Future<void> updateBarberProfile(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(id).update(data);
    } catch (e) {
      print('Error updating barber profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String phoneNumber,
    String? address,
    String? bio,
    String? profileImageUrl,
    Map<String, Map<String, String>>? workingHours,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final userData = {
        'name': name,
        'phoneNumber': phoneNumber,
        'address': address,
        'bio': bio,
        'profileImageUrl': profileImageUrl,
        'workingHours': workingHours,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Remove null values
      userData.removeWhere((key, value) => value == null);

      await _firestore.collection('users').doc(user.uid).update(userData);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Product Methods
  Future<void> createOrder({
    required String userId,
    required String productId,
    required int quantity,
    required double totalAmount,
    required String paymentReference,
    required String status,
  }) async {
    try {
      await _firestore.collection('orders').add({
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
        'totalAmount': totalAmount,
        'paymentReference': paymentReference,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating product stock: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting all products: $e');
      rethrow;
    }
  }

  // Service Methods
  Future<List<Map<String, dynamic>>> getAllServices() async {
    try {
      final querySnapshot = await _firestore.collection('services').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting all services: $e');
      rethrow;
    }
  }

  Stream<List<AppointmentModel>> streamBarberAppointments(String barberId) {
    return _firestore
        .collection('appointments')
        .where('barberId', isEqualTo: barberId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Barber Profile Methods
  Future<Map<String, dynamic>> getBarberProfile(String userId) async {
    final doc = await _firestore.collection('barbers').doc(userId).get();
    return doc.data() ?? {};
  }

  Future<Map<String, dynamic>> getBarberByUserId(String userId) async {
    final querySnapshot = await _firestore
        .collection('barbers')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isEmpty) {
      throw Exception('Barber not found');
    }
    
    return querySnapshot.docs.first.data();
  }

  // Barber Services Methods
  Future<List<Map<String, dynamic>>> getBarberServices(String barberId) async {
    final querySnapshot = await _firestore
        .collection('services')
        .where('barberId', isEqualTo: barberId)
        .get();
    
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addBarberService(Map<String, dynamic> service) async {
    await _firestore.collection('services').add(service);
  }

  Future<void> deleteBarberService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).delete();
  }

  // Barber Products Methods
  Future<List<Map<String, dynamic>>> getBarberProducts(String barberId) async {
    final querySnapshot = await _firestore
        .collection('products')
        .where('barberId', isEqualTo: barberId)
        .get();
    
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addBarberProduct(Map<String, dynamic> product) async {
    await _firestore.collection('products').add(product);
  }

  Future<void> deleteBarberProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // Barber Statistics Methods
  Future<Map<String, dynamic>> getBarberStatistics(String barberId) async {
    try {
      final appointments = await _firestore
          .collection('appointments')
          .where('barberId', isEqualTo: barberId)
          .get();

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      int totalAppointments = 0;
      int todayAppointments = 0;
      int pendingAppointments = 0;
      int completedAppointments = 0;

      for (var doc in appointments.docs) {
        final appointment = AppointmentModel.fromMap(doc.data());
        totalAppointments++;

        if (appointment.date.isAfter(todayStart) && appointment.date.isBefore(todayEnd)) {
          todayAppointments++;
        }

        if (appointment.status.toLowerCase() == 'pending') {
          pendingAppointments++;
        } else if (appointment.status.toLowerCase() == 'completed') {
          completedAppointments++;
        }
      }

      return {
        'totalAppointments': totalAppointments,
        'todayAppointments': todayAppointments,
        'pendingAppointments': pendingAppointments,
        'completedAppointments': completedAppointments,
      };
    } catch (e) {
      print('Error getting barber statistics: $e');
      rethrow;
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error cancelling appointment: $e');
      rethrow;
    }
  }
}