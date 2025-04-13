import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_home_page.dart';
import 'screens/barber/barber_home_page.dart';
import 'models/user_model.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authSnapshot.hasData || authSnapshot.data == null) {
          print('No authenticated user, showing login screen');
          return const LoginScreen();
        }

        final userId = authSnapshot.data!.uid;
        print('Authenticated user found with ID: $userId');
        
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              print('No user data found for ID: $userId, showing onboarding');
              return const OnboardingScreen();
            }

            try {
              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
              final isServiceProvider = userData['isServiceProvider'] ?? false;
              
              print('User role: ${isServiceProvider ? 'Barber' : 'Customer'}');
              
              final userModel = UserModel.fromMap({
                'id': userId,
                ...userData,
              });

              if (isServiceProvider) {
                print('Navigating to BarberHomePage');
                return BarberHomePage(userData: userModel);
              } else {
                print('Navigating to CustomerHomePage');
                return CustomerHomePage(userData: userModel);
              }
            } catch (e) {
              print('Error processing user data: $e');
              return const Scaffold(
                body: Center(
                  child: Text('Error loading user data. Please try again.'),
                ),
              );
            }
          },
        );
      },
    );
  }
}