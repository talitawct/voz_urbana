import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/email/email_service.dart';
import '../../../core/reports/report_repository.dart';
import '../../../core/reports/urban_report.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ImagePicker _picker = ImagePicker();
  final _descriptionController = TextEditingController();

  File? _image;
  String? _categoria;
  Position? _currentPosition;
  String _locationStatus = 'Obtendo localização atual...';
  bool _isTakingPhoto = false;
  bool _isLoadingLocation = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _capturarLocalizacaoAtual();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

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

  Future<void> _capturarLocalizacaoAtual() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = 'Obtendo localização atual...';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationError(
          'Ative o GPS do dispositivo para anexar a localização da denúncia.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _setLocationError(
          'Permissão de localização negada. Autorize o acesso para registrar o local da denúncia.',
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _setLocationError(
          'A permissão de localização foi bloqueada. Libere o acesso nas configurações do aplicativo.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _locationStatus =
            'Localização registrada: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      });
    } catch (_) {
      _setLocationError(
        'Não foi possível obter a localização atual. Tente novamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _setLocationError(String message) {
    if (!mounted) return;

    setState(() {
      _currentPosition = null;
      _locationStatus = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _enviarDenuncia() async {
    final image = _image;
    final category = _categoria;
    final position = _currentPosition;

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tire uma foto antes de enviar a denúncia.'),
        ),
      );
      return;
    }

    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma categoria.'),
        ),
      );
      return;
    }

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registre a localização antes de enviar a denúncia.'),
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final report = UrbanReport(
        category: category,
        description: _descriptionController.text.trim(),
        imagePath: image.path,
        latitude: position.latitude,
        longitude: position.longitude,
        status: 'Pendente',
        createdAt: DateTime.now(),
      );

      await ReportRepository.save(report);

      var emailSent = true;

      try {
        await EmailService.sendReportEmail(report);
      } catch (_) {
        emailSent = false;
      }

      if (!mounted) return;

      setState(() {
        _image = null;
        _categoria = null;
        _descriptionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            emailSent
                ? 'Denúncia salva e e-mail enviado ao órgão responsável.'
                : 'Denúncia salva, mas não foi possível enviar o e-mail.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar a denúncia. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
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

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _currentPosition == null
                          ? Icons.location_searching
                          : Icons.location_on,
                      color: const Color(0xFF0033A0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Localização da denúncia',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _locationStatus,
                            style: textTheme.bodySmall,
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _isLoadingLocation
                                ? null
                                : _capturarLocalizacaoAtual,
                            icon: _isLoadingLocation
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location),
                            label: Text(
                              _isLoadingLocation
                                  ? 'Localizando...'
                                  : 'Atualizar localização',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                controller: _descriptionController,
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
                    onPressed: _isSending ? null : _enviarDenuncia,
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isSending ? 'Enviando...' : 'Enviar Denúncia',
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
            ],
          ),
        ),
      ),
    );
  }
}
