import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment.dart';
import '../../models/service_model.dart';
import '../../models/user_model.dart';
import '../../services/appointment_service.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;
  final bool isBarber;

  const AppointmentDetailsScreen({
    Key? key,
    required this.appointment,
    required this.isBarber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('services')
            .doc(appointment.serviceId)
            .get(),
        builder: (context, serviceSnapshot) {
          if (serviceSnapshot.hasError) {
            return Center(child: Text('Error: ${serviceSnapshot.error}'));
          }

          if (!serviceSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final service = ServiceModel.fromMap({
            ...serviceSnapshot.data!.data() as Map<String, dynamic>,
            'id': serviceSnapshot.data!.id,
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusCard(),
                const SizedBox(height: 16),
                _buildServiceDetails(service),
                const SizedBox(height: 16),
                _buildUserDetails(isBarber ? appointment.customerId : appointment.barberId, isBarber),
                const SizedBox(height: 16),
                _buildAppointmentDetails(),
                if (appointment.status == 'pending' && isBarber)
                  _buildActionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Status: ${appointment.status.toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM dd, yyyy - hh:mm a').format(appointment.dateTime),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetails(ServiceModel service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Service: ${service.name}'),
            Text('Price: \$${service.price}'),
            Text('Duration: ${service.durationMinutes} minutes'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetails(String userId, bool isCustomer) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final user = UserModel.fromMap({
          ...snapshot.data!.data() as Map<String, dynamic>,
          'id': snapshot.data!.id,
        });

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCustomer ? 'Customer Details' : 'Barber Details',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Name: ${user.name}'),
                Text('Phone: ${user.phoneNumber}'),
                if (!isCustomer) Text('Address: ${user.address}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(appointment.notes.isEmpty ? 'No notes' : appointment.notes),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _updateStatus(context, 'accepted'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _updateStatus(context, 'rejected'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(BuildContext context, String status) async {
    try {
      final success = await AppointmentService()
          .updateAppointmentStatus(appointment.id, status);
      if (success && context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }
}