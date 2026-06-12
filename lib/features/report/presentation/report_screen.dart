import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // 1️⃣ IMPORT DO GPS ADICIONADO

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController descricaoController = TextEditingController();

    // 2️⃣ NOVA FUNÇÃO PARA PEGAR A LOCALIZAÇÃO ATUAL DO GPS
    Future<Position> _determinarPosicao() async {
      bool servicoHabilitado;
      LocationPermission permissao;

      // Testar se o serviço de localização está ativo
      servicoHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicoHabilitado) {
        return Future.error('O serviço de localização está desativado.');
      }

      permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
        if (permissao == LocationPermission.denied) {
          return Future.error('As permissões de localização foram negadas.');
        }
      }
      
      if (permissao == LocationPermission.deniedForever) {
        return Future.error('As permissões estão negadas permanentemente.');
      } 

      // Se tudo estiver OK, pega a posição atual com alta precisão
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
    }

    // 3️⃣ FUNÇÃO DE ENVIO ATUALIZADA PARA ENVIAR LATITUDE E LONGITUDE
    void salvarDenunciaReal() async {
      if (descricaoController.text.isEmpty) {
        print("❌ Por favor, digite uma descrição antes de enviar!");
        return;
      }

      try {
        print("🛰️ Buscando coordenadas do GPS...");
        Position posicao = await _determinarPosicao();
        
        print("📍 Coordenadas encontradas: Lat: ${posicao.latitude}, Lon: ${posicao.longitude}");

        // Salvando no Firebase com a localização do GPS
        await FirebaseFirestore.instance.collection('denuncias').add({
          'titulo': 'Nova Ocorrência', 
          'descricao': descricaoController.text,
          'latitude': posicao.latitude,   // Salva a Latitude real
          'longitude': posicao.longitude, // Salva a Longitude real
          'data': DateTime.now(),
        });

        print("🔥 DENÚNCIA COM GPS SALVA NO FIREBASE!");
        descricaoController.clear();
        
        // Alerta visual de sucesso na tela
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denúncia enviada com sucesso com sua localização!')),
        );

      } catch (e) {
        print("❌ Erro ao obter localização ou salvar: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }

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
              onPressed: () {
                salvarDenunciaReal(); 
              }, 
              icon: const Icon(Icons.camera_alt),
              label: const Text('Enviar Denúncia com meu GPS'),
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
            TextField(
              controller: descricaoController, 
              decoration: const InputDecoration(
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