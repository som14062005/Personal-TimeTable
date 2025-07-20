import 'package:flutter/material.dart';
import '../models/timetable_slot.dart';
import 'screens/weekly_screen.dart';
import 'screens/daily_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TimetableSlot> timetableSlots = []; // Shared data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Timetable App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeeklyScreen(
                      timetableSlots: timetableSlots,
                      onUpdate: (updatedList) {
                        setState(() {
                          timetableSlots = updatedList;
                        });
                      },
                    ),
                  ),
                );
              },
              child: const Text("Weekly View"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DailyScreen(
                      timetableSlots: timetableSlots,
                    ),
                  ),
                );
              },
              child: const Text("Daily View"),
            ),
          ],
        ),
      ),
    );
  }
}
