import 'package:flutter/material.dart';

class YiriTheme {
  static const Color yiriRed = Color(0xFFE30022);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color textBlack = Color(0xFF0B0B0F);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: yiriRed,
        brightness: Brightness.light,
        primary: yiriRed,
        surface: pureWhite,
      ),
      scaffoldBackgroundColor: pureWhite,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: textBlack,
        displayColor: textBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: pureWhite,
        foregroundColor: textBlack,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardTheme(
        color: pureWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: yiriRed, width: 1.6),
        ),
      ),
    );
  }
}
