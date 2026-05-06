import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import 'models/auth_provider.dart';
import 'models/app_data_provider.dart';
import 'models/cart_provider.dart';
import 'models/onboarding_provider.dart';
import 'core/routes/app_routes.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/main_shell.dart';
import 'screens/barber/barber_shell.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/barber_shop/presentation/screens/barber_shop_shell.dart';
import 'features/legacy/providers/legacy_auth_adapter.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/client/barbershop_detail_screen.dart';
import 'screens/client/service_detail_screen.dart';
import 'screens/client/booking_screen.dart';
import 'screens/client/product_detail_screen.dart';
import 'screens/client/cart_screen.dart';
import 'screens/client/review_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    // ProviderScope é o root do Riverpod — deve envolver tudo
    const ProviderScope(child: BarberHubApp()),
  );
}

class BarberHubApp extends ConsumerWidget {
  const BarberHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        provider.ChangeNotifierProvider(create: (_) => AppDataProvider()),
        provider.ChangeNotifierProvider(create: (_) => CartProvider()),
        provider.ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ],
      child: MaterialApp(
        title: 'Barber Hub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.login,
        onGenerateRoute: (settings) {
          Widget? page;
          switch (settings.name) {
            case AppRoutes.login:
              page = const LoginScreen();
              break;
            case AppRoutes.register:
              page = const RegisterScreen();
              break;
            case AppRoutes.forgotPassword:
              page = const ForgotPasswordScreen();
              break;
            case AppRoutes.home:
              page = const MainShell();
              break;
            case AppRoutes.barberHome:
              page = const BarberShell();
              break;
            case AppRoutes.adminHome:
              page = const AdminShell();
              break;
            case AppRoutes.barbershopDetail:
              page = const BarbershopDetailScreen();
              break;
            case AppRoutes.serviceDetail:
              page = const ServiceDetailScreen();
              break;
            case AppRoutes.booking:
              page = const BookingScreen();
              break;
            case AppRoutes.productDetail:
              page = const ProductDetailScreen();
              break;
            case AppRoutes.cart:
              page = const CartScreen();
              break;
            case AppRoutes.review:
              page = const ReviewScreen();
              break;
          }
          if (page == null) return null;
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (_, animation, __) => page!,
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity:
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 280),
          );
        },
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() => {
        // ── Entry ──────────────────────────────────────────────────────────────
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),

        // ── Cliente ────────────────────────────────────────────────────────────
        AppRoutes.home: (_) => const MainShell(),
        AppRoutes.barbershopDetail: (_) => const BarbershopDetailScreen(),
        AppRoutes.booking: (_) => const BookingScreen(),
        AppRoutes.productDetail: (_) => const ProductDetailScreen(),
        AppRoutes.cart: (_) => const CartScreen(),
        AppRoutes.review: (_) => const ReviewScreen(),
        AppRoutes.serviceDetail: (_) => const ServiceDetailScreen(),

        // ── Barbearia (novo) ──────────────────────────────────────────────────
        AppRoutes.barberShopHome: (_) => const BarberShopShell(),

        // ── Legacy ────────────────────────────────────────────────────────────
        AppRoutes.barberHome: (_) => const BarberShell(),
        AppRoutes.adminHome: (_) => const AdminShell(),
      };
}

/// Widget bridge: sincroniza o estado Riverpod (AuthNotifier) com o
/// LegacyAuthAdapter (ChangeNotifier), mantendo as telas legadas funcionando
/// sem precisar migrar para Riverpod.
///
/// Padrão: Observer + Adapter — o Riverpod é o Subject; o LegacyAuthAdapter
/// é o Observer; este widget é o mediador entre os dois sistemas.
class _AuthBridge extends ConsumerWidget {
  final Widget child;
  const _AuthBridge({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta mudanças no AuthNotifier e atualiza o adaptador legado
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      final adapter = context.read<LegacyAuthAdapter>();
      adapter.syncFromAuthState(next);
    });

    // Injeta callback de logout para que telas legadas possam deslogar
    // via Riverpod sem precisar de ref
    final adapter = context.read<LegacyAuthAdapter>();
    adapter.setLogoutCallback(
      () => ref.read(authNotifierProvider.notifier).logout(),
    );

    return child;
  }
}
