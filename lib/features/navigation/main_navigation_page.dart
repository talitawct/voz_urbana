import 'package:flutter/material.dart';
import '../map/presentation/map_screen.dart';
import '../report/presentation/report_screen.dart';
import '../feed/presentation/feed_screen.dart';

class MainNavigationPage extends StatefulWidget {
  final Function(bool) onThemeToggle;

  const MainNavigationPage({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  Widget _buildCurrentScreen() {
    return switch (_currentIndex) {
      0 => MapScreen(onToggleTheme: widget.onThemeToggle),
      1 => const ReportScreen(),
      _ => const FeedScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: _buildCurrentScreen(),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.indigo,

          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Denunciar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Histórico',
            ),
          ],
        ),
      ),
    );
  }
}
