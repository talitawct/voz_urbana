import 'dart:convert';

import 'package:http/http.dart' as http;

class EmailTransport {
  EmailTransport._();

  static Future<void> send({
    required Map<String, String> payload,
  }) async {
    final response = await http
        .post(
          Uri.parse('https://api.web3forms.com/submit'),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));

    final responseBody = _decodeResponse(response.body);
    final success = responseBody['success'] == true;

    if (response.statusCode != 200 || !success) {
      throw Exception(
        'HTTP ${response.statusCode}. ${_responseMessage(responseBody, response.body)}',
      );
    }
  }

  static Map<String, dynamic> _decodeResponse(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return {};
    }

    return {};
  }

  static String _responseMessage(
    Map<String, dynamic> responseBody,
    String rawBody,
  ) {
    final body = responseBody['body'];
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    final message = responseBody['message'];
    if (message is String && message.trim().isNotEmpty) return message;

    return _shortResponse(rawBody);
  }

  static String _shortResponse(String body) {
    final normalizedBody = body.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedBody.isEmpty) return 'Sem detalhes do servidor.';

    if (normalizedBody.length <= 160) return normalizedBody;

    return '${normalizedBody.substring(0, 157)}...';
  }
}
