import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleManagementScreen extends StatefulWidget {
  final UserModel barber;

  const ScheduleManagementScreen({
    Key? key,
    required this.barber,
  }) : super(key: key);

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  Map<String, List<TimeSlot>> _availableSlots = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('barber_schedules')
          .doc(widget.barber.id)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _availableSlots = Map.fromEntries(
            data.entries.map(
              (e) => MapEntry(
                e.key,
                (e.value as List).map((slot) => TimeSlot.fromMap(slot)).toList(),
              ),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading schedule: $e')),
        );
      }
    }
  }

  Future<void> _updateDaySchedule(String dayKey, List<TimeSlot> slots) async {
    try {
      await FirebaseFirestore.instance
          .collection('barber_schedules')
          .doc(widget.barber.id)
          .set({dayKey: slots.map((s) => s.toMap()).toList()}, SetOptions(merge: true));

      setState(() {
        _availableSlots[dayKey] = slots;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating schedule: $e')),
        );
      }
    }
  }

  void _showTimeSlotDialog(String dayKey) {
    showDialog(
      context: context,
      builder: (context) => TimeSlotDialog(
        initialSlots: _availableSlots[dayKey] ?? [],
        onSave: (slots) => _updateDaySchedule(dayKey, slots),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Schedule'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.week,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = _selectedDay.add(Duration(days: index));
                final dayKey = day.toIso8601String().split('T')[0];
                final slots = _availableSlots[dayKey] ?? [];

                return ListTile(
                  title: Text(
                    '${_getDayName(day.weekday)} - ${day.day}/${day.month}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    slots.isEmpty
                        ? 'No slots configured'
                        : '${slots.length} time slots available',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showTimeSlotDialog(dayKey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}

class TimeSlot {
  final TimeOfDay start;
  final TimeOfDay end;
  final int maxAppointments;

  TimeSlot({
    required this.start,
    required this.end,
    this.maxAppointments = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'start': '${start.hour}:${start.minute}',
      'end': '${end.hour}:${end.minute}',
      'maxAppointments': maxAppointments,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    final startParts = (map['start'] as String).split(':');
    final endParts = (map['end'] as String).split(':');
    return TimeSlot(
      start: TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      ),
      end: TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      ),
      maxAppointments: map['maxAppointments'] ?? 1,
    );
  }
}

class TimeSlotDialog extends StatefulWidget {
  final List<TimeSlot> initialSlots;
  final Function(List<TimeSlot>) onSave;

  const TimeSlotDialog({
    Key? key,
    required this.initialSlots,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<TimeSlotDialog> {
  late List<TimeSlot> _slots;

  @override
  void initState() {
    super.initState();
    _slots = List.from(widget.initialSlots);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Time Slots'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            ..._slots.map((slot) => _buildSlotTile(slot)).toList(),
            TextButton(
              onPressed: _addSlot,
              child: const Text('Add Slot'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(_slots);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildSlotTile(TimeSlot slot) {
    return ListTile(
      title: Text('${slot.start.format(context)} - ${slot.end.format(context)}'),
      subtitle: Text('Max appointments: ${slot.maxAppointments}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          setState(() {
            _slots.remove(slot);
          });
        },
      ),
    );
  }

  Future<void> _addSlot() async {
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (start == null) return;

    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: start.hour + 1,
        minute: start.minute,
      ),
    );
    if (end == null) return;

    setState(() {
      _slots.add(TimeSlot(start: start, end: end));
    });
  }
}