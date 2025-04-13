import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_loading_indicator.dart';
import '../../widgets/custom_empty_state.dart';
import '../../theme/app_theme.dart';

class AppointmentsScreen extends StatefulWidget {
  final UserModel userData;

  const AppointmentsScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Appointments',
      ),
      body: _isLoading
          ? const CustomLoadingIndicator()
          : RefreshIndicator(
              onRefresh: _loadAppointments,
              child: _appointments.isEmpty
                  ? const NoResultsEmptyState(
                      message: 'No appointments found',
                      onClearSearch: null,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            title: Text(
                              appointment['serviceName'] ?? 'Unknown Service',
                              style: AppTheme.heading3,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Date: ${appointment['date']}',
                                  style: AppTheme.bodyText2,
                                ),
                                Text(
                                  'Time: ${appointment['time']}',
                                  style: AppTheme.bodyText2,
                                ),
                                Text(
                                  'Status: ${appointment['status']}',
                                  style: AppTheme.bodyText2.copyWith(
                                    color: _getStatusColor(appointment['status']),
                                  ),
                                ),
                              ],
                            ),
                            trailing: appointment['status'] == 'pending'
                                ? IconButton(
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () => _cancelAppointment(appointment['id']),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
} 