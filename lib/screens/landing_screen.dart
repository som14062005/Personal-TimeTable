import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math' as math;
import '/models/timetable_slot.dart';
import '/models/friend_model.dart';
import '/screens/weekly_screen.dart';
import '/screens/daily_screen.dart';
import '/screens/friend_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  List<TimetableSlot> timetableSlots = [];
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    loadDataFromHive();

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void loadDataFromHive() async {
    final box = await Hive.openBox<TimetableSlot>('timetableBox');
    setState(() {
      timetableSlots = box.values.toList();
    });
  }

  Future<void> _clearAllData() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.red, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Clear All Data?',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            _buildDeleteItem('All timetable slots'),
            _buildDeleteItem('All friends and their timetables'),
            _buildDeleteItem('All saved data'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Delete All',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      // Clear timetable box
      final timetableBox = Hive.box<TimetableSlot>('timetableBox');
      await timetableBox.clear();

      // Clear friends box
      final friendsBox = Hive.box<FriendModel>('friendsBox');
      await friendsBox.clear();

      setState(() {
        timetableSlots = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('All data cleared successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

Widget _buildDeleteItem(String text) {
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(Icons.close, color: Colors.red, size: 18),
        SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F1E),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  _buildTopBar(),
                  SizedBox(height: 20),
                  _buildHeader(),
                  SizedBox(height: 60),
                  Expanded(
                    child: _buildButtonGrid(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FadeTransition(
            opacity: _fadeController,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _scaleController,
                curve: Curves.elasticOut,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade700],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _clearAllData,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_forever, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Clear All Data',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100 + (50 * math.sin(_rotateController.value * 2 * math.pi)),
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150 + (30 * math.cos(_rotateController.value * 2 * math.pi)),
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 200 + (40 * math.sin(_rotateController.value * 3 * math.pi)),
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.teal.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeController,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _scaleController,
          curve: Curves.elasticOut,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple.shade300],
                ),
              ),
              child: Icon(
                Icons.calendar_month,
                size: 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'My Timetable',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Center(
      child: Wrap(
        spacing: 40,
        runSpacing: 40,
        alignment: WrapAlignment.center,
        children: [
          _buildAnimatedButton(
            label: 'Weekly View',
            icon: Icons.calendar_month,
            gradientColors: [Colors.purple, Colors.deepPurple],
            delay: 0.0,
            onTap: () {
              Navigator.push(
                context,
                _createRoute(
                  WeeklyScreen(
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
          _buildAnimatedButton(
            label: 'Daily View',
            icon: Icons.today,
            gradientColors: [Colors.blueAccent, Colors.indigo],
            delay: 0.15,
            onTap: () {
              Navigator.push(
                context,
                _createRoute(DailyScreen(timetableSlots: timetableSlots)),
              );
            },
          ),
          _buildAnimatedButton(
            label: 'Friends TT',
            icon: Icons.people,
            gradientColors: [Colors.teal, Colors.green],
            delay: 0.3,
            onTap: () {
              Navigator.push(
                context,
                _createRoute(const FriendScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required double delay,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _floatController]),
      builder: (context, child) {
        final progress = (_scaleController.value - delay).clamp(0.0, 1.0);
        final scaleValue = Curves.elasticOut.transform(progress);
        final floatOffset = math.sin((_floatController.value + delay) * 2 * math.pi) * 8;
        final opacity = scaleValue.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.scale(
            scale: (0.5 + (0.5 * scaleValue)).clamp(0.0, 1.5),
            child: Opacity(
              opacity: opacity,
              child: GestureDetector(
                onTap: onTap,
                child: Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 400),
    );
  }
}
