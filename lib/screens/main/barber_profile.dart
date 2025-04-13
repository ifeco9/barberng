import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/user_model.dart';

class BarberProfileScreen extends StatefulWidget {
  final UserModel barber;

  const BarberProfileScreen({super.key, required this.barber});

  @override
  State<BarberProfileScreen> createState() => _BarberProfileScreenState();
}

class _BarberProfileScreenState extends State<BarberProfileScreen> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopName = widget.barber.additionalData?['shopName'] ?? 'Independent';
    final address = widget.barber.additionalData?['address'] ?? 'Address not provided';
    final experience = widget.barber.additionalData?['experience'] ?? '0';
    final services = (widget.barber.additionalData?['services'] as List<dynamic>?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(shopName),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildSectionTitle('About'),
            Text('Experience: $experience years'),
            Text(address),
            const SizedBox(height: 20),
            _buildSectionTitle('Services'),
            Wrap(
              spacing: 8,
              children: services
                  .map((service) => Chip(
                label: Text(service),
                backgroundColor: Colors.green.withOpacity(0.1),
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Location'),
            _currentPosition != null
                ? _buildMapPreview()
                : const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.green,
          child: Text(
            widget.barber.name[0],
            style: const TextStyle(fontSize: 32, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.barber.name, style: const TextStyle(fontSize: 24)),
            Text(widget.barber.phoneNumber ?? ''),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: Icon(Icons.map, size: 50)),
    );
  }
}