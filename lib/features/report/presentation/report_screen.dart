import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Nova Denúncia'),
        backgroundColor: const Color(0xFF0033A0),
        foregroundColor: Colors.white,

        // 🔥 impede voltar para Welcome
        automaticallyImplyLeading: false,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  isDark
                      ? 'assets/images/photodark.png'
                      : 'assets/images/photo.png',
                  height: 180,
                  filterQuality: FilterQuality.high,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Posicione corretamente seu smartphone para tirar uma boa foto.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),

              const SizedBox(height: 30),

              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tirar Foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0033A0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '🤖 IA (TensorFlow Lite): Analisando imagem para sugerir categoria...',
                  style: textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'Descrição do problema',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Ex: Buraco na via, poste quebrado...',
                  hintStyle: textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}