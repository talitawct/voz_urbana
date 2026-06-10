import 'package:flutter/material.dart';
import 'features/map/presentation/map_screen.dart';
import 'features/report/presentation/report_screen.dart';
import 'features/feed/presentation/feed_screen.dart';

void main() {
  runApp(const VozUrbanaApp());
}

class VozUrbanaApp extends StatelessWidget {
  const VozUrbanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voz Urbana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.indigo),
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  // Lista que guarda as nossas 3 telas criadas
  final List<Widget> _screens = [
    const MapScreen(),
    const ReportScreen(),
    const FeedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Muda a tela quando você clica no ícone de baixo
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Denunciar'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Histórico'),
        ],
      ),
    );
  }
}