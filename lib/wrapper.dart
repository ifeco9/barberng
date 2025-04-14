import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_home_page.dart';
import 'screens/barber/barber_home_page.dart';
import 'screens/maintenance/maintenance_screen.dart';
import 'models/user_model.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _isValidating = true;
  bool _hasNetwork = true;
  int _validationAttempts = 0;
  Timer? _validationTimer;
  UserModel? _lastValidUser;
  StreamSubscription? _connectivitySubscription;
  
  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _startValidationTimer();
  }
  
  @override
  void dispose() {
    _validationTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _initializeConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        _hasNetwork = connectivityResult != ConnectivityResult.none;
      });
      
      _connectivitySubscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) {
        setState(() {
          _hasNetwork = result != ConnectivityResult.none;
        });
      });
    } catch (e) {
      print('Error initializing connectivity: $e');
      // Default to assuming we have network if we can't check
      setState(() => _hasNetwork = true);
    }
  }
  
  void _startValidationTimer() {
    _validationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_validationAttempts >= 3) {
        timer.cancel();
        setState(() => _isValidating = false);
      } else {
        setState(() => _validationAttempts++);
      }
    });
  }
  
  bool _isValidUserType(UserModel user) {
    if (user.isServiceProvider) {
      return user.isApproved;
    }
    return true;
  }
  
  bool _isConsistentUserType(UserModel user) {
    if (_lastValidUser == null) {
      _lastValidUser = user;
      return true;
    }
    
    final isConsistent = _lastValidUser!.isServiceProvider == user.isServiceProvider;
    if (isConsistent) {
      _lastValidUser = user;
    }
    return isConsistent;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Handle connection errors
        if (authSnapshot.hasError) {
          print('Auth error: ${authSnapshot.error}');
          return const MaintenanceScreen(
            message: 'Authentication error. Please try again later.',
          );
        }

        // Show loading state only during initial validation
        if (authSnapshot.connectionState == ConnectionState.waiting && _isValidating) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Validating user session...'),
                ],
              ),
            ),
          );
        }

        // Handle no network state
        if (!_hasNetwork) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('No internet connection'),
                  const SizedBox(height: 8),
                  const Text('Please check your connection and try again'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _initializeConnectivity();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle no authenticated user
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LoginScreen();
        }

        final userId = authSnapshot.data!.uid;
        
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, userSnapshot) {
            // Handle Firestore errors
            if (userSnapshot.hasError) {
              print('Firestore error: ${userSnapshot.error}');
              return const MaintenanceScreen(
                message: 'Error loading user data. Please try again later.',
              );
            }

            // Show loading state only during initial load
            if (userSnapshot.connectionState == ConnectionState.waiting && _isValidating) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Handle no user data
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const OnboardingScreen();
            }

            try {
              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
              
              // Validate isServiceProvider field
              if (!userData.containsKey('isServiceProvider') || 
                  userData['isServiceProvider'] == null ||
                  !(userData['isServiceProvider'] is bool)) {
                return const MaintenanceScreen(
                  message: 'User type validation failed. Please contact support.',
                );
              }
              
              final isServiceProvider = userData['isServiceProvider'] ?? false;
              
              final userModel = UserModel.fromMap({
                'uid': userId,
                ...userData,
              });
              
              // Validate user data
              if (!userModel.isValid()) {
                return const MaintenanceScreen(
                  message: 'User data validation failed. Please contact support.',
                );
              }
              
              // Check for user type consistency
              if (!_isConsistentUserType(userModel)) {
                return const MaintenanceScreen(
                  message: 'User type inconsistency detected. Please contact support.',
                );
              }
              
              // Check if user can access their role
              if (isServiceProvider && !userModel.canAccessBarberFeatures()) {
                return const MaintenanceScreen(
                  message: 'Your barber account is pending approval.',
                );
              }
              
              if (isServiceProvider) {
                return BarberHomePage(userData: userModel);
              } else {
                return CustomerHomePage(userData: userModel);
              }
            } catch (e, stackTrace) {
              print('Error processing user data: $e');
              print('Stack trace: $stackTrace');
              return const MaintenanceScreen(
                message: 'Error processing user data. Please try again later.',
              );
            }
          },
        );
      },
    );
  }
}