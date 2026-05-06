import 'package:barber_hub/features/auth/domain/entities/user_entity.dart';
import 'package:barber_hub/features/auth/domain/repositories/i_auth_repository.dart';

/// Caso de uso: verificar sessão persistida e restaurar login automaticamente.
class AutoLoginUseCase {
  final IAuthRepository _repository;
  const AutoLoginUseCase(this._repository);

  Future<UserEntity?> call() => _repository.tryAutoLogin();
}
