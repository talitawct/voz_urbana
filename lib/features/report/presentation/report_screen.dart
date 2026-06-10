import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Denúncia'), 
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {}, 
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tirar Foto do Problema (Câmera)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800], 
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200], 
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('🤖 IA (TensorFlow Lite): Analisando imagem para sugerir categoria...'),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Descrição do problema (ex: Buraco na via)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}