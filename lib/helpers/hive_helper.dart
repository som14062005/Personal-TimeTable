import 'package:hive/hive.dart';
import '../models/timetable_slot.dart';

class HiveHelper {
  static Future<void> saveSlot(TimetableSlot slot) async {
    final box = Hive.box<TimetableSlot>('timetableBox');
    final key = '${slot.day}_${slot.timeSlot}';
    await box.put(key, slot);
  }

  static TimetableSlot? getSlot(String day, String timeSlot) {
    final box = Hive.box<TimetableSlot>('timetableBox');
    final key = '${day}_$timeSlot';
    return box.get(key);
  }

  static Map<String, TimetableSlot> getAllSlots() {
    final box = Hive.box<TimetableSlot>('timetableBox');
    return box.toMap().map((key, value) => MapEntry(key as String, value));
  }
}
