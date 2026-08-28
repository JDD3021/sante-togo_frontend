import 'package:flutter/material.dart';

/// Centralized color palette for SANTÉ+ TOGO
/// 
/// STRICT RULE: The red color (#B4362A) must ONLY be used for critical medical alerts
/// (allergies, emergencies). Never use it for other purposes to avoid desensitization.
class AppColors {
  AppColors._();

  // Primary - Medical green for positive actions and main buttons
  static const Color primary = Color(0xFF1A6B54);
  static const Color primaryDark = Color(0xFF0F4A39);
  static const Color primaryLight = Color(0xFFDCEDE6);

  // Accent - Warm orange for moderate alerts, reminders, items to process
  static const Color accent = Color(0xFFE67E22);
  static const Color accentLight = Color(0xFFFCE9D2);

  // Red - EXCLUSIVELY for critical medical alerts (allergies, emergencies)
  static const Color red = Color(0xFFB4362A);
  static const Color redLight = Color(0xFFF7E1DE);

  // Neutral tones
  static const Color sand = Color(0xFFEFE6D6);
  static const Color sandDark = Color(0xFFD8C9A9);
  
  // Text colors
  static const Color ink = Color(0xFF20261F); // Primary text
  static const Color inkSoft = Color(0xFF5B6660); // Secondary text

  // Borders and dividers
  static const Color line = Color(0xFFE4DDCD);

  // Backgrounds
  static const Color screenBg = Color(0xFFFBF8F2);
  static const Color white = Color(0xFFFFFFFF);
}
