import 'package:barber_hub/features/auth/domain/entities/user_entity.dart';

/// Estados do fluxo de autenticacao.
/// Usando sealed class do Dart 3 para exhaustive matching.
sealed class AuthState {
  const AuthState();
}

/// Estado inicial — antes de qualquer verificação
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Carregando (login, register, auto-login)
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Usuario autenticado com sucesso
final class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

/// Nao autenticado (sem sessao ou apos logout)
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Erro de autenticacao (credenciais invalidas, etc.)
final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
