import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Variáveis para Estado e Cidade (integrando com a lógica do IBGE do Cláudio)
  String? _selectedState;
  String? _selectedCity;

  // Lista fictícia para simular o comportamento. Quando você pegar o código do Cláudio,
  // basta plugar os mesmos métodos/Listas que ele usou na signup_screen.dart
  final List<String> _states = ['BA', 'SP', 'RJ', 'MG']; 
  final List<String> _cities = ['Salvador', 'Feira de Santana', 'São Paulo', 'Rio de Janeiro'];

  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = _currentUser?.displayName ?? '';
    _phoneController.text = _currentUser?.phoneNumber ?? '';
    
    // Valores iniciais padrão (você pode carregar do banco de dados futuramente)
    _selectedState = 'BA';
    _selectedCity = 'Salvador';
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _currentUser?.updateDisplayName(_nameController.text.trim());
      await _currentUser?.reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar alterações: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usando as cores do tema que o Cláudio definiu no main.dart para ficar harmonioso
    final primaryColor = Theme.of(context).primaryColor; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: primaryColor, // Sincronizado com o padrão do app
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // 🖼️ AVATAR DO USUÁRIO
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 70, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: primaryColor,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        onPressed: () {
                          // Aqui vai chamar a lógica de image_picker que o Cláudio implementou na report_screen.dart
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Abrindo a câmera/galeria com a lógica do Cláudio...')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                _currentUser?.email ?? 'usuario@email.com',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              
              const SizedBox(height: 32),
              
              // 📇 CAMPO: NOME COMPLETO
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira seu nome.';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // 📞 CAMPO: TELEFONE
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telefone de Contato',
                  hintText: '(71) 99999-9999',
                  prefixIcon: const Icon(Icons.phone_android_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              
              const SizedBox(height: 20),

              // 📍 INTEGRAÇÃO LOCALIDADE (Alinhado com a signup_screen do seu colega)
              Row(
                children: [
                  // Estado (UF)
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: InputDecoration(
                        labelText: 'UF',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _states.map((state) {
                        return DropdownMenuItem(value: state, child: Text(state));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value;
                          // Aqui você chama a função do Cláudio que atualiza as cidades com base no estado escolhido
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Cidade
                  Expanded(
                    flex: 5,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: InputDecoration(
                        labelText: 'Cidade',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _cities.map((city) {
                        return DropdownMenuItem(value: city, child: Text(city));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // 💾 BOTÃO DE SALVAR ALTERAÇÕES
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfileChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Salvar Alterações',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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