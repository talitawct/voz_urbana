import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../navigation/main_navigation_page.dart';

class SignInScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;

  const SignInScreen({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _openApp();
    } on AuthException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithDemoProvider(String provider) async {
    setState(() => _isLoading = true);

    try {
      await AuthService.signInWithDemoProvider(provider);
      _openApp();
    } on AuthException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openApp() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigationPage(
          onThemeToggle: widget.onThemeToggle,
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Entrar'),
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
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Bem-vindo de volta!',
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Entre para continuar',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 42),
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
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Digite seu e-mail',
                    hintStyle: textTheme.bodySmall,
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Informe o e-mail';
                    if (!email.contains('@') || !email.contains('.')) {
                      return 'Informe um e-mail válido';
                    }
                    return null;
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
                  obscureText: _hidePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Digite sua senha',
                    hintStyle: textTheme.bodySmall,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _hidePassword = !_hidePassword);
                      },
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a senha';
                    }
                    if (value.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 50),
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0033A0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'ou entre com',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 15),
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _loginWithDemoProvider('google'),
                      icon: const Icon(Icons.g_mobiledata, size: 30),
                      label: const Text('Entrar com Google'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _loginWithDemoProvider('gov.br'),
                      icon: const Icon(Icons.account_balance),
                      label: const Text('Entrar com Gov.br'),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Use o usuário teste@vozurbana.com e senha 123456.',
                              ),
                            ),
                          );
                        },
                  child: const Text('Esqueci minha senha'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
