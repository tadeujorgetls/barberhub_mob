/// Por que Riverpod?
///
/// - Compile-time safety: providers não podem ser acessados fora do
///   ProviderScope, eliminando erros de runtime comuns com Provider.
/// - Sem dependência de BuildContext para leitura/escrita de estado.
/// - Testabilidade: fácil substituição de dependências sem InheritedWidget.
/// - AsyncNotifier nativo + watch/listen/ref.invalidate sem boilerplate.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_hub/features/auth/domain/usecases/login_usecase.dart';
import 'package:barber_hub/features/auth/domain/usecases/register_usecase.dart';
import 'package:barber_hub/features/auth/domain/usecases/auto_login_usecase.dart';
import 'package:barber_hub/features/auth/domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final AutoLoginUseCase _autoLogin;
  final LogoutUseCase _logout;

  AuthNotifier({
    required LoginUseCase login,
    required RegisterUseCase register,
    required AutoLoginUseCase autoLogin,
    required LogoutUseCase logout,
  })  : _login = login,
        _register = register,
        _autoLogin = autoLogin,
        _logout = logout,
        super(const AuthInitial());

  // ── Auto-login ─────────────────────────────────────────────────────────────

  /// Chamado pelo SplashScreen. Retorna a rota inicial.
  Future<String> tryAutoLogin() async {
    state = const AuthLoading();
    try {
      final user = await _autoLogin();
      if (user != null) {
        state = AuthAuthenticated(user);
        return user.initialRoute;
      }
    } catch (_) {}
    state = const AuthUnauthenticated();
    return '/login';
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  /// Retorna null em sucesso, mensagem de erro em falha.
  Future<String?> login(String email, String password) async {
    state = const AuthLoading();
    final (user, failure) = await _login(email, password);
    if (failure != null) {
      state = AuthError(failure.message);
      return failure.message;
    }
    state = AuthAuthenticated(user!);
    return null;
  }

  // ── Register ───────────────────────────────────────────────────────────────

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AuthLoading();
    final (user, failure) = await _register(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (failure != null) {
      state = AuthError(failure.message);
      return failure.message;
    }
    state = AuthAuthenticated(user!);
    return null;
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _logout();
    state = const AuthUnauthenticated();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    // No estado atual apenas simula — em produção dispara AuthLoading etc.
    await Future.delayed(const Duration(milliseconds: 700));
  }

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }
}
