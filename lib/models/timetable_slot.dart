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

  TimetableSlot({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.day,
    required this.timeSlot,
  });
}
