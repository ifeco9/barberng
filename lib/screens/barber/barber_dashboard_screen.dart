import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/appointment_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_loading_indicator.dart';
import '../../widgets/custom_empty_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BarberDashboardScreen extends StatefulWidget {
  final UserModel userData;

  const BarberDashboardScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<BarberDashboardScreen> createState() => _BarberDashboardScreenState();
}

class _BarberDashboardScreenState extends State<BarberDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<AppointmentModel> _recentAppointments = [];
  Map<String, int> _stats = {
    'total': 0,
    'completed': 0,
    'pending': 0,
    'cancelled': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final barber = await _firestoreService.getBarberByUserId(user.uid);
        if (barber != null) {
          // Subscribe to appointments stream
          _firestoreService.streamBarberAppointments(barber['userId']).listen((appointments) {
            setState(() {
              _recentAppointments = appointments.take(5).toList();
              _stats = {
                'total': appointments.length,
                'completed': appointments.where((a) => a.status == 'completed').length,
                'pending': appointments.where((a) => a.status == 'pending').length,
                'cancelled': appointments.where((a) => a.status == 'cancelled').length,
              };
              _isLoading = false;
            });
          });
        }
      }
    } catch (e) {
      print('Error loading dashboard: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? const CustomLoadingIndicator()
          : RefreshIndicator(
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
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${widget.userData.name}!',
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
              color: Colors.grey[600],
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
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Appointments',
              _stats['totalAppointments'].toString(),
              Icons.calendar_today,
              Colors.blue,
            ),
            _buildStatCard(
              'Today\'s Appointments',
              _stats['todayAppointments'].toString(),
              Icons.today,
              Colors.green,
            ),
            _buildStatCard(
              'Pending Appointments',
              _stats['pendingAppointments'].toString(),
              Icons.pending,
              Colors.orange,
            ),
            _buildStatCard(
              'Completed Appointments',
              _stats['completedAppointments'].toString(),
              Icons.check_circle,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
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
        _recentAppointments.isEmpty
            ? const CustomEmptyState(
                message: 'No recent appointments',
                icon: Icons.calendar_today,
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = _recentAppointments[index];
                  return _buildAppointmentCard(appointment);
                },
              ),
      ],
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            appointment.customerName[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          appointment.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${appointment.serviceName}'),
            Text('Date: ${_formatDate(appointment.date)}'),
            Text('Time: ${appointment.time}'),
          ],
        ),
        trailing: _buildStatusChip(appointment.status),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 