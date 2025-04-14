import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      // Validate email format
      if (!email.contains('@') || !email.contains('.')) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is badly formatted.',
        );
      }

      // Validate password length
      if (password.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Password should be at least 6 characters.',
        );
      }

      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      // Handle specific error codes
      switch (e.code) {
        case 'email-already-in-use':
          print('The email address is already in use by another account.');
          break;
        case 'invalid-email':
          print('The email address is badly formatted.');
          break;
        case 'weak-password':
          print('The password is too weak.');
          break;
        case 'operation-not-allowed':
          print('Email/password accounts are not enabled.');
          break;
        default:
          print('Unknown error: ${e.code}');
      }
      rethrow;
    } catch (e) {
      print('Unexpected error during sign up: $e');
      rethrow;
    }
  }

  // Sign in with email and password - updated with additional error handling
  Future<UserCredential> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      // First validate input parameters to avoid sending bad requests
      if (email.isEmpty || !email.contains('@')) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is badly formatted.',
        );
      }
      if (password.isEmpty) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Password cannot be empty.',
        );
      }

      // Try to sign in
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Verify we have a valid user
        if (userCredential.user == null) {
          throw FirebaseAuthException(
            code: 'null-user',
            message: 'Authentication succeeded but user is null.',
          );
        }

        return userCredential;
      } catch (e) {
        // Check if this is the PigeonUserDetails error
        if (e.toString().contains('PigeonUserDetails')) {
          print('Detected PigeonUserDetails error, attempting to recover...');

          // Try to get the current user directly
          final currentUser = _auth.currentUser;
          if (currentUser != null) {
            print('Successfully recovered user: ${currentUser.uid}');
            // Instead of creating a new UserCredential, we'll throw a custom error
            // that the login screen can handle
            throw FirebaseAuthException(
              code: 'recovered-user',
              message: currentUser.uid,
            );
          }
        }
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign in: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during sign in: $e');
      // Create a more descriptive error that will be easier to debug
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Authentication failed. Please try again later or contact support. Error: ${e.toString()}',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email,
      String password,
      String name,
      String phoneNumber,
      bool isServiceProvider,
      ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final user = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        isServiceProvider: isServiceProvider,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      return userCredential;
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }
}