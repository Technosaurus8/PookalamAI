import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared design tokens for Pookalam.ai — Onam palette, typography, and
/// reusable decorations. Mirrors the tokens originally defined privately
/// in welcome_screen.dart's `_Palette`, so Draw/Leaderboard match it
/// without duplicating magic numbers. welcome_screen.dart itself is left
/// untouched for now — it can optionally be repointed to this file later.
class AppColors {
  AppColors._();

  static const green = Color(0xFF0F3D2E);
  static const gold = Color(0xFFF2A93C);
  static const red = Color(0xFFC1432E);
  static const cream = Color(0xFFFAF6EE);
  static const purple = Color(0xFF6B3FA0);
  static const yellow = Color(0xFFF7D046);

  static final creamFaded = cream.withOpacity(0.55);
  static final creamHint = cream.withOpacity(0.85);
}

class AppText {
  AppText._();

  static TextStyle heading({double size = 22, Color color = AppColors.gold}) =>
      GoogleFonts.baloo2(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle button({double size = 16, Color color = AppColors.green}) =>
      GoogleFonts.baloo2(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle body({
    double size = 14,
    Color color = AppColors.cream,
    FontWeight weight = FontWeight.w500,
  }) => GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);

  static TextStyle label({double size = 12, Color color = AppColors.cream}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color.withOpacity(0.75),
        letterSpacing: 0.4,
      );
}

class AppDecor {
  AppDecor._();

  static BoxDecoration card({
    double radius = 14,
    Color color = AppColors.cream,
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.18),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.gold,
    foregroundColor: AppColors.green,
    disabledBackgroundColor: AppColors.gold.withOpacity(0.5),
    disabledForegroundColor: AppColors.green.withOpacity(0.7),
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 0,
  );
  static final SliderThemeData sliderTheme = SliderThemeData(
    activeTrackColor: AppColors.gold,
    inactiveTrackColor: AppColors.cream.withOpacity(0.3),
    thumbColor: AppColors.gold,
    overlayColor: AppColors.gold.withOpacity(0.2),
    trackHeight: 3,
  );

  static AlertDialog themedDialog({
    required Widget title,
    required Widget content,
    required List<Widget> actions,
  }) => AlertDialog(
    backgroundColor: AppColors.cream,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: title,
    content: content,
    actions: actions,
  );
}
