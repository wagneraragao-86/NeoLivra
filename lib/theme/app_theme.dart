import 'package:flutter/material.dart';

class AppTheme {
  static const Color deepBlue = Color(0xFF0A1F44);
  static const Color midBlue = Color(0xFF123A7A);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color softGreen = Color(0xFF2EDB6C);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: deepBlue,
    primaryColor: neonGreen,
    colorScheme: const ColorScheme.dark(
      primary: neonGreen,
      secondary: softGreen,
      surface: deepBlue,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: deepBlue,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonGreen,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}