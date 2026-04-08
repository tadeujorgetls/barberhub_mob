import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Mock users database
  final List<Map<String, String>> _mockUsers = [
    {
      'id': '1',
      'name': 'Carlos Oliveira',
      'email': 'carlos@barberhub.com',
      'password': '123456',
    },
  ];

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final user = _mockUsers.where(
      (u) => u['email'] == email.trim().toLowerCase() && u['password'] == password,
    ).toList();

    _isLoading = false;

    if (user.isEmpty) {
      notifyListeners();
      return 'E-mail ou senha incorretos.';
    }

    _currentUser = UserModel(
      id: user.first['id']!,
      name: user.first['name']!,
      email: user.first['email']!,
    );

    notifyListeners();
    return null; // null = success
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    final exists = _mockUsers.any(
      (u) => u['email'] == email.trim().toLowerCase(),
    );

    if (exists) {
      _isLoading = false;
      notifyListeners();
      return 'Este e-mail já está cadastrado.';
    }

    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
    };

    _mockUsers.add(newUser);

    _currentUser = UserModel(
      id: newUser['id']!,
      name: newUser['name']!,
      email: newUser['email']!,
    );

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String?> sendPasswordReset(String email) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    _isLoading = false;
    notifyListeners();

    // Always succeed (simulated)
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
