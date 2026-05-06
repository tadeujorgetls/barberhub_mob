import 'package:barber_hub/features/auth/domain/repositories/i_auth_repository.dart';

/// Caso de uso: encerrar sessão.
class LogoutUseCase {
  final IAuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}
