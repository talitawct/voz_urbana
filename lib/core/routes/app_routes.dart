import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/welcome_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/report/presentation/report_screen.dart';
import '../../features/feed/presentation/feed_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const map = '/map';
  static const report = '/report';
  static const feed = '/feed';

  static Map<String, WidgetBuilder> getRoutes(
    Function(bool) toggleTheme,
  ) {
    return {
      login: (context) => WelcomeScreen(
            onThemeToggle: toggleTheme,
          ),
      map: (context) => MapScreen(
            onToggleTheme: toggleTheme,
          ),
      report: (context) => const ReportScreen(),
      feed: (context) => const FeedScreen(),
    };
  }
}