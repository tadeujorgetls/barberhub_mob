class AppConstants {
  AppConstants._();

  static const String appName = 'Barber Hub';

  // RISCO #7 CORRIGIDO: appVersion estava em '3.0.0', divergindo do
  // pubspec.yaml que declara version: 2.2.0+5. Versão sincronizada.
  //
  // RECOMENDAÇÃO FUTURA: substituir esta constante pelo pacote
  // `package_info_plus` (adicionar em pubspec.yaml e executar flutter pub get):
  //
  //   import 'package:package_info_plus/package_info_plus.dart';
  //
  //   final info = await PackageInfo.fromPlatform();
  //   final version = '${info.version}+${info.buildNumber}'; // ex: "2.2.0+5"
  //
  // Isso lê a versão diretamente do pubspec em runtime, eliminando a
  // necessidade de manter esta constante sincronizada manualmente.
  static const String appVersion = '2.2.0+5';

  // Cache keys
  static const String sessionKey    = 'bh_session_v2';
  static const String usersKey      = 'bh_registered_users_v2';
  static const String onboardingKey = 'onboarding_done_v1';
}
