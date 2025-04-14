import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_search_screen.dart';
import 'service_search_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_empty_state.dart';
import '../../widgets/custom_loading_indicator.dart';
import '../../theme/app_theme.dart';

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
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 0;
  bool _isLoading = true;
  UserModel? _userData;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _services = [];
  List<UserModel> _barbers = [];
  final _searchController = TextEditingController();
  int _currentIndex = 0;
  List<Map<String, dynamic>> _nearbyBarbers = [];
  List<Map<String, dynamic>> _popularServices = [];

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadAppointments(),
        _loadProducts(),
        _loadServices(),
        _loadBarbers(),
        _loadNearbyBarbers(),
        _loadPopularServices(),
      ]);
    } catch (e) {
      _showError('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAppointments() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final appointments = await _firestoreService.getCustomerAppointments(user.uid).first;
        if (mounted) {
          setState(() {
            _appointments = appointments.map((appointment) => appointment.toMap()).toList();
          });
        }
      }
    } catch (e) {
      print('Error loading appointments: $e');
      if (mounted) {
        _showError('Error loading appointments. Please try again.');
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _firestoreService.getAllProducts();
      if (mounted) {
        setState(() {
          _products = products;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      if (mounted) {
        _showError('Error loading products. Please try again.');
      }
    }
  }

  Future<void> _loadServices() async {
    try {
      final services = await _firestoreService.getAllServices();
      if (mounted) {
        setState(() {
          _services = services;
        });
      }
    } catch (e) {
      print('Error loading services: $e');
      if (mounted) {
        _showError('Error loading services. Please try again.');
      }
    }
  }

  Future<void> _loadBarbers() async {
    try {
      final barbers = await _firestoreService.getAllBarbers();
      if (mounted) {
        setState(() {
          _barbers = barbers;
        });
      }
    } catch (e) {
      print('Error loading barbers: $e');
      if (mounted) {
        _showError('Error loading barbers. Please try again.');
      }
    }
  }

  Future<void> _loadNearbyBarbers() async {
    try {
      final barbers = await _firestoreService.getBarberProfiles();
      if (mounted) {
        setState(() {
          _nearbyBarbers = barbers.map((barber) => {
            'uid': barber.uid,
            'name': barber.name,
            'imageUrl': barber.profileImageUrl ?? '',
            'rating': barber.rating ?? 0.0,
            'distance': '2.5 km', // Placeholder
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading nearby barbers: $e');
      if (mounted) {
        _showError('Error loading nearby barbers. Please try again.');
      }
    }
  }

  Future<void> _loadPopularServices() async {
    try {
      final services = await _firestoreService.getAllServices();
      if (mounted) {
        setState(() {
          _popularServices = services.map((service) => {
            'id': service['id'],
            'name': service['name'],
            'imageUrl': service['imageUrl'] ?? '',
            'price': service['price'] ?? 0.0,
            'duration': '30 min', // Placeholder
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading popular services: $e');
      if (mounted) {
        _showError('Error loading popular services. Please try again.');
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await _firestoreService.cancelAppointment(appointmentId);
      _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Error cancelling appointment: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation based on the selected index
    switch (index) {
      case 0: // Home
        // Already on home page, no need to navigate
        break;
      case 1: // Search
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceSearchScreen(userData: _userData!),
          ),
        );
        break;
      case 2: // Appointments
        // Navigate to appointments screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentsScreen(userData: _userData!),
          ),
        );
        break;
      case 3: // Profile
        // Navigate to profile screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userData: _userData!),
          ),
        );
        break;
    }
  }

  void _onSearch(String query) {
    // Implement search functionality
    print('Searching for: $query');
  }

  void _onBarberTap(String barberId) {
    // Navigate to barber profile
    print('Barber tapped: $barberId');
  }

  void _onServiceTap(String serviceId) {
    // Navigate to service details
    print('Service tapped: $serviceId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'BarberNG',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: _isLoading
          ? const CustomLoadingIndicator()
          : RefreshIndicator(
              onRefresh: () async {
                await _loadAppointments();
                await _loadProducts();
                await _loadServices();
                await _loadBarbers();
                await _loadNearbyBarbers();
                await _loadPopularServices();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildNearbyBarbers(),
                    const SizedBox(height: 24),
                    _buildPopularServices(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavBarItem(
            icon: Icons.home,
            label: 'Home',
          ),
          BottomNavBarItem(
            icon: Icons.search,
            label: 'Search',
          ),
          BottomNavBarItem(
            icon: Icons.calendar_today,
            label: 'Appointments',
          ),
          BottomNavBarItem(
            icon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search for barbers or services',
          hintStyle: AppTheme.bodyText2.copyWith(
            color: AppTheme.textSecondaryColor.withOpacity(0.7),
          ),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildNearbyBarbers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Barbers',
          style: AppTheme.heading2,
        ),
        const SizedBox(height: 16),
        if (_nearbyBarbers.isEmpty)
          const NoResultsEmptyState(
            message: 'No barbers found nearby',
            onClearSearch: null,
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _nearbyBarbers.length,
              itemBuilder: (context, index) {
                final barber = _nearbyBarbers[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ServiceCard(
                    title: barber['name'],
                    imageUrl: barber['imageUrl'],
                    onTap: () => _onBarberTap(barber['uid']),
                    actions: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            barber['rating'].toString(),
                            style: AppTheme.bodyText2,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        barber['distance'],
                        style: AppTheme.bodyText2.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPopularServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Services',
          style: AppTheme.heading2,
        ),
        const SizedBox(height: 16),
        if (_popularServices.isEmpty)
          const NoResultsEmptyState(
            message: 'No services available',
            onClearSearch: null,
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _popularServices.length,
            itemBuilder: (context, index) {
              final service = _popularServices[index];
              return ServiceCard(
                title: service['name'],
                imageUrl: service['imageUrl'],
                onTap: () => _onServiceTap(service['id']),
                actions: [
                  Text(
                    '₦${service['price'].toStringAsFixed(2)}',
                    style: AppTheme.heading3.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    service['duration'],
                    style: AppTheme.bodyText2.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
} 