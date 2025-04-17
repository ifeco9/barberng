import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Search barbers
  Future<List<UserModel>> searchBarbers({
    String? query,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      Query barbersQuery = _firestore
          .collection('users')
          .where('isServiceProvider', isEqualTo: true)
          .where('isApproved', isEqualTo: true);

      if (query != null && query.isNotEmpty) {
        barbersQuery = barbersQuery.where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff');
      }

      final querySnapshot = await barbersQuery.get();
      List<UserModel> barbers = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      // Filter by location if coordinates are provided
      if (latitude != null && longitude != null && radius != null) {
        barbers = barbers.where((barber) {
          if (barber.latitude == null || barber.longitude == null) return false;
          
          final distance = _calculateDistance(
            latitude,
            longitude,
            barber.latitude!,
            barber.longitude!,
          );
          
          return distance <= radius;
        }).toList();
      }

      return barbers;
    } catch (e) {
      print('Error searching barbers: $e');
      rethrow;
    }
  }

  // Get barber services
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

  // Get customer appointments
  Stream<List<AppointmentModel>> getCustomerAppointments() {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      return _firestore
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      print('Error getting customer appointments: $e');
      rethrow;
    }
  }

  // Get appointment history
  Future<List<AppointmentModel>> getAppointmentHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      Query query = _firestore
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: [
            AppointmentStatus.completed.toString(),
            AppointmentStatus.cancelled.toString(),
          ]);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }

      final querySnapshot = await query.orderBy('date', descending: true).get();
      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting appointment history: $e');
      rethrow;
    }
  }

  // Rate barber
  Future<void> rateBarber(
    String barberId,
    String appointmentId,
    double rating,
    String? review,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final ratingRef = _firestore.collection('ratings').doc();
      await ratingRef.set({
        'id': ratingRef.id,
        'userId': user.uid,
        'barberId': barberId,
        'appointmentId': appointmentId,
        'rating': rating,
        'review': review,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update barber's average rating
      final barberRatings = await _firestore
          .collection('ratings')
          .where('barberId', isEqualTo: barberId)
          .get();

      final totalRatings = barberRatings.docs.length;
      final averageRating = barberRatings.docs.fold<double>(
            0,
            (sum, doc) => sum + (doc.data()['rating'] as double),
          ) /
          totalRatings;

      await _firestore.collection('barbers').doc(barberId).update({
        'averageRating': averageRating,
        'totalRatings': totalRatings,
      });
    } catch (e) {
      print('Error rating barber: $e');
      rethrow;
    }
  }

  // Helper method to calculate distance between two points
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // in kilometers

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() * (dLon / 2).sin() * (dLon / 2).sin();
    double c = 2 * a.sqrt().asin();
    double distance = earthRadius * c;

    return distance;
  }

  double _toRadians(double degree) {
    return degree * (3.141592653589793 / 180);
  }
}