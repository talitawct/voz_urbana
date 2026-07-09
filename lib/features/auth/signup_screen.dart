import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../core/auth/auth_service.dart';
import 'signin_screen.dart';
import 'success_screen.dart';

class SignUpScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;

  const SignUpScreen({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cpfController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cpfController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _acceptTerms = false;
  bool _isSaving = false;

  String? _selectedState;
  String? _selectedCity;

  static const Map<String, List<String>> _fallbackCities = {
    'BA': ['Salvador', 'Feira de Santana', 'Vitória da Conquista'],
    'SP': ['São Paulo', 'Campinas', 'Santos'],
    'RJ': ['Rio de Janeiro', 'Niterói', 'Petrópolis'],
    'MG': ['Belo Horizonte', 'Uberlândia', 'Contagem'],
  };

  List<String> states = _fallbackCities.keys.toList();
  List<String> cities = [];

  @override
void initState() {
  super.initState();
  carregarEstados();
}

Future<void> carregarEstados() async {
  try {
    final response = await http
        .get(
          Uri.parse(
            'https://servicodados.ibge.gov.br/api/v1/localidades/estados',
          ),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 || !mounted) return;

    final List dados = json.decode(response.body);

    dados.sort(
      (a, b) => a['sigla'].compareTo(b['sigla']),
    );

    setState(() {
      states = dados
          .map<String>((e) => e['sigla'].toString())
          .toList();
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      states = _fallbackCities.keys.toList();
    });
  }
}

Future<void> carregarCidades(String uf) async {
  try {
    final response = await http
        .get(
          Uri.parse(
            'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios',
          ),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 || !mounted) {
      _usarCidadesFallback(uf);
      return;
    }

    final List dados = json.decode(response.body);

    setState(() {
      cities = dados
          .map<String>((e) => e['nome'].toString())
          .toList();

      _selectedCity = null;
    });
  } catch (_) {
    _usarCidadesFallback(uf);
  }
}

void _usarCidadesFallback(String uf) {
  if (!mounted) return;

  setState(() {
    cities = _fallbackCities[uf] ?? const ['Cidade não informada'];
    _selectedCity = null;
  });
}

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Criar Conta'),
        backgroundColor: const Color(0xFF0033A0),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Padding(
			padding: const EdgeInsets.all(30),
			child: Form(
				key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Crie sua conta',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Preencha os dados abaixo',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),

             const SizedBox(height: 40),

Text(
  'Nome completo',
  style: textTheme.bodyMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 8),

TextFormField(
  controller: _nameController,
  keyboardType: TextInputType.name,
  textCapitalization: TextCapitalization.words,
  textInputAction: TextInputAction.next,

  inputFormatters: [
    _NameInputFormatter(),
  ],

  decoration: InputDecoration(
    border: const OutlineInputBorder(),
    hintText: 'Digite seu nome completo',
    hintStyle: textTheme.bodySmall,
  ),

  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu nome completo';
    }

    final nome = value.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (nome.split(' ').length < 2) {
      return 'Digite nome e sobrenome';
    }

    if (nome.length < 5) {
      return 'Nome muito curto';
    }

    return null;
  },
),

const SizedBox(height: 20),

              Text(
                'CPF',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
  controller: _cpfController,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    _CpfInputFormatter(),
  ],
  decoration: InputDecoration(
    border: const OutlineInputBorder(),
    hintText: '000.000.000-00',
    hintStyle: textTheme.bodySmall,
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Informe o CPF';
    }

    if (value.length != 14) {
      return 'CPF incompleto';
    }

    return null;
  },
),

              const SizedBox(height: 20),

              Text(
                'Data de nascimento',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
  controller: _birthController,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    _DateInputFormatter(),
  ],
  decoration: InputDecoration(
    border: const OutlineInputBorder(),
    hintText: 'DD/MM/AAAA',
    hintStyle: textTheme.bodySmall,
    suffixIcon: const Icon(Icons.calendar_month),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Informe a data de nascimento';
    }

    if (value.length != 10) {
      return 'Data incompleta';
    }

    return null;
  },
),

              const SizedBox(height: 20),

              Text(
                'E-mail',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Digite seu e-mail',
                ),
                validator: (value) {
					if (value == null || value.isEmpty) {
						return 'Informe o e-mail';
					}
					final emailRegex = RegExp(
						r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
					);
					if (!emailRegex.hasMatch(value.trim())) {
						return 'E-mail inválido';
					}
					return null;
				},
              ),

              const SizedBox(height: 20),

              Text(
                'Telefone (opcional)',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
  controller: _phoneController,
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    _PhoneInputFormatter(),
  ],
  decoration: InputDecoration(
    border: const OutlineInputBorder(),
    hintText: '(00) 00000-0000',
    hintStyle: textTheme.bodySmall,
  ),
  validator: (value) {
    if (value != null &&
        value.trim().isNotEmpty &&
        value.length != 15) {
      return 'Telefone incompleto';
    }

    return null;
  },
),

              const SizedBox(height: 20),

              Text(
                'Estado',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _selectedState,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Selecione o estado';
                  }
                  return null;
                },
                hint: const Text('Selecione o estado'),
                items: states.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedState = value;
                    _selectedCity = null;
                    cities.clear();
                  });

                  if (value != null) {
                    await carregarCidades(value);
                  }
                },
              ),

              const SizedBox(height: 20),

              Text(
                'Cidade',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Selecione a cidade';
                  }
                  return null;
                },
                hint: Text(
                  _selectedState == null
                    ? 'Selecione primeiro o estado'
                    : 'Selecione a cidade',
                ),
                isExpanded: true,
                items: cities.map((cidade) {
                  return DropdownMenuItem(
                    value: cidade,
                    child: Text(cidade),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              Text(
                'Senha',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Digite sua senha',
                  hintStyle: textTheme.bodySmall,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
				validator: (value) {
					if (value == null || value.isEmpty) {
						return 'Informe a senha';
					}
					if (value.length < 6) {
						return 'Mínimo 6 caracteres';
					}
					return null;
				},
              ),

              const SizedBox(height: 20),

              Text(
                'Confirmar senha',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Digite novamente sua senha',
                  hintStyle: textTheme.bodySmall,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                ),
				validator: (value) {
					if (value == null || value.isEmpty) {
						return 'Confirme sua senha';
					}
					if (value != _passwordController.text) {
						return 'As senhas não coincidem';
					}
					return null;
				},
              ),

              const SizedBox(height: 25),

              CheckboxListTile(
                value: _acceptTerms,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'Li e aceito os Termos de Uso e a Política de Privacidade.',
                ),
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 10),

              Text(
                'Seus dados pessoais (CPF, data de nascimento e telefone) não serão exibidos publicamente.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),

              const SizedBox(height: 35),

              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _acceptTerms && !_isSaving
                      ? () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() {
                            _isSaving = true;
                          });

                          try {
                            await AuthService.register(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              phone: _phoneController.text,
                              state: _selectedState ?? 'BA',
                              city: _selectedCity ?? 'Salvador',
                            );

                            if (!context.mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SuccessScreen(
                                  onThemeToggle: widget.onThemeToggle,
                                ),
                              ),
                            );
                          } on AuthException catch (error) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.message)),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSaving = false;
                              });
                            }
                          }
                        }
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0033A0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Cadastrar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já possui uma conta?',
                    style: textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignInScreen(
                            onThemeToggle: widget.onThemeToggle,
                          ),
                        ),
                      );
                    },
                    child: const Text('Entrar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
		  ),
        ),
      ),
    );
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {

    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    String formatted = '';

    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {

    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 8) {
      text = text.substring(0, 8);
    }

    String formatted = '';

    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {

    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    String formatted = '';

    for (int i = 0; i < text.length; i++) {
      if (i == 0) formatted += '(';
      if (i == 2) formatted += ') ';
      if (i == 7) formatted += '-';
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _NameInputFormatter extends TextInputFormatter {
  static const Set<String> _minusculas = {
    'da',
    'de',
    'do',
    'das',
    'dos',
    'e',
    'di',
    'du',
    'del',
    'della',
    'van',
    'von',
  };

  String _capitalizar(String palavra) {
    if (palavra.isEmpty) return palavra;

    final texto = palavra.toLowerCase();

    if (_minusculas.contains(texto)) {
      return texto;
    }

    // D'Ávila
    if (texto.contains("'")) {
      final partes = texto.split("'");

      return partes
          .map((parte) {
            if (parte.isEmpty) return parte;

            return parte[0].toUpperCase() +
                parte.substring(1);
          })
          .join("'");
    }

    // Maria-Clara
    if (texto.contains('-')) {
      final partes = texto.split('-');

      return partes
          .map((parte) {
            if (parte.isEmpty) return parte;

            return parte[0].toUpperCase() +
                parte.substring(1);
          })
          .join('-');
    }

    return texto[0].toUpperCase() +
        texto.substring(1);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {

    final cursor = newValue.selection.baseOffset;

    final palavras = newValue.text.split(' ');

    final resultado = palavras
        .map(_capitalizar)
        .join(' ');

    int novoCursor = cursor;

    if (novoCursor > resultado.length) {
      novoCursor = resultado.length;
    }

    return TextEditingValue(
      text: resultado,
      selection: TextSelection.collapsed(
        offset: novoCursor,
      ),
    );
  }
}
