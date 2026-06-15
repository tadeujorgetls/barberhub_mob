/// Por que Riverpod?
///
/// - Compile-time safety: providers nao podem ser acessados fora do
///   ProviderScope, eliminando erros de runtime comuns com Provider.
/// - Sem dependencia de BuildContext para leitura/escrita de estado.
/// - Testabilidade: facil substituicao de dependencias sem InheritedWidget.
/// - AsyncNotifier nativo + watch/listen/ref.invalidate sem boilerplate.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_hub/features/auth/domain/usecases/login_usecase.dart';
import 'package:barber_hub/features/auth/domain/usecases/register_usecase.dart';
import 'package:barber_hub/features/auth/domain/usecases/auto_login_usecase.dart';
import 'package:barber_hub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:barber_hub/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final AutoLoginUseCase _autoLogin;
  final LogoutUseCase _logout;
  final SendPasswordResetUseCase _sendPasswordReset;

  AuthNotifier({
    required LoginUseCase login,
    required RegisterUseCase register,
    required AutoLoginUseCase autoLogin,
    required LogoutUseCase logout,
    required SendPasswordResetUseCase sendPasswordReset,
  })  : _login = login,
        _register = register,
        _autoLogin = autoLogin,
        _logout = logout,
        _sendPasswordReset = sendPasswordReset,
        super(const AuthInitial());

  /// Chamado pelo SplashScreen. Retorna a rota inicial.
  Future<String> tryAutoLogin() async {
    state = const AuthLoading();
    try {
      final user = await _autoLogin();
      if (user != null) {
        state = AuthAuthenticated(user);
        return user.initialRoute;
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AuthNotifier.tryAutoLogin] Erro ao restaurar sessao: $e');
        debugPrint(st.toString());
      }
    }
    state = const AuthUnauthenticated();
    return '/login';
  }

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

  Future<void> logout() async {
    await _logout();
    state = const AuthUnauthenticated();
  }

  Future<String?> sendPasswordReset(String email) async {
    state = const AuthLoading();
    final failure = await _sendPasswordReset(email);
    if (failure != null) {
      state = AuthError(failure.message);
      return failure.message;
    }
    state = const AuthUnauthenticated();
    return null;
  }

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }
}
