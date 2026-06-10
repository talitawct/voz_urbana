import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocorrências da Comunidade'), 
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.report_problem, color: Colors.red, size: 40),
            title: Text('Buraco na Av. Principal'),
            subtitle: Text('Status: Urgente (Pendente)'),
          ),
          ListTile(
            leading: Icon(Icons.lightbulb, color: Colors.green, size: 40),
            title: Text('Poste sem Luz na Rua 4'),
            subtitle: Text('Status: Resolvido'),
          ),
        ],
      ),
    );
  }
}