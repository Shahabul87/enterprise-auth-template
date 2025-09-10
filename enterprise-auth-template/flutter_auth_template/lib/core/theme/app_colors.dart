import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2563EB); // Blue
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF60A5FA);

  // Secondary colors
  static const Color secondary = Color(0xFF7C3AED); // Purple
  static const Color secondaryDark = Color(0xFF6D28D9);
  static const Color secondaryLight = Color(0xFFA78BFA);

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF9FAFB);
  static const Color background = Color(0xFFF3F4F6);

  // On colors (text on colored backgrounds)
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF111827);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color onBackground = Color(0xFF111827);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Neutral colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  // Border and divider colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color outline = Color(0xFFD1D5DB);

  // Shadow colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x33000000);

  // Overlay colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x33000000);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF2563EB), // Blue
    Color(0xFF7C3AED), // Purple
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Violet
  ];

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successLight, success],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorLight, error],
  );
}

/// Dark theme colors
class AppColorsDark {
  // Primary colors
  static const Color primary = Color(0xFF60A5FA); // Light Blue
  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF93C5FD);

  // Secondary colors
  static const Color secondary = Color(0xFFA78BFA); // Light Purple
  static const Color secondaryDark = Color(0xFF8B5CF6);
  static const Color secondaryLight = Color(0xFFC4B5FD);

  // Surface colors
  static const Color surface = Color(0xFF1F2937);
  static const Color surfaceVariant = Color(0xFF374151);
  static const Color background = Color(0xFF111827);

  // On colors (text on colored backgrounds)
  static const Color onPrimary = Color(0xFF111827);
  static const Color onSecondary = Color(0xFF111827);
  static const Color onSurface = Color(0xFFF9FAFB);
  static const Color onSurfaceVariant = Color(0xFFD1D5DB);
  static const Color onBackground = Color(0xFFF9FAFB);

  // Status colors
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFF87171);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF60A5FA);

  // Text colors
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFFD1D5DB);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFF6B7280);

  // Border and divider colors
  static const Color border = Color(0xFF374151);
  static const Color divider = Color(0xFF374151);
  static const Color outline = Color(0xFF4B5563);
}
