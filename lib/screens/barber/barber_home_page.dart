import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_empty_state.dart';
import '../../widgets/custom_loading_indicator.dart';
import '../../theme/app_theme.dart';

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
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  UserModel? _userData;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _products = [];
  Map<String, dynamic> _statistics = {
    'totalAppointments': 0,
    'completedAppointments': 0,
    'cancelledAppointments': 0,
    'totalEarnings': 0.0,
  };
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadAppointments(),
        _loadServices(),
        _loadProducts(),
        _loadStatistics(),
      ]);
    } catch (e) {
      _showError('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAppointments() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final appointments = await _firestoreService.getBarberAppointments(user.uid).first;
        setState(() {
          _appointments = appointments.map((appointment) => appointment.toMap()).toList();
        });
      }
    } catch (e) {
      _showError('Error loading appointments: $e');
    }
  }

  Future<void> _loadServices() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final services = await _firestoreService.getBarberServices(user.uid);
        setState(() {
          _services = services;
        });
      }
    } catch (e) {
      _showError('Error loading services: $e');
    }
  }

  Future<void> _loadProducts() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final products = await _firestoreService.getBarberProducts(user.uid);
        setState(() {
          _products = products;
        });
      }
    } catch (e) {
      _showError('Error loading products: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final stats = await _firestoreService.getBarberStatistics(user.uid);
        setState(() {
          _statistics = stats;
        });
      }
    } catch (e) {
      _showError('Error loading statistics: $e');
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

  Future<void> _updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestoreService.updateAppointmentStatus(appointmentId, status);
      _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment ${status.toLowerCase()} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Error updating appointment status: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatistics(),
                    const SizedBox(height: 24),
                    _buildTodayAppointments(),
                    const SizedBox(height: 24),
                    _buildServices(),
                    const SizedBox(height: 24),
                    _buildProducts(),
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
            icon: Icons.calendar_today,
            label: 'Appointments',
          ),
          BottomNavBarItem(
            icon: Icons.store,
            label: 'Services',
          ),
          BottomNavBarItem(
            icon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: AppTheme.heading2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Appointments',
                value: _statistics['totalAppointments'].toString(),
                icon: Icons.calendar_today,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Total Earnings',
                value: '₦${_statistics['totalEarnings'].toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.bodyText2.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTheme.heading3.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayAppointments() {
    final today = DateTime.now();
    final todayAppointments = _appointments.where((appointment) {
      final appointmentDate = (appointment['date'] as Timestamp).toDate();
      return appointmentDate.year == today.year &&
          appointmentDate.month == today.month &&
          appointmentDate.day == today.day;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Appointments',
          style: AppTheme.heading2,
        ),
        const SizedBox(height: 16),
        if (todayAppointments.isEmpty)
          const NoResultsEmptyState(
            message: 'No appointments for today',
            onClearSearch: null,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todayAppointments.length,
            itemBuilder: (context, index) {
              final appointment = todayAppointments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CustomCard(
                  child: ListTile(
                    title: Text(
                      appointment['customerName'] ?? 'Unknown Customer',
                      style: AppTheme.heading3,
                    ),
                    subtitle: Text(
                      '${appointment['serviceName'] ?? 'Unknown Service'} - ${DateFormat.jm().format((appointment['time'] as Timestamp).toDate())}',
                      style: AppTheme.bodyText2,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _updateAppointmentStatus(
                            appointment['id'],
                            'completed',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _updateAppointmentStatus(
                            appointment['id'],
                            'cancelled',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: AppTheme.heading2,
        ),
        const SizedBox(height: 16),
        if (_services.isEmpty)
          const NoResultsEmptyState(
            message: 'No services available',
            onClearSearch: null,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CustomCard(
                  child: ListTile(
                    title: Text(
                      service['name'],
                      style: AppTheme.heading3,
                    ),
                    subtitle: Text(
                      '₦${service['price'].toStringAsFixed(2)} - ${service['duration']}',
                      style: AppTheme.bodyText2,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to edit service page
                      },
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products',
          style: AppTheme.heading2,
        ),
        const SizedBox(height: 16),
        if (_products.isEmpty)
          const NoResultsEmptyState(
            message: 'No products available',
            onClearSearch: null,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CustomCard(
                  child: ListTile(
                    title: Text(
                      product['name'],
                      style: AppTheme.heading3,
                    ),
                    subtitle: Text(
                      '₦${product['price'].toStringAsFixed(2)} - ${product['stock']} in stock',
                      style: AppTheme.bodyText2,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to edit product page
                      },
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
} 