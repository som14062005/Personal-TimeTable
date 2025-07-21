import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/models/timetable_slot.dart';
import '/screens/weekly_screen.dart';
import '/screens/daily_screen.dart';
import '/screens/friend_screen.dart'; // ✅ Added import

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  List<TimetableSlot> timetableSlots = [];

  @override
  void initState() {
    super.initState();
    loadDataFromHive();
  }

  void loadDataFromHive() async {
    final box = await Hive.openBox<TimetableSlot>('timetableBox');
    setState(() {
      timetableSlots = box.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEEF0),
      appBar: AppBar(
        title: const Text('My Timetable'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _buildCircularButton(
                label: 'Weekly View',
                icon: Icons.calendar_month,
                gradientColors: [Colors.purple, Colors.deepPurple],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WeeklyScreen(
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
              ),
              _buildCircularButton(
                label: 'Daily View',
                icon: Icons.today,
                gradientColors: [Colors.blueAccent, Colors.indigo],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DailyScreen(timetableSlots: timetableSlots),
                    ),
                  );
                },
              ),
              _buildCircularButton( // ✅ Fixed name
                label: 'Friends TT',
                icon: Icons.people,
                gradientColors: [Colors.teal, Colors.green],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FriendScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
