import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Chaves usadas no SharedPreferences.
/// Centralizadas aqui para evitar typos.
class _Keys {
  static const session = 'bh_session_v2';
  static const registeredUsers = 'bh_registered_users_v2';
}

/// Serviço de cache baseado em SharedPreferences.
/// Responsável por salvar/restaurar a sessão do usuário logado
/// e a lista de usuários cadastrados pelo app.
class CacheService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  CacheService._();
  static final CacheService instance = CacheService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Sessão ────────────────────────────────────────────────────────────────

  /// Persiste a sessão do usuário logado.
  Future<void> saveSession(Map<String, dynamic> sessionData) async {
    final p = await _p;
    await p.setString(_Keys.session, jsonEncode(sessionData));
  }

  /// Recupera a sessão salva, ou null se não existir.
  Future<Map<String, dynamic>?> loadSession() async {
    final p = await _p;
    final raw = p.getString(_Keys.session);
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      await p.remove(_Keys.session);
      return null;
    }
  }

  /// Remove a sessão salva (logout).
  Future<void> clearSession() async {
    final p = await _p;
    await p.remove(_Keys.session);
  }

  // ── Usuários registrados ──────────────────────────────────────────────────

  /// Salva a lista de usuários registrados via app (cadastros feitos pelo usuário).
  Future<void> saveRegisteredUsers(List<Map<String, dynamic>> users) async {
    final p = await _p;
    await p.setString(_Keys.registeredUsers, jsonEncode(users));
  }

  /// Recupera os usuários registrados anteriormente.
  Future<List<Map<String, dynamic>>> loadRegisteredUsers() async {
    final p = await _p;
    final raw = p.getString(_Keys.registeredUsers);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      await p.remove(_Keys.registeredUsers);
      return [];
    }
  }

  /// Adiciona ou atualiza um usuário na lista persistida.
  Future<void> upsertRegisteredUser(Map<String, dynamic> user) async {
    final users = await loadRegisteredUsers();
    final idx = users.indexWhere((u) => u['id'] == user['id']);
    if (idx == -1) {
      users.add(user);
    } else {
      users[idx] = user;
    }
    await saveRegisteredUsers(users);
  }

  // ── Utilitários ───────────────────────────────────────────────────────────

  /// Apaga todos os dados do cache do app (útil para dev/testes).
  Future<void> clearAll() async {
    final p = await _p;
    await p.remove(_Keys.session);
    await p.remove(_Keys.registeredUsers);
  }
}
