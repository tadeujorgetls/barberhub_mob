import 'package:barber_hub/core/constants/user_role.dart';
import 'package:barber_hub/core/errors/failures.dart';
import 'package:barber_hub/core/services/supabase_service.dart';
import 'package:barber_hub/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSupabaseDatasource {
  SupabaseClient? get _client => SupabaseService.client;

  bool get isConfigured => _client != null;

  Future<(UserModel?, Failure?)> login(String email, String password) async {
    final client = _client;
    if (client == null) {
      return (null, const AuthFailure('Supabase nao configurado.'));
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final authUser = response.user;
      if (authUser == null) {
        return (null, const AuthFailure('E-mail ou senha incorretos.'));
      }

      final profile = await _loadProfile(authUser.id);
      final user = _toUser(authUser, profile);
      final profileFailure = _validateProfile(user);
      if (profileFailure != null) return (null, profileFailure);

      return (user, null);
    } on AuthException catch (e) {
      return (null, AuthFailure(_authMessage(e.message)));
    } catch (_) {
      return (null, const UnknownFailure());
    }
  }

  Future<(UserModel?, Failure?)> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      return (null, const AuthFailure('Supabase nao configurado.'));
    }

    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': UserRole.client.name,
        },
      );
      final authUser = response.user;
      if (authUser == null) {
        return (null, const AuthFailure('Nao foi possivel criar a conta.'));
      }

      final profile = await _upsertProfile(
        id: authUser.id,
        name: name,
        email: email,
        role: UserRole.client,
      );
      return (_toUser(authUser, profile), null);
    } on AuthException catch (e) {
      return (null, AuthFailure(_authMessage(e.message)));
    } catch (_) {
      return (null, const UnknownFailure());
    }
  }

  Future<UserModel?> currentUser() async {
    final client = _client;
    final authUser = client?.auth.currentUser;
    if (client == null || authUser == null) return null;

    final profile = await _loadProfile(authUser.id);
    final user = _toUser(authUser, profile);
    if (_validateProfile(user) != null) return null;
    return user;
  }

  Future<void> logout() async {
    final client = _client;
    if (client == null) return;
    await client.auth.signOut();
  }

  Future<Failure?> sendPasswordReset(String email) async {
    final client = _client;
    if (client == null) return const AuthFailure('Supabase nao configurado.');

    try {
      await client.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return AuthFailure(_authMessage(e.message));
    } catch (_) {
      return const UnknownFailure();
    }
  }

  Future<Map<String, dynamic>?> _loadProfile(String id) async {
    final client = _client;
    if (client == null) return null;

    return client.from('profiles').select().eq('id', id).maybeSingle();
  }

  Future<Map<String, dynamic>> _upsertProfile({
    required String id,
    required String name,
    required String email,
    required UserRole role,
  }) async {
    final client = _client!;
    final data = {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    return client.from('profiles').upsert(data).select().single();
  }

  UserModel _toUser(User user, Map<String, dynamic>? profile) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final roleName =
        profile?['role'] as String? ?? metadata['role'] as String? ?? 'client';
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => UserRole.client,
    );

    return UserModel(
      id: user.id,
      name: profile?['name'] as String? ??
          metadata['name'] as String? ??
          user.email?.split('@').first ??
          'Usuario',
      email: profile?['email'] as String? ?? user.email ?? '',
      role: role,
      linkedId: profile?['linked_id'] as String?,
    );
  }

  Failure? _validateProfile(UserModel user) {
    final linkedId = user.linkedId?.trim() ?? '';
    if (user.role.isBarberShop && linkedId.isEmpty) {
      return const AuthFailure(
        'Perfil de barbearia sem vinculo. Verifique o linked_id no Supabase.',
      );
    }
    if (user.role.isBarber && linkedId.isEmpty) {
      return const AuthFailure(
        'Perfil de barbeiro sem vinculo. Verifique o linked_id no Supabase.',
      );
    }
    return null;
  }

  String _authMessage(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (normalized.contains('already registered') ||
        normalized.contains('already exists')) {
      return 'Este e-mail ja esta cadastrado.';
    }
    if (normalized.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (normalized.contains('rate limit')) {
      return 'Muitas tentativas em pouco tempo. Aguarde alguns minutos.';
    }
    return message;
  }
}
