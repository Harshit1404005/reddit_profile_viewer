import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color surface = Color(0xFF131319);
  static const Color surfaceContainer = Color(0xFF1F1F26);
  static const Color surfaceContainerHigh = Color(0xFF2A2930);
  static const Color surfaceContainerHighest = Color(0xFF35343B);
  
  static const Color primary = Color(0xFFDCB8FF);
  static const Color primaryContainer = Color(0xFF8A2BE2);
  static const Color onPrimaryContainer = Color(0xFFEED9FF);
  
  static const Color secondary = Color(0xFFA5C8FF);
  static const Color secondaryContainer = Color(0xFF2792FF);
  
  static const Color tertiary = Color(0xFF4CE346);
  static const Color error = Color(0xFFFFB4AB);
  
  static const Color onSurface = Color(0xFFE4E1EA);
  static const Color onSurfaceVariant = Color(0xFFCFC2D7);
  static const Color outlineVariant = Color(0xFF4C4354);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        error: error,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        surfaceContainer: surfaceContainer,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.apply(
              bodyColor: onSurface,
              displayColor: onSurface,
            ),
      ).copyWith(
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: onSurfaceVariant,
        ),
      ),
    );
  }
}
