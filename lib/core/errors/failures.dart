/// Hierarquia de falhas do domínio.
/// Preferimos sealed classes a String genéricos para ter exhaustive matching.
sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Erro inesperado. Tente novamente.']);
}
