import "package:flutter/material.dart";

class AppTheme {
  static const Color lightPrimary = Color(0xFF0057D9);
  static const Color lightAccent = Color(0xFF00A7A0);
  static const Color darkPrimary = Color(0xFF66A6FF);
  static const Color darkAccent = Color(0xFF4ED4CC);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: lightPrimary,
      brightness: Brightness.light,
    ).copyWith(
      primary: lightPrimary,
      secondary: lightAccent,
      surface: const Color(0xFFF5F8FC),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFEFF4FA),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: darkPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: darkPrimary,
      secondary: darkAccent,
      surface: const Color(0xFF1A2430),
      onSurface: const Color(0xFFEAF1FF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF101823),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFF1A2430),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
