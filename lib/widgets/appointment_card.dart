import 'package:flutter/material.dart';
import '../models/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final Function(String)? onStatusChange;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    this.onTap,
    this.onStatusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMM dd, yyyy HH:mm').format(appointment.dateTime),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Status: ${appointment.status}'),
              if (onStatusChange != null && appointment.status == 'pending')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => onStatusChange!('accepted'),
                      child: const Text('Accept'),
                    ),
                    TextButton(
                      onPressed: () => onStatusChange!('rejected'),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}