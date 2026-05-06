import 'package:barber_hub/core/constants/user_role.dart';
import 'package:barber_hub/core/errors/failures.dart';
import 'package:barber_hub/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:barber_hub/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:barber_hub/features/auth/domain/entities/user_entity.dart';
import 'package:barber_hub/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:barber_hub/shared/mock/mock_data.dart';

/// Implementação concreta do repositório de autenticação.
/// Orquestra o datasource mock (remoto) e o local (cache).
class AuthRepositoryImpl implements IAuthRepository {
  final AuthMockDatasource _mock;
  final AuthLocalDatasource _local;

  const AuthRepositoryImpl(this._mock, this._local);

  @override
  Future<(UserEntity?, Failure?)> login(String email, String password) async {
    final (user, failure) = await _mock.login(email, password);
    if (failure != null) return (null, failure);
    await _local.saveSession(user!);
    return (user, null);
  }

  @override
  Future<(UserEntity?, Failure?)> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final (user, failure) = await _mock.register(
      name: name,
      email: email,
      password: password,
    );
    if (failure != null) return (null, failure);

    // Persiste usuário registrado para sobreviver a reinicializações
    final json = user!.toJson();
    json['password'] = password; // necessário para re-autenticar offline
    await _local.saveRegisteredUser(json);
    await _local.saveSession(user);
    return (user, null);
  }

  @override
  Future<UserEntity?> tryAutoLogin() async {
    // 1. Restaura usuários cadastrados pelo app para a lista em memória
    final cachedUsers = await _local.loadRegisteredUsers();
    for (final cu in cachedUsers) {
      final email = cu['email'] as String?;
      if (email == null) continue;
      if (!MockData.users.any((u) => u['email'] == email)) {
        MockData.users.add({
          'id': cu['id'],
          'name': cu['name'],
          'email': cu['email'],
          'password': cu['password'],
          'role': UserRole.client,
        });
      }
    }

    // 2. Tenta restaurar sessão
    final session = await _local.loadSession();
    if (session == null) return null;

    // Valida que o usuário ainda existe
    final valid = MockData.users.any(
      (u) => u['id'] == session.id && u['email'] == session.email,
    );
    if (!valid) {
      await _local.clearSession();
      return null;
    }
    return session;
  }

  @override
  Future<void> logout() async => _local.clearSession();

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }
}
