import 'package:flutter/material.dart';

class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Timetable")),
      body: const Center(child: Text("Daily timetable layout here")),
    );
  }
}
