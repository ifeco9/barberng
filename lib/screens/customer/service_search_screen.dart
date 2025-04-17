import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/service_model.dart';
import '../../models/user_model.dart';

class ServiceSearchScreen extends StatefulWidget {
  const ServiceSearchScreen({Key? key}) : super(key: key);

  @override
  State<ServiceSearchScreen> createState() => _ServiceSearchScreenState();
}

class _ServiceSearchScreenState extends State<ServiceSearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search services...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .where('isAvailable', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data!.docs
              .map((doc) => ServiceModel.fromMap({
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  }))
              .where((service) =>
                  _searchQuery.isEmpty ||
                  service.name.toLowerCase().contains(_searchQuery))
              .toList();

          if (services.isEmpty) {
            return const Center(child: Text('No services found'));
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(service.barberId)
                    .get(),
                builder: (context, snapshot) {
                  final barber = snapshot.hasData
                      ? UserModel.fromMap({
                          ...snapshot.data!.data() as Map<String, dynamic>,
                          'id': snapshot.data!.id,
                        })
                      : null;

                  return ListTile(
                    leading: service.imageUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(service.imageUrl!),
                          )
                        : const CircleAvatar(child: Icon(Icons.cut)),
                    title: Text(service.name),
                    subtitle: Text(
                      barber != null ? 'By ${barber.name}' : 'Loading...',
                    ),
                    trailing: Text(
                      '\$${service.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/service-details',
                        arguments: {
                          'service': service,
                          'barber': barber,
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}