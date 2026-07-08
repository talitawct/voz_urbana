import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voz_urbana/main.dart';

void main() {
  testWidgets('App inicia corretamente', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VozUrbanaApp());

    // Aguarda renderização
    await tester.pumpAndSettle();

    // Verifica se o MaterialApp foi carregado
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verifica se a tela inicial (WelcomeScreen) aparece
    expect(find.byType(Scaffold), findsWidgets);
  });
}