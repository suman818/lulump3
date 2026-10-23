// reusable typography for screen titles, track names, labels and supporting text.

import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  // Screen headings
  static const TextStyle screenTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // Track information
  static const TextStyle trackTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle trackArtist = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // Navigation and controls
  static const TextStyle navigationLabel = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // Small labels and metadata
  static const TextStyle overline = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  static const TextStyle metadata = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Playback timestamps
  static const TextStyle playbackTime = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Status and error messages
  static const TextStyle error = TextStyle(
    color: AppColors.error,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
