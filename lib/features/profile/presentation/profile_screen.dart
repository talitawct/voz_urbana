import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedState;
  String? _selectedCity;

  final List<String> _states = ['BA', 'SP', 'RJ', 'MG']; 
  final List<String> _cities = ['Salvador', 'Feira de Santana', 'São Paulo', 'Rio de Janeiro'];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final currentUser = AuthService.currentUser;

    _nameController.text = currentUser?.name ?? '';
    _phoneController.text = currentUser?.phone ?? '';

    _selectedState = currentUser?.state ?? 'BA';
    _selectedCity = currentUser?.city ?? 'Salvador';
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await AuthService.updateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        state: _selectedState ?? 'BA',
        city: _selectedCity ?? 'Salvador',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar alterações: ${e.message}')),
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
    final primaryColor = Theme.of(context).primaryColor; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: primaryColor,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Foto de perfil disponível em uma próxima versão.',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                AuthService.currentUser?.email ?? 'usuario@email.com',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              
              const SizedBox(height: 32),

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

              Row(
                children: [
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
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
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
