import 'package:flutter_test/flutter_test.dart';
import 'package:voz_urbana/core/email/email_service.dart';

void main() {
  group('EmailService.recipientForCategory', () {
    test('encaminha categorias de infraestrutura para o e-mail de teste', () {
      const expectedEmail = 'talitawct3@gmail.com';

      expect(
        EmailService.recipientForCategory('Buraco na via'),
        expectedEmail,
      );
      expect(
        EmailService.recipientForCategory('Poste danificado'),
        expectedEmail,
      );
      expect(
        EmailService.recipientForCategory('Iluminação pública'),
        expectedEmail,
      );
      expect(
        EmailService.recipientForCategory('Lixo acumulado'),
        expectedEmail,
      );
    });

    test('encaminha categorias de saneamento e outros para a UFBA', () {
      const expectedEmail = 'claudio.vieira@ufba.br';

      expect(EmailService.recipientForCategory('Esgoto'), expectedEmail);
      expect(EmailService.recipientForCategory('Árvore caída'), expectedEmail);
      expect(EmailService.recipientForCategory('Outro'), expectedEmail);
    });
  });
}
