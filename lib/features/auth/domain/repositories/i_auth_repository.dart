import 'package:barber_hub/core/errors/failures.dart';
import 'package:barber_hub/features/auth/domain/entities/user_entity.dart';

/// Contrato do repositório de autenticação.
/// O domínio define a interface; a camada data implementa.
abstract interface class IAuthRepository {
  /// Autentica com email/senha. Retorna null em erro, lança [AuthFailure].
  Future<(UserEntity?, Failure?)> login(String email, String password);

  /// Cria nova conta.
  Future<(UserEntity?, Failure?)> register({
    required String name,
    required String email,
    required String password,
  });

  /// Tenta restaurar sessão salva. Null se não houver sessão.
  Future<UserEntity?> tryAutoLogin();

  /// Encerra sessão.
  Future<void> logout();

  /// Simula envio de link de redefinição de senha.
  Future<void> sendPasswordReset(String email);
}
