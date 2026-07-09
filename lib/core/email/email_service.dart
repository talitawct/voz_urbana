import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_service.dart';
import '../reports/urban_report.dart';

class EmailService {
  EmailService._();

  static const recipientEmail = 'talitawct3@gmail.com';

  static Future<void> sendReportEmail(UrbanReport report) async {
    final currentUser = AuthService.currentUser;
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${report.latitude},${report.longitude}';

    final response = await http.post(
      Uri.parse('https://formsubmit.co/ajax/$recipientEmail'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        '_subject': 'Nova denúncia Voz Urbana - ${report.category}',
        '_captcha': 'false',
        'categoria': report.category,
        'status': report.status,
        'descricao': report.description.isEmpty
            ? 'Sem descrição informada.'
            : report.description,
        'latitude': report.latitude.toStringAsFixed(6),
        'longitude': report.longitude.toStringAsFixed(6),
        'localizacao_google_maps': mapsUrl,
        'foto_no_dispositivo': report.imagePath,
        'data_registro': report.createdAt.toIso8601String(),
        'usuario_nome': currentUser?.name ?? 'Usuário não identificado',
        'usuario_email': currentUser?.email ?? 'E-mail não informado',
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw EmailException(
        'Falha ao enviar e-mail: HTTP ${response.statusCode}',
      );
    }
  }
}

class EmailException implements Exception {
  EmailException(this.message);

  final String message;

  @override
  String toString() => message;
}
