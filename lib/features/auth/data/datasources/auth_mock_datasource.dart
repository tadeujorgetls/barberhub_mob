import 'package:barber_hub/core/constants/user_role.dart';
import 'package:barber_hub/core/errors/failures.dart';
import 'package:barber_hub/features/auth/data/models/user_model.dart';
import 'package:barber_hub/shared/mock/mock_data.dart';

/// Datasource que simula um backend remoto usando dados em memória.
/// Injeta os usuários do MockData. Simula latência de rede.
class AuthMockDatasource {
  Future<(UserModel?, Failure?)> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final match = MockData.users.where(
      (u) => u['email'] == email && u['password'] == password,
    ).firstOrNull;

    if (match == null) {
      return (null, const AuthFailure('E-mail ou senha incorretos.'));
    }

    return (
      UserModel(
        id: match['id'] as String,
        name: match['name'] as String,
        email: match['email'] as String,
        role: match['role'] as UserRole,
        linkedId: match['linkedId'] as String?,
      ),
      null,
    );
  }

  Future<(UserModel?, Failure?)> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final exists = MockData.users.any((u) => u['email'] == email);
    if (exists) {
      return (null, const AuthFailure('Este e-mail já está cadastrado.'));
    }

    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'email': email,
      'password': password,
      'role': UserRole.client,
    };
    MockData.users.add(newUser);

    return (
      UserModel(
        id: newUser['id'] as String,
        name: newUser['name'] as String,
        email: newUser['email'] as String,
        role: UserRole.client,
      ),
      null,
    );
  }
}
