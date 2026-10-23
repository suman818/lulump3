// background, surfaces, accent color, text colors, borders and status colors.

import 'package:flutter/material.dart';

abstract final class AppColors {
  // Main backgrounds
  static const Color background = Color(0xFF101010);
  static const Color surface = Color(0xFF1B1B1B);
  static const Color surfaceElevated = Color(0xFF242424);

  // Brand accent
  static const Color accent = Color(0xFFF2B844);
  static const Color accentMuted = Color(0xFFB88A28);

  // Text
  static const Color textPrimary = Color(0xFFF4F1E8);
  static const Color textSecondary = Color(0xFF92908A);
  static const Color textDisabled = Color(0xFF5F5D58);
  static const Color textOnAccent = Color(0xFF17130A);

  // Borders and dividers
  static const Color border = Color(0xFF303030);
  static const Color divider = Color(0xFF383630);

  // Playback and status
  static const Color success = Color(0xFF72C997);
  static const Color warning = Color(0xFFF2B844);
  static const Color error = Color(0xFFFF6B6B);

  // Player controls
  static const Color inactiveControl = Color(0xFF77756F);
  static const Color progressTrack = Color(0xFF383630);
}
