import '../config/local_secrets.dart';
import '../auth/auth_service.dart';
import '../reports/urban_report.dart';
import 'email_transport.dart';

class EmailService {
  EmailService._();

  static const _defaultWeb3FormsAccessKey = String.fromEnvironment(
    'WEB3FORMS_ACCESS_KEY',
  );
  static const _infrastructureWeb3FormsAccessKey = String.fromEnvironment(
    'WEB3FORMS_INFRASTRUCTURE_ACCESS_KEY',
  );
  static const _sanitationWeb3FormsAccessKey = String.fromEnvironment(
    'WEB3FORMS_SANITATION_ACCESS_KEY',
  );

  static const infrastructureRecipientEmail = 'talitawct3@gmail.com';
  static const sanitationRecipientEmail = 'claudio.vieira@ufba.br';

  static String recipientForCategory(String category) {
    return switch (_normalizeCategory(category)) {
      'buraco na via' ||
      'poste danificado' ||
      'iluminacao publica' ||
      'lixo acumulado' =>
        infrastructureRecipientEmail,
      'esgoto' || 'arvore caida' || 'outro' => sanitationRecipientEmail,
      _ => sanitationRecipientEmail,
    };
  }

  static Future<String> sendReportEmail(UrbanReport report) async {
    final currentUser = AuthService.currentUser;
    final recipientEmail = recipientForCategory(report.category);
    final accessKey = _accessKeyForRecipient(recipientEmail);
    final mapsUrl =
        'https://www.openstreetmap.org/?mlat=${report.latitude}&mlon=${report.longitude}#map=18/${report.latitude}/${report.longitude}';

    if (accessKey.trim().isEmpty) {
      throw EmailException(
        'Chave do Web3Forms não configurada para $recipientEmail.',
      );
    }

    final payload = {
      'access_key': accessKey,
      'subject':
          'Nova denúncia Voz Urbana #${report.id ?? 'sem-protocolo'} - ${report.category}',
      'from_name': 'Voz Urbana',
      'email': currentUser?.email ?? 'nao-informado@vozurbana.local',
      'replyto': currentUser?.email ?? 'nao-informado@vozurbana.local',
      'message': _emailMessage(
        report: report,
        recipientEmail: recipientEmail,
        mapsUrl: mapsUrl,
        userName: currentUser?.name ?? 'Usuário não identificado',
        userEmail: currentUser?.email ?? 'E-mail não informado',
      ),
      'protocolo': report.id == null ? 'Não informado' : '#${report.id}',
      'categoria': report.category,
      'destinatario_orgao': recipientEmail,
      'status': report.status,
      'descricao': report.description.isEmpty
          ? 'Sem descrição informada.'
          : report.description,
      'latitude': report.latitude.toStringAsFixed(6),
      'longitude': report.longitude.toStringAsFixed(6),
      'localizacao_mapa': mapsUrl,
      'foto_no_dispositivo': report.imagePath,
      'data_registro': report.createdAt.toIso8601String(),
      'usuario_nome': currentUser?.name ?? 'Usuário não identificado',
      'usuario_email': currentUser?.email ?? 'E-mail não informado',
      'botcheck': '',
    };

    try {
      await EmailTransport.send(
        payload: payload,
      );
    } catch (error) {
      throw EmailException(
        'Falha ao conectar ao serviço de e-mail. ${_shortResponse(error.toString())}',
      );
    }

    return recipientEmail;
  }

  static String _emailMessage({
    required UrbanReport report,
    required String recipientEmail,
    required String mapsUrl,
    required String userName,
    required String userEmail,
  }) {
    return '''
Nova denúncia registrada no Voz Urbana.

Protocolo: ${report.id == null ? 'Não informado' : '#${report.id}'}
Categoria: ${report.category}
Órgão/destinatário demonstrativo: $recipientEmail
Status: ${report.status}
Descrição: ${report.description.isEmpty ? 'Sem descrição informada.' : report.description}
Localização: ${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}
Mapa: $mapsUrl
Foto no dispositivo: ${report.imagePath}
Data de registro: ${report.createdAt.toIso8601String()}
Usuário: $userName
E-mail do usuário: $userEmail
''';
  }

  static String _accessKeyForRecipient(String recipientEmail) {
    if (recipientEmail == infrastructureRecipientEmail) {
      return _infrastructureWeb3FormsAccessKey.trim().isNotEmpty
          ? _infrastructureWeb3FormsAccessKey
          : _configuredDefaultAccessKey;
    }

    if (recipientEmail == sanitationRecipientEmail) {
      return _sanitationWeb3FormsAccessKey.trim().isNotEmpty
          ? _sanitationWeb3FormsAccessKey
          : LocalSecrets.web3FormsSanitationAccessKey;
    }

    return _configuredDefaultAccessKey;
  }

  static String get _configuredDefaultAccessKey {
    if (_defaultWeb3FormsAccessKey.trim().isNotEmpty) {
      return _defaultWeb3FormsAccessKey;
    }

    if (LocalSecrets.web3FormsInfrastructureAccessKey.trim().isNotEmpty) {
      return LocalSecrets.web3FormsInfrastructureAccessKey;
    }

    return LocalSecrets.web3FormsAccessKey;
  }

  static String _normalizeCategory(String category) {
    return category
        .trim()
        .toLowerCase()
        .replaceAll(RegExp('[áàâã]'), 'a')
        .replaceAll(RegExp('[éê]'), 'e')
        .replaceAll('í', 'i')
        .replaceAll(RegExp('[óôõ]'), 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }

  static String _shortResponse(String body) {
    final normalizedBody = body.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedBody.isEmpty) return 'Sem detalhes do servidor.';

    if (normalizedBody.length <= 160) return normalizedBody;

    return '${normalizedBody.substring(0, 157)}...';
  }
}

class EmailException implements Exception {
  EmailException(this.message);

  final String message;

  @override
  String toString() => message;
}
