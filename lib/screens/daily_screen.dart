import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/timetable_slot.dart';
import '../constants/app_colors.dart';
import 'package:intl/intl.dart';

class DailyScreen extends StatefulWidget {
  final List<TimetableSlot> timetableSlots;

  const DailyScreen({super.key, required this.timetableSlots});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> with TickerProviderStateMixin {
  late String selectedDay;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    selectedDay = _getWeekday(DateTime.now().weekday);
    
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..forward();
    
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onDayChanged() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Set status bar color to match background
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
    
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
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Color(0xFF0F0F1E), Color(0xFF1A1A2E)]
                : [Color(0xFFF0F4FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            _buildHeader(isDark),
            SizedBox(height: 20),
            _buildDaySelector(isDark),
            SizedBox(height: 20),
            Expanded(
              child: filteredSlots.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildClassList(filteredSlots, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple.shade700, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Schedule',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  DateFormat('MMMM d, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.calendar_today, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(bool isDark) {
    final days = ['Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = selectedDay == day;
          final color = AppColors.subjectColors[index % AppColors.subjectColors.length];
          
          return AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeController.value,
                child: Transform.scale(
                  scale: 0.8 + (0.2 * _fadeController.value),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day;
                        _onDayChanged();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [color, color.withOpacity(0.7)],
                              )
                            : null,
                        color: isSelected ? null : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          day.substring(0, 3),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildClassList(List<TimetableSlot> slots, bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      physics: BouncingScrollPhysics(),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final color = _getColorForSubject(slot.subject, index, slot.color);
        
        return AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animValue = Curves.easeOut.transform(
              (_slideController.value - delay).clamp(0.0, 1.0) / (1.0 - delay)
            );
            
            return Opacity(
              opacity: animValue,
              child: Transform.translate(
                offset: Offset(0, 50 * (1 - animValue)),
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Time indicator
                          Container(
                            width: 70,
                            child: Column(
                              children: [
                                Icon(Icons.access_time, color: Colors.white, size: 24),
                                SizedBox(height: 8),
                                Text(
                                  slot.timeSlot,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // Vertical divider
                          Container(
                            width: 2,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.5),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Class details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slot.subject,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.white.withOpacity(0.9), size: 16),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        slot.teacher,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.white.withOpacity(0.9), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      slot.room,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Arrow indicator
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 20),
          Text(
            'No classes scheduled',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Enjoy your free day!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForSubject(String subject, int index, String? colorHex) {
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        return _hexToColor(colorHex);
      } catch (e) {
        // Fall back to hash-based color
      }
    }
    
    if (subject.isEmpty) return Colors.grey.shade300;
    final colorIndex = subject.hashCode % AppColors.subjectColors.length;
    return AppColors.subjectColors[colorIndex.abs()];
  }
  
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // FIXED TIME PARSING - handles range format like "8-9 AM"
  DateTime? extractStartTime(String timeSlot) {
    try {
      // Clean Unicode spaces
      timeSlot = timeSlot.replaceAll(RegExp(r'[\u00A0\u202F\s]+'), ' ').trim();

      // Split by dash
      final parts = timeSlot.split('-');
      if (parts.length != 2) return null;

      final startHourStr = parts[0].trim(); // e.g., "8"
      final endPart = parts[1].trim().toUpperCase(); // e.g., "9 AM"

      // Extract AM/PM
      final isPM = endPart.contains('PM');
      final isAM = endPart.contains('AM');
      
      if (!isPM && !isAM) return null;

      // Parse start hour
      int startHour = int.parse(startHourStr);
      
      // Convert to 24-hour format
      if (isPM && startHour != 12) {
        startHour += 12;
      }
      if (isAM && startHour == 12) {
        startHour = 0;
      }

      // Create DateTime with parsed hour
      return DateTime(2024, 1, 1, startHour, 0);
    } catch (e) {
      debugPrint("Failed to parse time: '$timeSlot' => $e");
      return null;
    }
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
        return 'Tuesday';
    }
  }
}
