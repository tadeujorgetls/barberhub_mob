import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barber_hub/core/constants/app_constants.dart';
import 'package:barber_hub/features/auth/data/models/user_model.dart';

/// Datasource local: persiste sessão e usuários registrados via SharedPreferences.
class AuthLocalDatasource {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ── Sessão ────────────────────────────────────────────────────────────────

  Future<void> saveSession(UserModel user) async {
    final p = await _prefs;
    await p.setString(AppConstants.sessionKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> loadSession() async {
    final p = await _prefs;
    final raw = p.getString(AppConstants.sessionKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(Map<String, dynamic>.from(
        jsonDecode(raw) as Map,
      ));
    } catch (_) {
      await p.remove(AppConstants.sessionKey);
      return null;
    }
  }

  Future<void> clearSession() async {
    final p = await _prefs;
    await p.remove(AppConstants.sessionKey);
  }

  // ── Usuários registrados ──────────────────────────────────────────────────

  Future<void> saveRegisteredUser(Map<String, dynamic> userJson) async {
    final p = await _prefs;
    final raw = p.getString(AppConstants.usersKey);
    final list = raw != null
        ? List<Map<String, dynamic>>.from(
            (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)),
          )
        : <Map<String, dynamic>>[];

    final idx = list.indexWhere((u) => u['id'] == userJson['id']);
    if (idx == -1) {
      list.add(userJson);
    } else {
      list[idx] = userJson;
    }
    await p.setString(AppConstants.usersKey, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> loadRegisteredUsers() async {
    final p = await _prefs;
    final raw = p.getString(AppConstants.usersKey);
    if (raw == null) return [];
    try {
      return List<Map<String, dynamic>>.from(
        (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
    } catch (_) {
      return [];
    }
  }
}
