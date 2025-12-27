import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/timetable_slot.dart';
import 'models/friend_model.dart';
import 'screens/landing_screen.dart'; // ✅ Changed import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TimetableSlotAdapter());
  Hive.registerAdapter(FriendModelAdapter());

  await Hive.openBox<TimetableSlot>('timetableBox');
  await Hive.openBox<FriendModel>('friendsBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kodambakkam Coders',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark, // Optional: dark theme
      ),
      home: const LandingScreen(), // ✅ Changed to LandingScreen
    );
  }
}
