import 'dart:io';

import 'package:flutter/foundation.dart';
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

  Color _statusColor(String status) {
    return status == 'Resolvido' ? Colors.green.shade700 : Colors.red.shade700;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year às $hour:$minute';
  }

  String _protocol(UrbanReport report) {
    return report.id == null ? 'Sem protocolo' : '#${report.id}';
  }

  void _showReportDetails(UrbanReport report) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_protocol(report)} - ${report.category}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _ReportImagePreview(imagePath: report.imagePath),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.flag,
                  label: 'Status',
                  value: report.status,
                ),
                _DetailRow(
                  icon: Icons.schedule,
                  label: 'Criada em',
                  value: _formatDate(report.createdAt),
                ),
                _DetailRow(
                  icon: Icons.location_on,
                  label: 'Localização',
                  value:
                      '${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}',
                ),
                _DetailRow(
                  icon: Icons.notes,
                  label: 'Descrição',
                  value: report.description.isEmpty
                      ? 'Sem descrição informada.'
                      : report.description,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: report.id == null
                      ? null
                      : () => _toggleReportStatus(context, report),
                  icon: Icon(
                    report.status == 'Resolvido'
                        ? Icons.pending_actions
                        : Icons.check_circle_outline,
                  ),
                  label: Text(
                    report.status == 'Resolvido'
                        ? 'Marcar como pendente'
                        : 'Marcar como resolvida',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0033A0),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: report.id == null
                      ? null
                      : () => _confirmDeleteReport(context, report),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Excluir denúncia'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleReportStatus(
    BuildContext bottomSheetContext,
    UrbanReport report,
  ) async {
    final id = report.id;
    if (id == null) return;

    final newStatus = report.status == 'Resolvido' ? 'Pendente' : 'Resolvido';

    await ReportRepository.updateStatus(
      id: id,
      status: newStatus,
    );

    if (!mounted || !bottomSheetContext.mounted) return;

    Navigator.pop(bottomSheetContext);
    _reloadReports();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Denúncia marcada como $newStatus.'),
      ),
    );
  }

  Future<void> _confirmDeleteReport(
    BuildContext bottomSheetContext,
    UrbanReport report,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir denúncia?'),
          content: const Text(
            'Esta ação remove o registro do histórico e do mapa neste dispositivo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || report.id == null) return;

    await ReportRepository.deleteById(report.id!);

    if (!mounted || !bottomSheetContext.mounted) return;

    Navigator.pop(bottomSheetContext);
    _reloadReports();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Denúncia excluída.'),
      ),
    );
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
                      '${_protocol(report)} - ${report.category}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatusBadge(
                            status: report.status,
                            color: _statusColor(report.status),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            [
                              'Criada em ${_formatDate(report.createdAt)}',
                              'Local: ${report.latitude.toStringAsFixed(5)}, ${report.longitude.toStringAsFixed(5)}',
                              if (report.description.isNotEmpty)
                                'Descrição: ${report.description}',
                            ].join('\n'),
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showReportDetails(report),
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

class _ReportImagePreview extends StatelessWidget {
  const _ReportImagePreview({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: kIsWeb ? _webImage(context) : _deviceImage(context),
    );
  }

  Widget _webImage(BuildContext context) {
    if (imagePath.isEmpty) return _unavailableImage(context);

    return Image.network(
      imagePath,
      height: 220,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _unavailableImage(context),
    );
  }

  Widget _deviceImage(BuildContext context) {
    final imageFile = File(imagePath);

    if (!imageFile.existsSync()) return _unavailableImage(context);

    return Image.file(
      imageFile,
      height: 220,
      fit: BoxFit.cover,
    );
  }

  Widget _unavailableImage(BuildContext context) {
    return Container(
      height: 140,
      color: Theme.of(context).dividerColor,
      alignment: Alignment.center,
      child: const Text('Foto indisponível'),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF0033A0),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.color,
  });

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          status,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
