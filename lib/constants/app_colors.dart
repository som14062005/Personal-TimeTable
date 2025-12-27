import 'package:flutter/material.dart';

class AppColors {
  // Glassmorphic backgrounds
  static const primary = Color(0xFF6C63FF);
  static const secondary = Color(0xFF4ECDC4);
  static const accent = Color(0xFFFF6B6B);
  
  // Subject colors (assign to different subjects)
  static const List<Color> subjectColors = [
    Color(0xFF667EEA), // Purple
    Color(0xFF64B5F6), // Blue
    Color(0xFF4DD0E1), // Cyan
    Color(0xFF81C784), // Green
    Color(0xFFFFB74D), // Orange
    Color(0xFFE57373), // Red
    Color(0xFFBA68C8), // Pink
    Color(0xFFFFD54F), // Yellow
  ];
  
  // Glassmorphic overlay
  static Color glassOverlay(bool isDark) => 
      isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.2);
  
  static Color glassBorder(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.3);
}
