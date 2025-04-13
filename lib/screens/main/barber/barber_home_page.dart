import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../barber/barber_dashboard_screen.dart';
import '../../barber/barber_services_screen.dart';
import '../../barber/barber_products_screen.dart';
import '../../barber/barber_profile_screen.dart';
import '../appointments_screen.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';

class BarberHomePage extends StatefulWidget {
  final UserModel userData;

  const BarberHomePage({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<BarberHomePage> createState() => _BarberHomePageState();
}

class _BarberHomePageState extends State<BarberHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      BarberDashboardScreen(userData: widget.userData),
      AppointmentsScreen(userData: widget.userData),
      BarberServicesScreen(userData: widget.userData),
      BarberProductsScreen(userData: widget.userData),
      BarberProfileScreen(userData: widget.userData),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavBarItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
          ),
          BottomNavBarItem(
            icon: Icons.calendar_today,
            label: 'Appointments',
          ),
          BottomNavBarItem(
            icon: Icons.cut,
            label: 'Services',
          ),
          BottomNavBarItem(
            icon: Icons.shopping_bag,
            label: 'Products',
          ),
          BottomNavBarItem(
            icon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 