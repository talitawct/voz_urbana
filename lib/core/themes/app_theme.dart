import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.indigo,
    scaffoldBackgroundColor: const Color(0xFFF2F7FF),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.indigo,
    scaffoldBackgroundColor: const Color(0xFF121826),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E2A3A),
      foregroundColor: Colors.white,
    ),
  );
}