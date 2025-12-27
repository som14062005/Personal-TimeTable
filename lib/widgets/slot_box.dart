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
    
    // Handle empty slots with cool animation
    if (widget.subject.isEmpty) {
      return GestureDetector(
        onTap: widget.onEdit ?? widget.onTap,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 100,
          margin: isCompact ? EdgeInsets.all(2) : EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? Colors.grey[850]! : Colors.grey[50]!,
                isDark ? Colors.grey[900]! : Colors.grey[100]!,
              ],
            ),
            borderRadius: BorderRadius.circular(isCompact ? 12 : 20),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.grey[400],
                  size: isCompact ? 24 : 36,
                ),
                if (!isCompact) ...[
                  SizedBox(height: 8),
                  Text(
                    'Add Class',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
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
      .animate(onPlay: (controller) => controller.repeat(reverse: true))
      .fadeIn(duration: 300.ms)
      .scale(begin: Offset(0.95, 0.95), duration: 2000.ms, curve: Curves.easeInOut);
    }

    // COMPACT VERSION FOR WEEKLY GRID - Super colorful
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
                  widget.color.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated background pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: DotPatternPainter(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subject,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.teacher != null && widget.teacher!.isNotEmpty) ...[
                        SizedBox(height: 3),
                        Text(
                          widget.teacher!,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, size: 8, color: Colors.white),
                            SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                widget.time,
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
        ),
      )
      .animate()
      .fadeIn(duration: 600.ms, delay: (30 * widget.index).ms)
      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic, delay: (30 * widget.index).ms)
      .scale(begin: Offset(0.7, 0.7), curve: Curves.easeOutBack, delay: (30 * widget.index).ms)
      .shimmer(duration: 1500.ms, delay: (80 * widget.index).ms, color: Colors.white.withOpacity(0.3));
    }

    // FULL VERSION - GLASSMORPHIC WITH PARALLAX EFFECT
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
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDark 
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white.withOpacity(0.7),
                      isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Animated gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.color.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Left accent with gradient
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              widget.color,
                              widget.color.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.5),
                              blurRadius: 8,
                              offset: Offset(2, 0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Animated icon container
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.color.withOpacity(0.2),
                                  widget.color.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: widget.color.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.color.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.auto_stories_rounded,
                              color: widget.color,
                              size: 36,
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .shimmer(duration: 2000.ms, color: widget.color.withOpacity(0.3))
                          .scale(begin: Offset(1.0, 1.0), end: Offset(1.05, 1.05), duration: 2000.ms),
                          
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                
                                // Teacher name
                                if (widget.teacher != null && widget.teacher!.isNotEmpty) ...[
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline_rounded,
                                        size: 16,
                                        color: widget.color,
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          widget.teacher!,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
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
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            widget.color.withOpacity(0.2),
                                            widget.color.withOpacity(0.1),
                                          ],
                                        ),
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
                                            size: 14,
                                            color: widget.color,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            widget.time,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
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
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDark 
                                            ? Colors.grey[800]?.withOpacity(0.5)
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_on_rounded,
                                            size: 14,
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            widget.room,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
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

                          // Chevron with pulse animation
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                            color: widget.color.withOpacity(0.5),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .slideX(begin: 0, end: 0.2, duration: 1000.ms)
                          .then()
                          .slideX(begin: 0.2, end: 0, duration: 1000.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 700.ms, delay: (120 * widget.index).ms)
    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic, delay: (120 * widget.index).ms)
    .scale(begin: Offset(0.8, 0.8), curve: Curves.easeOutBack, delay: (120 * widget.index).ms);
  }
}

// Custom painter for dot pattern
class DotPatternPainter extends CustomPainter {
  final Color color;
  
  DotPatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    for (double x = 0; x < size.width; x += 15) {
      for (double y = 0; y < size.height; y += 15) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
