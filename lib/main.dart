import 'package:flutter/material.dart';
import 'features/auth/welcome_screen.dart';
import 'features/map/presentation/map_screen.dart';
import 'features/report/presentation/report_screen.dart';
import 'features/feed/presentation/feed_screen.dart';

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

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF2F7FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121826),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E2A3A),
          foregroundColor: Colors.white,
        ),
      ),

      themeMode: _themeMode,

      initialRoute: '/login',

      routes: {
        '/login': (context) => WelcomeScreen(
              onThemeToggle: toggleTheme,
            ),

        '/map': (context) => MapScreen(
              onToggleTheme: toggleTheme,
            ),

        '/report': (context) => const ReportScreen(),

        '/feed': (context) => const FeedScreen(),
      },
    );
  }
}