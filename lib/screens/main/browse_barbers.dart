import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../barber/barber_profile_screen.dart';

class BrowseBarbersScreen extends StatefulWidget {
  const BrowseBarbersScreen({super.key});

  @override
  State<BrowseBarbersScreen> createState() => _BrowseBarbersScreenState();
}

class _BrowseBarbersScreenState extends State<BrowseBarbersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _barbers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBarbers();
  }

  Future<void> _loadBarbers() async {
    try {
      final barbers = await _firestoreService.getBarberProfiles();
      setState(() {
        _barbers = barbers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading barbers: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  List<UserModel> get _filteredBarbers {
    return _barbers.where((barber) {
      final query = _searchQuery.toLowerCase();
      final name = barber.name.toLowerCase();
      final shop = barber.address?.toLowerCase() ?? '';
      final services = barber.services?.join(' ').toLowerCase() ?? '';
      final bio = barber.bio?.toLowerCase() ?? '';
      return name.contains(query) || 
             shop.contains(query) || 
             services.contains(query) ||
             bio.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Barbers'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search barbers by name, services, or location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBarbers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No barbers found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredBarbers.length,
                    itemBuilder: (context, index) {
                      final barber = _filteredBarbers[index];
                      return _BarberCard(barber: barber);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BarberCard extends StatelessWidget {
  final UserModel barber;

  const _BarberCard({required this.barber});

  @override
  Widget build(BuildContext context) {
    final shopName = barber.address ?? 'Independent Barber';
    final services = barber.services ?? [];
    final rating = barber.rating ?? 0.0;
    final totalReviews = barber.totalReviews ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          backgroundImage: barber.profileImageUrl != null
              ? NetworkImage(barber.profileImageUrl!)
              : null,
          child: barber.profileImageUrl == null
              ? Text(barber.name[0], style: const TextStyle(color: Colors.white))
              : null,
        ),
        title: Text(barber.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shopName),
            if (barber.bio != null) Text(barber.bio!),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('$rating ($totalReviews reviews)'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 5,
              children: services
                  .map((service) => Chip(
                label: Text(service),
                backgroundColor: Colors.green.withOpacity(0.1),
              ))
                  .toList(),
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarberProfileScreen(userData: barber),
          ),
        ),
      ),
    );
  }
}