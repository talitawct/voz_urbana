import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/themes/app_theme.dart';

void main() {
  runApp(const VozUrbanaApp());
}

class VozUrbanaApp extends StatefulWidget {
  const VozUrbanaApp({super.key});

  @override
  State<VozUrbanaApp> createState() => _VozUrbanaAppState();
}

class _VozUrbanaAppState extends State<VozUrbanaApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voz Urbana',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      themeMode: _themeMode,

      initialRoute: AppRoutes.login,

      routes: AppRoutes.getRoutes(toggleTheme),
    );
  }
}