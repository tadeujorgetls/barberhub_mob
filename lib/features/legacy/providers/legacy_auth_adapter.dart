import 'package:flutter/foundation.dart';
import 'package:barber_hub/features/auth/domain/entities/user_entity.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_state.dart';

/// Adaptador de compatibilidade para as telas legadas (barbeiro funcionário,
/// admin) que ainda utilizam o padrão Provider/ChangeNotifier.
///
/// É sincronizado com o [AuthNotifier] (Riverpod) através do widget
/// [AuthBridge] montado na raiz da árvore no main.dart.
///
/// Padrão: Bridge (GoF) — traduz a interface Riverpod para a interface
/// ChangeNotifier consumida pelas telas legadas sem exigir migração delas.
class LegacyAuthAdapter extends ChangeNotifier {
  UserEntity? _user;
  bool _isLoading = false;
  Future<void> Function()? _logoutCallback;

  // ── Interface pública compatível com o antigo AuthProvider ──────────────

  UserEntity? get currentUser => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get linkedBarberId => _user?.linkedId;

  bool get isClient    => _user?.isClient ?? false;
  bool get isBarber    => _user?.isBarber ?? false;
  bool get isAdmin     => _user?.isAdmin ?? false;
  bool get isBarberShop => _user?.isBarberShop ?? false;

  // ── Sincronização com Riverpod ──────────────────────────────────────────

  void syncFromAuthState(AuthState state) {
    _isLoading = state is AuthLoading;
    _user = state is AuthAuthenticated ? state.user : null;
    notifyListeners();
  }

  void setLogoutCallback(Future<void> Function() fn) {
    _logoutCallback = fn;
  }

  Future<void> logout() async {
    await _logoutCallback?.call();
    _user = null;
    notifyListeners();
  }
}
