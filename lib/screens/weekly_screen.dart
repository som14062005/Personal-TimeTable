import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:math' as math;
import '../widgets/slot_box.dart';
import '../models/timetable_slot.dart';
import '../screens/edit_slot_screen.dart';
import '../constants/app_colors.dart';

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

class _WeeklyScreenState extends State<WeeklyScreen> with TickerProviderStateMixin {
  final List<String> days = ['Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  
  final int startHour = 8;
  final int endHour = 18;
  final double hourHeight = 80.0;
  
  late Box<TimetableSlot> timetableBox;
  late AnimationController _fadeController;
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController1; // For day tabs
  late ScrollController _horizontalScrollController2; // For grid
  
  DateTime now = DateTime.now();
  bool _isScrolling = false; // Prevent infinite loop

  @override
  void initState() {
    super.initState();
    timetableBox = Hive.box<TimetableSlot>('timetableBox');
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..forward();
    
    _verticalScrollController = ScrollController();
    _horizontalScrollController1 = ScrollController();
    _horizontalScrollController2 = ScrollController();
    
    // Sync scrolling manually
    _horizontalScrollController1.addListener(() {
      if (!_isScrolling && _horizontalScrollController2.hasClients) {
        _isScrolling = true;
        _horizontalScrollController2.jumpTo(_horizontalScrollController1.offset);
        _isScrolling = false;
      }
    });
    
    _horizontalScrollController2.addListener(() {
      if (!_isScrolling && _horizontalScrollController1.hasClients) {
        _isScrolling = true;
        _horizontalScrollController1.jumpTo(_horizontalScrollController2.offset);
        _isScrolling = false;
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  void _scrollToCurrentTime() {
    if (_verticalScrollController.hasClients) {
      if (now.hour >= startHour && now.hour <= endHour) {
        final offset = (now.hour - startHour) * hourHeight + (now.minute / 60) * hourHeight - 100;
        _verticalScrollController.animateTo(
          offset.clamp(0.0, _verticalScrollController.position.maxScrollExtent),
          duration: Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController1.dispose();
    _horizontalScrollController2.dispose();
    super.dispose();
  }

  List<TimetableSlot> getSlotsForDay(String day) {
    final daySlots = widget.timetableSlots.where((slot) {
      final slotDay = slot.day.toLowerCase();
      final targetDay = day.toLowerCase();
      return slotDay.contains(targetDay.substring(0, 3)) || 
             slotDay == targetDay;
    }).toList();
    
    daySlots.sort((a, b) {
      try {
        final timeA = _parseTimeString(a.startTime ?? a.timeSlot);
        final timeB = _parseTimeString(b.startTime ?? b.timeSlot);
        return timeA.compareTo(timeB);
      } catch (e) {
        return 0;
      }
    });
    
    return daySlots;
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

  double _getSlotTop(String startTime) {
    try {
      final time = _parseTimeString(startTime);
      final hour = time.hour + (time.minute / 60.0);
      return (hour - startHour) * hourHeight;
    } catch (e) {
      return 0;
    }
  }

  double _getSlotHeight(String startTime, String endTime) {
    try {
      if (startTime.contains('-') && startTime == endTime) {
        final parts = startTime.split('-');
        if (parts.length >= 2) {
          final startHour = int.parse(parts[0].trim());
          final endPart = parts[1].trim().split(' ')[0];
          final endHour = int.parse(endPart);
          final duration = (endHour - startHour).abs();
          return duration * hourHeight;
        }
      }
      
      final start = _parseTimeString(startTime);
      final end = _parseTimeString(endTime);
      final duration = end.difference(start).inMinutes / 60.0;
      return duration * hourHeight;
    } catch (e) {
      return hourHeight;
    }
  }

  DateTime _parseTimeString(String time) {
    try {
      final trimmedTime = time.trim();
      
      if (trimmedTime.contains('-')) {
        final parts = trimmedTime.split('-');
        if (parts.length >= 1) {
          final startPart = parts[0].trim();
          final isPM = trimmedTime.toUpperCase().contains('PM');
          final isAM = trimmedTime.toUpperCase().contains('AM');
          
          int hour = int.parse(startPart);
          
          if (isPM && hour != 12) {
            hour += 12;
          }
          if (isAM && hour == 12) {
            hour = 0;
          }
          
          return DateTime(2024, 1, 1, hour, 0);
        }
      }
      
      final parts = trimmedTime.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
      
      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      }
      if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
      
      return DateTime(2024, 1, 1, hour, minute);
    } catch (e) {
      return DateTime(2024, 1, 1, 8, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalHeight = (endHour - startHour) * hourHeight;
    
    return Scaffold(
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
            _buildHeader(isDark),
            _buildDayTabs(isDark),
            Expanded(
              child: _buildTimelineView(isDark, totalHeight),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDaySelector,
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple.shade700, Colors.blue.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      'Weekly Timeline',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayTabs(bool isDark) {
  return Container(
    height: 70,
    margin: EdgeInsets.only(top: 12, bottom: 12),
    child: Row(
      children: [
        // Day tabs - Uses controller 1
        Expanded(
          child: ListView.builder(
            controller: _horizontalScrollController1,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16), // Left and right padding
            itemCount: days.length,
            itemBuilder: (context, index) {
              // Tuesday=2, Wednesday=3, Thursday=4, Friday=5, Saturday=6
              final isToday = now.weekday == index + 2;
              final color = AppColors.subjectColors[index % AppColors.subjectColors.length];
              
              return AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  final delay = index * 0.1;
                  final animValue = Curves.easeOut.transform(
                    (_fadeController.value - delay).clamp(0.0, 1.0) / (1.0 - delay)
                  );
                  
                  return Opacity(
                    opacity: animValue,
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * animValue),
                      child: Container(
                        width: 140,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isToday 
                                ? [color, color.withOpacity(0.7)]
                                : [color.withOpacity(0.3), color.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isToday ? Colors.white.withOpacity(0.4) : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isToday ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ] : null,
                        ),
                        child: Center(
                          child: Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isToday ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
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
        ),
      ],
    ),
  );
}

Widget _buildTimelineView(bool isDark, double totalHeight) {
  return SingleChildScrollView(
    controller: _verticalScrollController,
    physics: BouncingScrollPhysics(),
    child: Expanded(
      child: SingleChildScrollView(
        controller: _horizontalScrollController2,
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16), // Left and right padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(days.length, (dayIndex) {
            return _buildDayColumn(days[dayIndex], dayIndex, isDark, totalHeight);
          }),
        ),
      ),
    ),
  );
}


  Widget _buildTimeLabels(bool isDark, double totalHeight) {
    return SizedBox(
      width: 60,
      height: totalHeight + 40,
      child: Stack(
        children: List.generate(endHour - startHour + 1, (index) {
          final hour = startHour + index;
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          final period = hour >= 12 ? 'PM' : 'AM';
          
          return Positioned(
            top: index * hourHeight,
            child: Container(
              height: hourHeight,
              child: Column(
                children: [
                  Text(
                    '$displayHour',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    period,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn(String day, int dayIndex, bool isDark, double totalHeight) {
    final slots = getSlotsForDay(day);
    
    return GestureDetector(
      onLongPress: () => _showAddSlotDialog(day, dayIndex),
      child: Container(
        width: 140,
        height: totalHeight + 40,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Grid lines
            ...List.generate(endHour - startHour + 1, (index) {
              return Positioned(
                top: index * hourHeight,
                left: 0,
                right: 0,
                child: Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark 
                          ? [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.15)]
                          : [Colors.grey.withOpacity(0.5), Colors.grey.withOpacity(0.3)],
                    ),
                  ),
                ),
              );
            }),
            
            // Current time indicator
            // Tuesday=2, Wednesday=3, Thursday=4, Friday=5, Saturday=6
            if (now.weekday == dayIndex + 2 && now.hour >= startHour && now.hour <= endHour)
              Positioned(
                top: _getSlotTop('${now.hour}:${now.minute}'),
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red, Colors.red.withOpacity(0.3)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Time slots
            ...slots.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;
              
              final startTime = slot.startTime ?? slot.timeSlot;
              final endTime = slot.endTime ?? slot.timeSlot;
              final topPosition = _getSlotTop(startTime);
              
              if (topPosition < 0 || topPosition > totalHeight) {
                return SizedBox.shrink();
              }
              
              return Positioned(
                top: topPosition,
                left: 4,
                right: 4,
                child: AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    final delay = 0.3 + (index * 0.08);
                    final animValue = Curves.easeOut.transform(
                      (_fadeController.value - delay).clamp(0.0, 1.0) / (1.0 - delay)
                    );
                    
                    return Opacity(
                      opacity: animValue,
                      child: Transform.scale(
                        scale: 0.9 + (0.1 * animValue),
                        child: _buildTimelineSlot(slot, _getColorForSubject(slot.subject, index, slot.color), isDark),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  void _showDaySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Select Day', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: days.map((day) => ListTile(
            title: Text(day),
            onTap: () {
              Navigator.pop(context);
              _addNewSlot(day, days.indexOf(day));
            },
          )).toList(),
        ),
      ),
    );
  }
  
  void _showAddSlotDialog(String day, int dayIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Class', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Add a new class for $day?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addNewSlot(day, dayIndex);
            },
            child: Text('Add', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
  
  void _addNewSlot(String day, int dayIndex) async {
    final newSlot = TimetableSlot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: '',
      teacher: '',
      room: '',
      day: day,
      timeSlot: '8:00 AM',
      startTime: '8:00 AM',
      endTime: '9:00 AM',
    );
    
    final result = await Navigator.push<TimetableSlot>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            EditSlotScreen(slot: newSlot),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );

    if (result != null && result.subject.isNotEmpty) {
      await timetableBox.put(result.id, result);
      final updatedList = [...widget.timetableSlots, result];
      widget.onUpdate(updatedList);
      setState(() {});
    }
  }

  Widget _buildTimelineSlot(TimetableSlot slot, Color color, bool isDark) {
    final startTime = slot.startTime ?? slot.timeSlot;
    final endTime = slot.endTime ?? slot.timeSlot;
    final height = _getSlotHeight(startTime, endTime).clamp(60.0, 500.0);
    
    String timeDisplay;
    if (startTime == endTime) {
      timeDisplay = startTime;
    } else {
      timeDisplay = '$startTime-$endTime';
    }
    
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<TimetableSlot>(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                EditSlotScreen(slot: slot),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
        );

        if (result != null) {
          await timetableBox.put(result.id, result);
          final updatedList = [...widget.timetableSlots];
          final index = updatedList.indexWhere((s) => s.id == result.id);
          if (index >= 0) {
            if (result.subject.isEmpty) {
              updatedList.removeAt(index);
              await timetableBox.delete(result.id);
            } else {
              updatedList[index] = result;
            }
          } else if (result.subject.isNotEmpty) {
            updatedList.add(result);
          }
          widget.onUpdate(updatedList);
          setState(() {});
        }
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  slot.subject.isNotEmpty ? slot.subject : 'Untitled',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (slot.teacher.isNotEmpty) ...[
                  SizedBox(height: 3),
                  Text(
                    slot.teacher,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 9, color: Colors.white),
                      SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          timeDisplay,
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (slot.room.isNotEmpty) ...[
                  SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 9, color: Colors.white.withOpacity(0.9)),
                      SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          slot.room,
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
