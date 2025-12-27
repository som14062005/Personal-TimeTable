import 'package:hive/hive.dart';

part 'timetable_slot.g.dart';

@HiveType(typeId: 0)
class TimetableSlot extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subject;

  @HiveField(2)
  String teacher;

  @HiveField(3)
  String room;

  @HiveField(4)
  String day;

  @HiveField(5)
  String timeSlot;
  
  @HiveField(6)
  String? startTime; // NEW: e.g., "1:20 PM"
  
  @HiveField(7)
  String? endTime;   // NEW: e.g., "3:15 PM"
  
  @HiveField(8)
  String? color;     // NEW: Store hex color

  TimetableSlot({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.day,
    required this.timeSlot,
    this.startTime,
    this.endTime,
    this.color,
  });
  
  // Helper to get duration in minutes
  int get durationMinutes {
    if (startTime == null || endTime == null) return 60;
    
    try {
      final start = _parseTime(startTime!);
      final end = _parseTime(endTime!);
      return end.difference(start).inMinutes;
    } catch (e) {
      return 60;
    }
  }
  
  DateTime _parseTime(String time) {
    // Parse "1:20 PM" format
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    
    if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour != 12) {
      hour += 12;
    }
    if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
      hour = 0;
    }
    
    return DateTime(2024, 1, 1, hour, minute);
  }
}
