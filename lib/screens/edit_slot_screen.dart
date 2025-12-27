import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../models/timetable_slot.dart';
import '../constants/app_colors.dart';


class EditSlotScreen extends StatefulWidget {
  final TimetableSlot slot;


  const EditSlotScreen({super.key, required this.slot});


  @override
  _EditSlotScreenState createState() => _EditSlotScreenState();
}


class _EditSlotScreenState extends State<EditSlotScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late TextEditingController _teacherController;
  late TextEditingController _roomController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  
  late AnimationController _controller;
  Color selectedColor = Colors.deepPurple;
  
  final FocusNode _subjectFocus = FocusNode();
  final FocusNode _teacherFocus = FocusNode();
  final FocusNode _roomFocus = FocusNode();


  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.slot.subject);
    _teacherController = TextEditingController(text: widget.slot.teacher);
    _roomController = TextEditingController(text: widget.slot.room);
    _startTimeController = TextEditingController(text: widget.slot.startTime ?? '8:00 AM');
    _endTimeController = TextEditingController(text: widget.slot.endTime ?? '9:00 AM');
    
    // Get color from subject
    if (widget.slot.subject.isNotEmpty) {
      final index = widget.slot.subject.hashCode % AppColors.subjectColors.length;
      selectedColor = AppColors.subjectColors[index.abs()];
    }
    
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..forward();
  }


  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _subjectFocus.dispose();
    _teacherFocus.dispose();
    _roomFocus.dispose();
    _controller.dispose();
    super.dispose();
  }


  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: selectedColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final hour = picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final timeString = '${hour == 0 ? 12 : hour}:$minute $period';
      
      setState(() {
        if (isStartTime) {
          _startTimeController.text = timeString;
        } else {
          _endTimeController.text = timeString;
        }
      });
    }
  }


  void _save() {
    if (_formKey.currentState!.validate()) {
      final updatedSlot = TimetableSlot(
        id: widget.slot.id,
        subject: _subjectController.text,
        teacher: _teacherController.text,
        room: _roomController.text,
        day: widget.slot.day,
        timeSlot: widget.slot.timeSlot,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        color: '#${selectedColor.value.toRadixString(16).substring(2)}',
      );
      
      // Success animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildSuccessDialog(),
      );
      
      Future.delayed(Duration(milliseconds: 1500), () {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context, updatedSlot); // Return result
      });
    }
  }


  void _delete() {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteDialog(),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Color(0xFF0F0F1E), Color(0xFF1A1A2E)]
                : [Color(0xFFF0F4FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubjectField(isDark).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                          SizedBox(height: 20),
                          _buildTeacherField(isDark).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
                          SizedBox(height: 20),
                          _buildRoomField(isDark).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
                          SizedBox(height: 20),
                          _buildTimeFields(isDark).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),
                          SizedBox(height: 30),
                          _buildColorPicker(isDark).animate().fadeIn(duration: 300.ms, delay: 500.ms).slideY(begin: 0.2, end: 0),
                          SizedBox(height: 40),
                          _buildActionButtons(isDark).animate().fadeIn(duration: 300.ms, delay: 600.ms).scale(begin: Offset(0.8, 0.8)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [selectedColor, selectedColor.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: selectedColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
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
                  widget.slot.subject.isEmpty ? 'New Class' : 'Edit Class',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.slot.day} • ${widget.slot.timeSlot}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (widget.slot.subject.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.white),
                onPressed: _delete,
              ),
            ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 300.ms)
    .slideY(begin: -0.3, end: 0);
  }


  Widget _buildSubjectField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _subjectFocus.hasFocus ? selectedColor : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
          width: 2,
        ),
        boxShadow: _subjectFocus.hasFocus ? [
          BoxShadow(
            color: selectedColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _subjectController,
        focusNode: _subjectFocus,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: 'Subject Name',
          labelStyle: TextStyle(
            color: _subjectFocus.hasFocus ? selectedColor : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(Icons.book_rounded, color: selectedColor, size: 28),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        validator: (val) => val!.isEmpty ? 'Enter subject name' : null,
        onChanged: (val) => setState(() {}),
      ),
    );
  }


  Widget _buildTeacherField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _teacherFocus.hasFocus ? selectedColor : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
          width: 2,
        ),
        boxShadow: _teacherFocus.hasFocus ? [
          BoxShadow(
            color: selectedColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _teacherController,
        focusNode: _teacherFocus,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: 'Teacher Name',
          labelStyle: TextStyle(
            color: _teacherFocus.hasFocus ? selectedColor : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(Icons.person_rounded, color: selectedColor, size: 26),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        validator: (val) => val!.isEmpty ? 'Enter teacher name' : null,
      ),
    );
  }


  Widget _buildRoomField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _roomFocus.hasFocus ? selectedColor : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
          width: 2,
        ),
        boxShadow: _roomFocus.hasFocus ? [
          BoxShadow(
            color: selectedColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _roomController,
        focusNode: _roomFocus,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: 'Room Number',
          labelStyle: TextStyle(
            color: _roomFocus.hasFocus ? selectedColor : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(Icons.location_on_rounded, color: selectedColor, size: 26),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        validator: (val) => val!.isEmpty ? 'Enter room number' : null,
      ),
    );
  }


  Widget _buildTimeFields(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTime(context, true),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [selectedColor.withOpacity(0.2), selectedColor.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selectedColor.withOpacity(0.3), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, color: selectedColor, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Start Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _startTimeController.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: selectedColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTime(context, false),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [selectedColor.withOpacity(0.2), selectedColor.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selectedColor.withOpacity(0.3), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, color: selectedColor, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'End Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _endTimeController.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: selectedColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildColorPicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppColors.subjectColors.map((color) {
            final isSelected = color == selectedColor;
            return GestureDetector(
              onTap: () => setState(() => selectedColor = color),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(isSelected ? 0.6 : 0.3),
                      blurRadius: isSelected ? 20 : 10,
                      spreadRadius: isSelected ? 2 : 0,
                    ),
                  ],
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 28)
                    : null,
              )
              .animate(
                key: ValueKey('$color-$isSelected'),
                onPlay: isSelected ? (controller) => controller.repeat(reverse: true) : null,
              )
              .scale(
                begin: Offset(1.0, 1.0), 
                end: Offset(isSelected ? 1.1 : 1.0, isSelected ? 1.1 : 1.0), 
                duration: 800.ms
              ),
            );
          }).toList(),
        ),
      ],
    );
  }


  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E1E2E) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _save,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [selectedColor, selectedColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
        ),
      ],
    );
  }


  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: Colors.white, size: 50),
            )
            .animate()
            .scale(duration: 400.ms, curve: Curves.elasticOut),
            SizedBox(height: 20),
            Text(
              'Saved!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }


  Widget _buildDeleteDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Delete Class?', style: TextStyle(fontWeight: FontWeight.w800)),
      content: Text('This will remove the class from your timetable.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final emptySlot = TimetableSlot(
              id: widget.slot.id,
              subject: '',
              teacher: '',
              room: '',
              day: widget.slot.day,
              timeSlot: widget.slot.timeSlot,
            );
            Navigator.pop(context); // Close dialog
            Navigator.pop(context, emptySlot); // Return empty slot
          },
          child: Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
