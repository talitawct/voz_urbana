import 'package:flutter/material.dart';

import '../../../core/reports/report_repository.dart';
import '../../../core/reports/urban_report.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<UrbanReport>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = ReportRepository.findAll();
  }

  void _reloadReports() {
    setState(() {
      _reportsFuture = ReportRepository.findAll();
    });
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Buraco na via' => Icons.report_problem,
      'Poste danificado' => Icons.electrical_services,
      'Iluminação pública' => Icons.lightbulb,
      'Lixo acumulado' => Icons.delete,
      'Esgoto' => Icons.water_damage,
      'Árvore caída' => Icons.park,
      _ => Icons.campaign,
    };
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year às $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ocorrências da Comunidade'),
        backgroundColor: const Color(0xFF0033A0),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _reloadReports,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: FutureBuilder<List<UrbanReport>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar as denúncias salvas.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ),
            );
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nenhuma denúncia registrada ainda.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadReports(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: Theme.of(context).cardColor,
                  child: ListTile(
                    leading: Icon(
                      _categoryIcon(report.category),
                      color: const Color(0xFF0033A0),
                      size: 40,
                    ),
                    title: Text(
                      report.category,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      [
                        'Status: ${report.status}',
                        'Criada em ${_formatDate(report.createdAt)}',
                        'Local: ${report.latitude.toStringAsFixed(5)}, ${report.longitude.toStringAsFixed(5)}',
                        if (report.description.isNotEmpty)
                          'Descrição: ${report.description}',
                      ].join('\n'),
                      style: textTheme.bodyMedium,
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
