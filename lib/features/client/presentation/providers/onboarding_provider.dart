import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  static const _key = 'onboarding_done_v1';

  bool _shouldShow = false;
  bool _isReady = false;
  int _step = 0;

  bool get shouldShow => _shouldShow;
  bool get isReady => _isReady;
  int get step => _step;
  bool get isWelcomeStep => _step == 0;
  bool get isLastStep => _step == 5;

  Future<void> checkFirstAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_key) ?? false;
    _shouldShow = !done;
    _isReady = true;
    notifyListeners();
  }

  void nextStep() {
    if (_step < 5) {
      _step++;
      notifyListeners();
    } else {
      _complete();
    }
  }

  void skip() => _complete();

  Future<void> _complete() async {
    _shouldShow = false;
    _step = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Para dev/demo: reseta o onboarding
  Future<void> resetForDemo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _step = 0;
    _shouldShow = true;
    notifyListeners();
  }
}
