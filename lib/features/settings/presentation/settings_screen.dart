import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;

  const SettingsScreen({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: const Color(0xFF0033A0),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Tema escuro'),
              subtitle: const Text('Ativar modo escuro no aplicativo'),
              value: isDark,
              onChanged: (value) {
                setState(() {
                  isDark = value;
                });

                widget.onThemeToggle(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}