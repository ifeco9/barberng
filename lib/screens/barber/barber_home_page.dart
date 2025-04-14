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

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadAppointments(),
        _loadServices(),
        _loadProducts(),
        _loadStatistics(),
      ]);
    } catch (e) {
      _showError('Error refreshing dashboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your dashboard...'),
            ],
          ),
        ),
      );
    }

    // Validate required data for barbers
    if (widget.userData.services == null || widget.userData.services!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Setup Required'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Setup Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please complete your profile by adding services to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to profile setup
                    Navigator.pushNamed(
                      context,
                      '/barber-profile',
                      arguments: {'userData': widget.userData},
                    );
                  },
                  child: const Text('Complete Setup'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildRecentAppointmentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${widget.userData.name}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s what\'s happening with your business today.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Appointments',
              _statistics['totalAppointments'].toString(),
              Icons.calendar_today,
              Colors.blue,
            ),
            _buildStatCard(
              'Completed',
              _statistics['completedAppointments'].toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Cancelled',
              _statistics['cancelledAppointments'].toString(),
              Icons.cancel,
              Colors.red,
            ),
            _buildStatCard(
              'Total Earnings',
              '₦${_statistics['totalEarnings'].toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Appointments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_appointments.isEmpty)
          const Center(
            child: Text(
              'No appointments yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _appointments.length > 5 ? 5 : _appointments.length,
            itemBuilder: (context, index) {
              final appointment = _appointments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.person, color: Colors.green),
                  ),
                  title: Text(appointment['customerName'] ?? 'Unknown Customer'),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy - hh:mm a')
                        .format((appointment['date'] as Timestamp).toDate()),
                  ),
                  trailing: _buildStatusChip(appointment['status'] ?? 'pending'),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
    );
  }
} 