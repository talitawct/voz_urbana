class AppUser {
  AppUser({
    required this.name,
    required this.email,
    this.phone = '',
    this.state = 'BA',
    this.city = 'Salvador',
    this.provider = 'email',
  });

  String name;
  final String email;
  String phone;
  String state;
  String city;
  final String provider;
}

class AuthService {
  AuthService._();

  static final Map<String, ({AppUser user, String password})> _users = {
    'teste@vozurbana.com': (
      user: AppUser(
        name: 'Usuário de Teste',
        email: 'teste@vozurbana.com',
        provider: 'email',
      ),
      password: '123456',
    ),
  };

  static AppUser? _currentUser;

  static AppUser? get currentUser => _currentUser;

  static Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final normalizedEmail = email.trim().toLowerCase();
    final record = _users[normalizedEmail];

    if (record == null || record.password != password) {
      throw AuthException('E-mail ou senha inválidos.');
    }

    _currentUser = record.user;
    return record.user;
  }

  static Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String state = 'BA',
    String city = 'Salvador',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final normalizedEmail = email.trim().toLowerCase();

    if (_users.containsKey(normalizedEmail)) {
      throw AuthException('Já existe uma conta cadastrada com este e-mail.');
    }

    final user = AppUser(
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      state: state,
      city: city,
    );

    _users[normalizedEmail] = (user: user, password: password);
    _currentUser = user;

    return user;
  }

  static Future<AppUser> signInWithDemoProvider(String provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final normalizedProvider = provider.trim().toLowerCase();
    final user = AppUser(
      name: normalizedProvider == 'gov.br'
          ? 'Cidadão Gov.br'
          : 'Usuário Google',
      email: normalizedProvider == 'gov.br'
          ? 'cidadao.gov@vozurbana.com'
          : 'google.teste@vozurbana.com',
      provider: normalizedProvider,
    );

    _currentUser = user;
    return user;
  }

  static Future<void> updateProfile({
    required String name,
    required String phone,
    required String state,
    required String city,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final user = _currentUser;
    if (user == null) {
      throw AuthException('Nenhum usuário está autenticado.');
    }

    user.name = name.trim();
    user.phone = phone.trim();
    user.state = state;
    user.city = city;
  }

  static void signOut() {
    _currentUser = null;
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
