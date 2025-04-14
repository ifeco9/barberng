import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../models/user_model.dart';
import '../../services/appointment_service.dart';

class AppointmentsScreen extends StatelessWidget {
  final AppointmentService _appointmentService = AppointmentService();
  final UserModel userData;

  AppointmentsScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: _appointmentService.getUserAppointments(userData.uid),
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

          final appointments = snapshot.data!;

          if (appointments.isEmpty) {
            return const Center(
              child: Text('No appointments found'),
            );
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text(
                    'Appointment for ${appointment.serviceName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time: ${_formatDateTime(appointment.dateTime)}'),
                      Text('Service: ${appointment.serviceName}'),
                      Text('Status: ${appointment.status.toUpperCase()}'),
                      Text('Price: \$${appointment.price.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: _getStatusChip(appointment.status),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 