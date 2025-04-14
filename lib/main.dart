import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'wrapper.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/user_type_selection_screen.dart';
import 'screens/auth/barber_signup_screen.dart';
import 'screens/auth/customer_signup_screen.dart';
import 'screens/barber/barber_home_page.dart';
import 'screens/customer/customer_home_page.dart';
import 'screens/customer/product_search_screen.dart';
import 'screens/customer/service_search_screen.dart';
import 'screens/customer/product_details_screen.dart';
import 'screens/barber/barber_profile_screen.dart';
import 'models/user_model.dart';
import 'screens/splash_screen.dart';

Future<void> _checkLocationPermission() async {
  try {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied, we cannot request permissions.');
      return;
    }
  } catch (e) {
    print('Error checking location permissions: $e');
    // Continue without location permissions
  }
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    
    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    // Configure Firebase Auth persistence only for web
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }
    
    // Configure Firebase Storage
    FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 30));
    FirebaseStorage.instance.setMaxOperationRetryTime(const Duration(seconds: 30));
    
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Continue without Firebase persistence - app will still work
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first
  await _initializeFirebase();
  
  // Then check location permissions
  await _checkLocationPermission();
  
  runApp(const BarberApp());
}

class BarberApp extends StatelessWidget {
  const BarberApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarberNG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/wrapper': (context) => const Wrapper(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/user-type': (context) => const UserTypeSelectionScreen(),
        '/barber-signup': (context) => const BarberSignupScreen(),
        '/customer-signup': (context) => const CustomerSignupScreen(),
        '/barber-home': (context) => BarberHomePage(userData: ModalRoute.of(context)!.settings.arguments as UserModel),
        '/customer-home': (context) => CustomerHomePage(userData: ModalRoute.of(context)!.settings.arguments as UserModel),
        '/product-search': (context) => const ProductSearchScreen(),
        '/service-search': (context) => ServiceSearchScreen(userData: ModalRoute.of(context)!.settings.arguments as UserModel),
        '/product-details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProductDetailsScreen(product: args['product']);
        },
        '/barber-profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return BarberProfileScreen(userData: args['userData']);
        },
      },
    );
  }
}