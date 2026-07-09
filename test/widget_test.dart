import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voz_urbana/main.dart';

void main() {
  testWidgets('App abre tela inicial e navega para login', (tester) async {
    await tester.pumpWidget(const VozUrbanaApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Cadastrar Grátis'), findsOneWidget);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.text('Entrar com Google'), findsOneWidget);
    expect(find.text('Entrar com Gov.br'), findsOneWidget);
  });
}
