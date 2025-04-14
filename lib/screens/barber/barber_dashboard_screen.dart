import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/barber_service.dart';
import '../../services/appointment_service.dart';
import '../../models/appointment.dart';
import '../../models/user_model.dart';
import '../../widgets/statistics_card.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/quick_action_button.dart';

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
  final BarberService _barberService = BarberService();
  final AppointmentService _appointmentService = AppointmentService();
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final stats = await _barberService.getBarberStatistics(
        widget.userData.uid,
        startOfMonth,
        endOfMonth,
      );

      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Text(
                      'Welcome, ${widget.userData.name}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // Statistics Section
                    Text(
                      'Monthly Statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatisticsCard(
                            title: 'Appointments',
                            value: _statistics['totalAppointments']?.toString() ?? '0',
                            icon: Icons.calendar_today,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatisticsCard(
                            title: 'Earnings',
                            value: '\$${_statistics['totalEarnings']?.toStringAsFixed(2) ?? '0.00'}',
                            icon: Icons.attach_money,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatisticsCard(
                            title: 'Completed',
                            value: _statistics['completedAppointments']?.toString() ?? '0',
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatisticsCard(
                            title: 'Cancelled',
                            value: _statistics['cancelledAppointments']?.toString() ?? '0',
                            icon: Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        QuickActionButton(
                          icon: Icons.add_circle,
                          label: 'New Service',
                          onTap: () {
                            // Navigate to add service screen
                          },
                        ),
                        QuickActionButton(
                          icon: Icons.inventory,
                          label: 'Products',
                          onTap: () {
                            // Navigate to products screen
                          },
                        ),
                        QuickActionButton(
                          icon: Icons.schedule,
                          label: 'Schedule',
                          onTap: () {
                            // Navigate to schedule screen
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Today's Appointments
                    Text(
                      "Today's Appointments",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<Appointment>>(
                      stream: _appointmentService.getBarberAppointments(widget.userData.uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final appointments = snapshot.data!
                            .where((appointment) =>
                                appointment.dateTime.day == DateTime.now().day &&
                                appointment.dateTime.month == DateTime.now().month &&
                                appointment.dateTime.year == DateTime.now().year)
                            .toList();

                        if (appointments.isEmpty) {
                          return const Center(
                            child: Text('No appointments for today'),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            return AppointmentCard(
                              appointment: appointments[index],
                              onStatusChanged: (status) async {
                                await _appointmentService.updateAppointmentStatus(
                                  appointments[index].id,
                                  status,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 