import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF128c7E); // WhatsApp UI green
  static const Color primaryLight = Color(
    0xFFE8F3F1,
  ); // Lighter shade of WhatsApp green

  // Text Colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;
  static const Color textLight = Colors.white;

  // Background Colors
  static const Color background = Color(0xFFF3F3F3);
  static const Color surface = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF1C40F);

  // Utility Colors
  static const Color divider = Colors.black12;
  static const Color shadow = Color(0x40000000);
  static const Color border = Colors.black38;
  static const Color surfaceInput = Color(0xFFEAFBF0);

  // Helper method to get primary color with opacity
  static Color getPrimaryWithAlpha(double opacity) {
    final int alpha = (opacity * 255).round();
    return primary.withAlpha(alpha);
  }
}
