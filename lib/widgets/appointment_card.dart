import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final Function(String) onStatusChanged;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.onStatusChanged,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment.customerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Chip(
                  label: Text(
                    appointment.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(appointment.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Service: ${appointment.serviceName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Time: ${_formatDateTime(appointment.dateTime)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Price: \$${appointment.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (appointment.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${appointment.notes}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (appointment.status.toLowerCase() == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => onStatusChanged('rejected'),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => onStatusChanged('accepted'),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ],
            if (appointment.status.toLowerCase() == 'accepted') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => onStatusChanged('completed'),
                    child: const Text('Complete'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 