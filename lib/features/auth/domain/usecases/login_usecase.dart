import 'package:barber_hub/core/errors/failures.dart';
import 'package:barber_hub/features/auth/domain/entities/user_entity.dart';
import 'package:barber_hub/features/auth/domain/repositories/i_auth_repository.dart';

/// Caso de uso: autenticar usuário.
/// Encapsula a regra de negócio de validação antes de delegar ao repositório.
class LoginUseCase {
  final IAuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<(UserEntity?, Failure?)> call(String email, String password) async {
    if (email.trim().isEmpty) {
      return (null, const ValidationFailure('Informe o e-mail.'));
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim())) {
      return (null, const ValidationFailure('E-mail inválido.'));
    }
    if (password.isEmpty) {
      return (null, const ValidationFailure('Informe a senha.'));
    }
    return _repository.login(email.trim().toLowerCase(), password);
  }
}
