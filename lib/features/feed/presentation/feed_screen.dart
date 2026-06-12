import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final List<Map<String, dynamic>> feed = [
      {
        'icon': Icons.lightbulb,
        'color': Colors.green,
        'title': 'Poste sem Luz na Rua 4',
        'subtitle': 'Status: Resolvido',
      },
      {
        'icon': Icons.report_problem,
        'color': Colors.red,
        'title': 'Buraco na Av. Principal',
        'subtitle': 'Status: Urgente (Pendente)',
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ✔️ padrão visual igual outras telas
      appBar: AppBar(
        title: const Text('Ocorrências da Comunidade'),
        backgroundColor: const Color(0xFF0033A0),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // 🔥 evita botão de voltar
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: feed.length,
        itemBuilder: (context, index) {
          final item = feed[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: Icon(
                item['icon'],
                color: item['color'],
                size: 40,
              ),
              title: Text(
                item['title'],
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                item['subtitle'],
                style: textTheme.bodyMedium,
              ),
            ),
          );
        },
      ),
    );
  }
}