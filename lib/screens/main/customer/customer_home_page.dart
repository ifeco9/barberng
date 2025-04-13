import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../browse_barbers.dart';
import '../appointments_screen.dart';
import '../profile_screen.dart';
import '../../customer/product_search_screen.dart';
import '../../customer/service_search_screen.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';

class CustomerHomePage extends StatefulWidget {
  final UserModel userData;

  const CustomerHomePage({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  UserModel? _userData;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    // Initialize pages with user data
    _pages = [
      const BrowseBarbersScreen(),
      ServiceSearchScreen(userData: widget.userData),
      const ProductSearchScreen(),
      AppointmentsScreen(userData: widget.userData),
      ProfileScreen(key: null, userData: widget.userData),
    ];
    _userData = widget.userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomerBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
} 