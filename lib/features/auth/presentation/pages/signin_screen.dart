import 'package:flutter/material.dart';
import '../navigation/main_navigation_page.dart';
// Quando as versões do pubspec forem resolvidas, estas importações serão usadas:
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class SignInScreen extends StatelessWidget {
  final Function(bool) onThemeToggle;

  const SignInScreen({
    super.key,
    required this.onThemeToggle,
  });

  // 🍏 Função para Autenticação com o Google
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      // TODO: Implementar a chamada do Firebase Auth + Google Sign In
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      // final credential = GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      // await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conectando ao Google...')),
      );

      // Após o login com sucesso, redireciona para a Home:
      _navigateToHome(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar com o Google: $e')),
      );
    }
  }

  // 🏛️ Função para Autenticação com o Gov.br (OAuth 2.0)
  Future<void> _handleGovBrSignIn(BuildContext context) async {
    try {
      // TODO: Substituir pelas credenciais oficiais do ambiente de validação do Gov.br
      const url = 'https://sso.staging.validacao.gov.br/authorize?response_type=code&client_id=SEU_CLIENT_ID&scope=openid+govbr_confiabilidade&redirect_uri=vozurbana://auth';
      const callbackUrlScheme = 'vozurbana';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Redirecionando para o Gov.br...')),
      );

      // Fluxo do Web Auth para abrir a janela do Governo de forma segura:
      // final result = await FlutterWebAuth2.authenticate(url: url, callbackUrlScheme: callbackUrlScheme);
      // final code = Uri.parse(result).queryParameters['code'];
      // TODO: Enviar o 'code' para trocar pelo Access Token

      _navigateToHome(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar com Gov.br: $e')),
      );
    }
  }

  // Função auxiliar para navegar para a tela principal
  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigationPage(
          onThemeToggle: onThemeToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (isDark)
                        const BoxShadow(
                          color: Colors.white,
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    filterQuality: FilterQuality.high,
                  ),
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
              TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Digite seu e-mail',
                  hintStyle: textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Senha',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Digite sua senha',
                  hintStyle: textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _navigateToHome(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0033A0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
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
                    onPressed: () => _handleGoogleSignIn(context),
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
                    onPressed: () => _handleGovBrSignIn(context),
                    icon: const Icon(Icons.account_balance),
                    label: const Text('Entrar com Gov.br'),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {},
                child: const Text('Esqueci minha senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}