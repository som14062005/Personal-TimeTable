import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widgets/slot_box.dart';
import '../models/timetable_slot.dart';
import '../screens/edit_slot_screen.dart';

class WeeklyScreen extends StatefulWidget {
  final List<TimetableSlot> timetableSlots;
  final Function(List<TimetableSlot>) onUpdate;

  const WeeklyScreen({
    super.key,
    required this.timetableSlots,
    required this.onUpdate,
  });

  @override
  _WeeklyScreenState createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<String> timeSlots = [
    '8-9 AM', '9-10 AM', '10-11 AM', '11-12 PM', '12-1 PM',
    '1-2 PM', '2-3 PM', '3-4 PM', '4-5 PM'
  ];

  late Box<TimetableSlot> timetableBox;

  @override
  void initState() {
    super.initState();
    timetableBox = Hive.box<TimetableSlot>('timetableBox');
  }

  TimetableSlot getSlot(String day, String timeSlot) {
    String key = '$day-$timeSlot';
    return timetableBox.get(key) ?? TimetableSlot(
      id: key,
      subject: '',
      teacher: '',
      room: '',
      day: day,
      timeSlot: timeSlot,
    );
  }

  Future<void> _editSlot(String day, String timeSlot) async {
    final currentSlot = getSlot(day, timeSlot);

    final result = await Navigator.push<TimetableSlot>(
      context,
      MaterialPageRoute(
        builder: (_) => EditSlotScreen(slot: currentSlot),
      ),
    );

    if (result != null) {
      await timetableBox.put(result.id, result);

      // Update local list too
      final updatedList = [...widget.timetableSlots];
      final index = updatedList.indexWhere((s) => s.id == result.id);
      if (index >= 0) {
        updatedList[index] = result;
      } else {
        updatedList.add(result);
      }

      widget.onUpdate(updatedList);

      setState(() {}); // Refresh UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Timetable')),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              // Header row for days
              Row(
                children: [
                  const SizedBox(width: 80, height: 40),
                  ...days.map((day) => Container(
                        width: 120,
                        height: 40,
                        alignment: Alignment.center,
                        color: Colors.deepPurple[100],
                        child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                      )),
                ],
              ),
              // Rows for time slots
              ...timeSlots.map((slot) {
                return Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      color: Colors.deepPurple[50],
                      child: Text(slot),
                    ),
                    ...days.map((day) {
                      final slotData = getSlot(day, slot);
                      return SlotBox(
                        subject: slotData.subject,
                        teacher: slotData.teacher,
                        room: slotData.room,
                        onEdit: () => _editSlot(day, slot),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
