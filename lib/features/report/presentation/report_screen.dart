import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _image;
  String? _categoria;
  bool _isTakingPhoto = false;

  Future<void> _tirarFoto() async {
    setState(() {
      _isTakingPhoto = true;
    });

    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (foto != null) {
        setState(() {
          _image = File(foto.path);
        });
      }
    } on PlatformException catch (error) {
      if (!mounted) return;

      final message = switch (error.code) {
        'camera_access_denied' =>
          'Permissão da câmera negada. Autorize o acesso para registrar a denúncia.',
        'camera_access_restricted' =>
          'O acesso à câmera está restrito neste dispositivo.',
        'camera_unavailable' =>
          'Não foi possível acessar a câmera deste dispositivo.',
        _ => 'Não foi possível abrir a câmera. Tente novamente.',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPhoto = false;
        });
      }
    }
  }

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
        automaticallyImplyLeading: false,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _image == null
                    ? Image.asset(
                        isDark
                            ? 'assets/images/photodark.png'
                            : 'assets/images/photo.png',
                        height: 180,
                        filterQuality: FilterQuality.high,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              Text(
                'Posicione corretamente seu smartphone para tirar uma boa foto. O sistema solicitará sua permissão para acessar a câmera.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),

              const SizedBox(height: 30),

              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isTakingPhoto ? null : _tirarFoto,
                    icon: _isTakingPhoto
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.camera_alt),
                    label: Text(
                      _isTakingPhoto ? 'Abrindo...' : 'Tirar Foto',
                    ),
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

              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Categoria da denúncia',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Buraco na via',
                    child: Text('Buraco na via'),
                  ),
                  DropdownMenuItem(
                    value: 'Poste danificado',
                    child: Text('Poste danificado'),
                  ),
                  DropdownMenuItem(
                    value: 'Iluminação pública',
                    child: Text('Iluminação pública'),
                  ),
                  DropdownMenuItem(
                    value: 'Lixo acumulado',
                    child: Text('Lixo acumulado'),
                  ),
                  DropdownMenuItem(
                    value: 'Esgoto',
                    child: Text('Esgoto'),
                  ),
                  DropdownMenuItem(
                    value: 'Árvore caída',
                    child: Text('Árvore caída'),
                  ),
                  DropdownMenuItem(
                    value: 'Outro',
                    child: Text('Outro'),
                  ),
                ],
                onChanged: (valor) {
                  setState(() {
                    _categoria = valor;
                  });
                },
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
                  hintText: 'Informe detalhes que possam auxiliar na análise da denúncia. (opcional)',
                  hintStyle: textTheme.bodySmall,
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tire uma foto antes de enviar a denúncia.'),
                          ),
                        );
                        return;
                      }

                      if (_categoria == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selecione uma categoria.'),
                          ),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Denúncia enviada com sucesso!'),
                        ),
                      );

                      // Aqui futuramente será feita a gravação
                      // da denúncia no banco de dados/Firebase/API.
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar Denúncia'),
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
            ],
          ),
        ),
      ),
    );
  }
}
