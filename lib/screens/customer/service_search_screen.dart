import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_loading_indicator.dart';
import '../../widgets/custom_empty_state.dart';
import '../../theme/app_theme.dart';

class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String barberId;
  final String barberName;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.barberId,
    required this.barberName,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      barberId: map['barberId'] ?? '',
      barberName: map['barberName'] ?? '',
    );
  }
}

class ServiceSearchScreen extends StatefulWidget {
  final UserModel userData;

  const ServiceSearchScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<ServiceSearchScreen> createState() => _ServiceSearchScreenState();
}

class _ServiceSearchScreenState extends State<ServiceSearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final services = await _firestoreService.getAllServices();
      if (mounted) {
        setState(() {
          _services = services;
          _filteredServices = services;
        });
      }
    } catch (e) {
      print('Error loading services: $e');
      if (mounted) {
        _showError('Error loading services. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterServices(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredServices = _services;
      } else {
        _filteredServices = _services.where((service) {
          final name = service['name'].toString().toLowerCase();
          final description = service['description']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || description.contains(searchQuery);
        }).toList();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Search Services',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterServices,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const CustomLoadingIndicator()
                : _filteredServices.isEmpty
                    ? const NoResultsEmptyState(
                        message: 'No services found',
                        onClearSearch: null,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = _filteredServices[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              title: Text(
                                service['name'] ?? 'Unknown Service',
                                style: AppTheme.heading3,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    service['description'] ?? 'No description available',
                                    style: AppTheme.bodyText2,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₦${service['price']?.toStringAsFixed(2) ?? '0.00'}',
                                    style: AppTheme.heading3.copyWith(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Navigate to service details or booking screen
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 