import 'package:flutter/material.dart';
import 'signin_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final Function(bool) onThemeToggle;

  const WelcomeScreen({
    super.key,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (isDark)
                      const BoxShadow(
                        color: Colors.white,
                        blurRadius: 25,
                        spreadRadius: 4,
                      ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 300,
                  filterQuality: FilterQuality.high,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignInScreen(
                          onThemeToggle: onThemeToggle,
                        ),
                      ),
                    );
                  },
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

              const SizedBox(height: 20),

              Text(
                'Não tem uma conta?',
                style: textTheme.bodyMedium,
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignInScreen(
                        onThemeToggle: onThemeToggle,
                      ),
                    ),
                  );
                },
                child: const Text('Cadastrar Grátis'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}