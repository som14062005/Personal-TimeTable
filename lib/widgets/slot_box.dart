import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class SlotBox extends StatefulWidget {
  final String subject;
  final String? teacher;
  final String time;
  final String room;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final int index;
  final double? width;
  final double? height;

  const SlotBox({
    Key? key,
    required this.subject,
    this.teacher,
    required this.time,
    required this.room,
    required this.color,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.index = 0,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<SlotBox> createState() => _SlotBoxState();
}

class _SlotBoxState extends State<SlotBox> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = widget.width != null && widget.width! < 150;
    
    // Handle empty slots
    if (widget.subject.isEmpty) {
      return GestureDetector(
        onTap: widget.onEdit ?? widget.onTap,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 100,
          margin: isCompact ? EdgeInsets.all(2) : EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(isCompact ? 12 : 20),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.grey[400],
                  size: isCompact ? 28 : 40,
                ),
                if (!isCompact) ...[
                  SizedBox(height: 8),
                  Text(
                    'Add Class',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      )
      .animate()
      .fadeIn(duration: 300.ms);
    }

    // COMPACT VERSION FOR WEEKLY GRID
    if (isCompact) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onEdit ?? widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: Duration(milliseconds: 150),
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color,
                  widget.color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subject,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.teacher != null && widget.teacher!.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      widget.teacher!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 10, color: Colors.white),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.time,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
      .animate()
      .fadeIn(duration: 600.ms, delay: (30 * widget.index).ms)
      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic, delay: (30 * widget.index).ms);
    }

    // FULL VERSION - Clean design
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onEdit != null) widget.onEdit!();
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          height: 140,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Left colored accent
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
              ),
              
              SizedBox(width: 20),

              // Icon container
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: widget.color,
                  size: 40,
                ),
              ),
              
              SizedBox(width: 20),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Subject name
                    Text(
                      widget.subject,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Teacher name
                    if (widget.teacher != null && widget.teacher!.isNotEmpty) ...[
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 18,
                            color: widget.color,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.teacher!,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    SizedBox(height: 12),
                    
                    // Time and room info
                    Row(
                      children: [
                        // Time chip
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 16,
                                color: widget.color,
                              ),
                              SizedBox(width: 6),
                              Text(
                                widget.time,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: widget.color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        // Room chip
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                widget.room,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 22,
                  color: widget.color.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 700.ms, delay: (120 * widget.index).ms)
    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic, delay: (120 * widget.index).ms);
  }
}
