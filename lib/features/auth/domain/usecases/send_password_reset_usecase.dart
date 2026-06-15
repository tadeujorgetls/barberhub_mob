import 'package:barber_hub/core/errors/failures.dart';
import 'package:barber_hub/features/auth/domain/repositories/i_auth_repository.dart';

/// Caso de uso: solicitar redefinicao de senha por e-mail.
class SendPasswordResetUseCase {
  final IAuthRepository _repository;
  const SendPasswordResetUseCase(this._repository);

  Future<Failure?> call(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      return const ValidationFailure('Informe o e-mail.');
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(normalizedEmail)) {
      return const ValidationFailure('E-mail invalido.');
    }
    return _repository.sendPasswordReset(normalizedEmail);
  }
}
