import 'package:flutter/material.dart';
import '../models/timetable_slot.dart';
import 'package:intl/intl.dart';

class DailyScreen extends StatefulWidget {
  final List<TimetableSlot> timetableSlots;

  const DailyScreen({super.key, required this.timetableSlots});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  late String selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = _getWeekday(DateTime.now().weekday);
  }

  @override
  Widget build(BuildContext context) {
    final filteredSlots = widget.timetableSlots
        .where((slot) => slot.day.toLowerCase() == selectedDay.toLowerCase())
        .toList()
      ..sort((a, b) {
        final aTime = extractStartTime(a.timeSlot);
        final bTime = extractStartTime(b.timeSlot);
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Timetable'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildDaySelector(),
          const SizedBox(height: 10),
          Expanded(
            child: filteredSlots.isEmpty
                ? const Center(child: Text('No classes today.'))
                : ListView.builder(
                    itemCount: filteredSlots.length,
                    itemBuilder: (context, index) {
                      final slot = filteredSlots[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            slot.subject,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Teacher: ${slot.teacher}'),
                              Text('Room: ${slot.room}'),
                              Text('Time: ${slot.timeSlot}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// ✅ Fixed time parsing with invisible Unicode removal
  DateTime? extractStartTime(String timeSlot) {
    try {
      // Remove non-breaking and narrow no-break spaces
      timeSlot = timeSlot.replaceAll(RegExp(r'[\u00A0\u202F]'), ' ').trim();

      // Split like "10-11 AM"
      final parts = timeSlot.split('-');
      if (parts.length != 2) return null;

      String start = parts[0].trim(); // e.g. "10"
      String end = parts[1].trim();   // e.g. "11 AM"

      // Extract AM/PM from the end part
      String meridiem = end.toUpperCase().contains("PM") ? "PM" : "AM";

      // Construct start time in format like "10:00 AM"
      String formattedStart = "$start:00 $meridiem";

      // Parse with DateFormat.jm (e.g. "10:00 AM")
      return DateFormat.jm().parse(formattedStart);
    } catch (e) {
      debugPrint("Failed to parse time: '$timeSlot' => $e");
      return null;
    }
  }

  Widget _buildDaySelector() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: days.map((day) {
          final isSelected = selectedDay == day;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDay = day;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : Colors.grey,
              ),
              child: Text(
                day,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
