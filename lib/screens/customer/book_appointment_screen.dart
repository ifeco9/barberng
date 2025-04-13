import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/appointment_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_loading_indicator.dart';

class BookAppointmentScreen extends StatefulWidget {
  final UserModel barber;

  const BookAppointmentScreen({
    Key? key,
    required this.barber,
  }) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedService;
  bool _isLoading = false;
  List<String> _availableServices = [];
  List<String> _availableTimes = [];

  @override
  void initState() {
    super.initState();
    _loadBarberServices();
  }

  Future<void> _loadBarberServices() async {
    setState(() => _isLoading = true);
    try {
      final services = widget.barber.services ?? [];
      setState(() {
        _availableServices = services;
        if (services.isNotEmpty) {
          _selectedService = services.first;
        }
      });
    } catch (e) {
      _showError('Error loading services: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loadAvailableTimes();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _loadAvailableTimes() async {
    if (_selectedDate == null) return;

    setState(() => _isLoading = true);
    try {
      // Get working hours for the selected day
      final dayOfWeek = _selectedDate!.weekday;
      final workingHours = widget.barber.workingHours?[_getDayName(dayOfWeek)];
      
      if (workingHours != null) {
        final startTime = workingHours['start'];
        final endTime = workingHours['end'];
        
        // Generate available time slots
        final times = _generateTimeSlots(startTime, endTime);
        setState(() {
          _availableTimes = times;
          if (times.isNotEmpty) {
            _selectedTime = TimeOfDay(
              hour: int.parse(times.first.split(':')[0]),
              minute: int.parse(times.first.split(':')[1]),
            );
          }
        });
      }
    } catch (e) {
      _showError('Error loading available times: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<String> _generateTimeSlots(String start, String end) {
    final List<String> slots = [];
    final startHour = int.parse(start.split(':')[0]);
    final startMinute = int.parse(start.split(':')[1]);
    final endHour = int.parse(end.split(':')[0]);
    final endMinute = int.parse(end.split(':')[1]);

    var currentHour = startHour;
    var currentMinute = startMinute;

    while (currentHour < endHour || (currentHour == endHour && currentMinute <= endMinute)) {
      slots.add('${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}');
      currentMinute += 30;
      if (currentMinute >= 60) {
        currentHour += 1;
        currentMinute = 0;
      }
    }

    return slots;
  }

  String _getDayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day - 1];
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null || _selectedService == null) {
      _showError('Please select date, time, and service');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      final appointment = AppointmentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.uid,
        barberId: widget.barber.id,
        barberName: widget.barber.name,
        customerName: currentUser.displayName ?? 'Customer',
        serviceName: _selectedService!,
        date: _selectedDate!,
        time: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        service: _selectedService!,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _firestoreService.createAppointment(appointment);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Error booking appointment: $e');
    } finally {
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Book Appointment',
      ),
      body: _isLoading
          ? const CustomLoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Barber: ${widget.barber.name}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            if (widget.barber.rating != null)
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.barber.rating!.toStringAsFixed(1),
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Service',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedService,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: _availableServices.map((service) {
                                return DropdownMenuItem(
                                  value: service,
                                  child: Text(service),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedService = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a service';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Date & Time',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              title: const Text('Date'),
                              subtitle: Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : 'Select a date',
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => _selectDate(context),
                            ),
                            if (_selectedDate != null) ...[
                              const SizedBox(height: 8),
                              ListTile(
                                title: const Text('Time'),
                                subtitle: Text(
                                  _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : 'Select a time',
                                ),
                                trailing: const Icon(Icons.access_time),
                                onTap: () => _selectTime(context),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _bookAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Book Appointment',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 