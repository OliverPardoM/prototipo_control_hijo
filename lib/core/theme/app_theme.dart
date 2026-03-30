// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const double baseRadius = 10;
  static const double textDisplay = 34;
  static const double textHeadline = 24;
  static const double textTitle = 20;
  static const double textBody = 16;
  static const double textSmall = 14;
  static const double textXs = 12;

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.outfit().fontFamily,

      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0288D1),
        onPrimary: Color(0xFFF2F8FC),
        secondary: Color(0xFF003C8F),
        onSecondary: Color(0xFFF3F4F6),
        surface: Color(0xFFE5E7EB),
        onSurface: Color(0xFF232323),
        error: Color(0xFFBA1A1A),
        onError: Color(0xFFFFFFFF),
        outline: Color(0xFFE0E0E0),
        surfaceTint: Color(0xFF343434),
      ),

      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(baseRadius),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(baseRadius - 4),
        ),
      ),

      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: textDisplay,
            fontWeight: FontWeight.w700,
          ),
          headlineLarge: TextStyle(
            fontSize: textHeadline,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            fontSize: textTitle,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(fontSize: textBody, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(
            fontSize: textSmall,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: TextStyle(fontSize: textXs, fontWeight: FontWeight.w500),
        ),
      ),

      extensions: [CustomColors.light()],
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.outfit().fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1565C0),
        onPrimary: Color(0xFFF2F8FC),
        secondary: Color(0xFF003C8F),
        onSecondary: Color(0xFFFAFAFA),
        surface: Color(0xFF343434),
        onSurface: Color(0xFFFAFAFA),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        outline: Color(0x1AFFFFFF),
        surfaceTint: Color(0xFF8C8C8C),
      ),

      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(baseRadius),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(baseRadius - 4),
        ),
      ),

      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: textDisplay,
            fontWeight: FontWeight.w700,
          ),
          headlineLarge: TextStyle(
            fontSize: textHeadline,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            fontSize: textTitle,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(fontSize: textBody, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(
            fontSize: textSmall,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: TextStyle(fontSize: textXs, fontWeight: FontWeight.w500),
        ),
      ),

      extensions: [CustomColors.dark()],
    );
  }
}

class CustomColors extends ThemeExtension<CustomColors> {
  final Color background;
  final Color foreground;
  final Color border;
  final Color input;
  final Color ring;

  const CustomColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.input,
    required this.ring,
  });

  static CustomColors light() {
    return const CustomColors(
      background: Color(0xFFFFFFFF),
      foreground: Color(0xFF232323),
      border: Color(0xFFE0E0E0),
      input: Color(0xFFE0E0E0),
      ring: Color(0xFFB0B0B0),
    );
  }

  static CustomColors dark() {
    return const CustomColors(
      background: Color(0xFF232323),
      foreground: Color(0xFFFAFAFA),
      border: Color(0x1AFFFFFF),
      input: Color(0x26FFFFFF),
      ring: Color(0xFF8C8C8C),
    );
  }

  @override
  CustomColors copyWith({
    Color? background,
    Color? foreground,
    Color? border,
    Color? input,
    Color? ring,
  }) {
    return CustomColors(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      border: border ?? this.border,
      input: input ?? this.input,
      ring: ring ?? this.ring,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;

    return CustomColors(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      border: Color.lerp(border, other.border, t)!,
      input: Color.lerp(input, other.input, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
    );
  }
}
