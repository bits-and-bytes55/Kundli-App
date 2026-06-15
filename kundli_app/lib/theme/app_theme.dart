import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─── Global App Colors ────────────────────────────────────────────────────
/// Single source of truth. Import AppColors anywhere in the app.
class AppColors {
  AppColors._();

  // Primary palette — dark orange (matches Graha Sthiti theme)
  static const Color primary       = Color(0xFFE07B20); // Dark orange
  static const Color primaryLight  = Color(0xFFFFB74D); // Amber/light orange
  static const Color primaryDark   = Color(0xFFBF5400); // Deeper burnt orange
  static const Color accent        = Color(0xFFFFB300); // Golden amber
  static const Color accentLight   = Color(0xFFFFF3E0); // Very light peach/orange tint

  // Backgrounds
  static const Color scaffoldBg    = Color(0xFFFFFDF0); // Warm light yellow-white
  static const Color cardBg        = Color(0xFFFFFFFF);
  static const Color surfaceBg     = Color(0xFFFFF8F0); // Very slight warm tint

  // Text
  static const Color textDark      = Color(0xFF2C3E50);
  static const Color textMedium    = Color(0xFF5D6D7E);
  static const Color textLight     = Color(0xFF7F8C8D);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders & dividers
  static const Color border        = Color(0xFFFFCC80); // Warm orange border
  static const Color divider       = Color(0xFFEEEEEE);

  // Semantic
  static const Color success       = Color(0xFF2E7D32);
  static const Color error         = Color(0xFFC62828);
  static const Color warning       = Color(0xFFE65100);
}

class AppTheme {
  // Keep backward-compat aliases pointing to AppColors
  static const Color primaryPink  = AppColors.primary;
  static const Color lightPink    = AppColors.accentLight;
  static const Color accentGreen  = AppColors.accent;
  static const Color white        = AppColors.cardBg;
  static const Color textColor    = AppColors.textDark;
  static const Color textLight    = AppColors.textLight;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.cardBg,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textDark,
        onSurface: AppColors.textDark,
      ),
      textTheme: GoogleFonts.montserratTextTheme().apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Montserrat'),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
      ),
    );
  }
}

