import 'package:flutter/foundation.dart';
import 'user_model.dart';
import '../mock/mock_data.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  String? _linkedBarberId; // for barber role
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get linkedBarberId => _linkedBarberId;

  bool get isClient => _currentUser?.role == UserRole.client;
  bool get isBarber => _currentUser?.role == UserRole.barber;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));

    final matches = MockData.users.where(
      (u) =>
          u['email'] == email.trim().toLowerCase() &&
          u['password'] == password,
    ).toList();

    _isLoading = false;

    if (matches.isEmpty) {
      notifyListeners();
      return 'E-mail ou senha incorretos.';
    }

    final u = matches.first;
    _currentUser = UserModel(
      id: u['id'],
      name: u['name'],
      email: u['email'],
      role: u['role'],
    );
    _linkedBarberId = u['barberId'] as String?;

    notifyListeners();
    return null;
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));

    final exists = MockData.users.any(
      (u) => u['email'] == email.trim().toLowerCase(),
    );

    if (exists) {
      _isLoading = false;
      notifyListeners();
      return 'Este e-mail já está cadastrado.';
    }

    final newU = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': UserRole.client,
    };
    MockData.users.add(newU);

    _currentUser = UserModel(
      id: newU['id'] as String,
      name: newU['name'] as String,
      email: newU['email'] as String,
      role: UserRole.client,
    );

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String?> sendPasswordReset(String email) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    _isLoading = false;
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    _linkedBarberId = null;
    notifyListeners();
  }
}
