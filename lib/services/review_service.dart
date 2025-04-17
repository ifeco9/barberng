import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ReviewModel>> getBarberReviews(String barberId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('barberId', isEqualTo: barberId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting barber reviews: $e');
      return [];
    }
  }

  Stream<List<ReviewModel>> watchBarberReviews(String barberId) {
    return _firestore
        .collection('reviews')
        .where('barberId', isEqualTo: barberId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<double> getBarberAverageRating(String barberId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('barberId', isEqualTo: barberId)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      final totalRating = snapshot.docs.fold<int>(
          0, (sum, doc) => sum + (doc.data()['rating'] as int));
      return totalRating / snapshot.docs.length;
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0;
    }
  }

  Future<bool> createReview(ReviewModel review) async {
    try {
      await _firestore.collection('reviews').add(review.toMap());
      return true;
    } catch (e) {
      print('Error creating review: $e');
      return false;
    }
  }

  Future<bool> updateReview(ReviewModel review) async {
    try {
      await _firestore
          .collection('reviews')
          .doc(review.id)
          .update(review.toMap());
      return true;
    } catch (e) {
      print('Error updating review: $e');
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }
}