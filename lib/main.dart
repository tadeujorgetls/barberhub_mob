import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import 'models/auth_provider.dart';
import 'models/app_data_provider.dart';
import 'models/cart_provider.dart';
import 'models/onboarding_provider.dart';
import 'core/routes/app_routes.dart';
import 'core/services/supabase_service.dart';

// MELHORIA #12: LoginScreen migrado para a versÃ£o Riverpod em features/auth.
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/barber_shop/presentation/screens/barber_shop_shell.dart';
import 'features/legacy/providers/legacy_auth_adapter.dart';

// Membership feature
import 'features/membership/presentation/screens/client/membership_plans_screen.dart';
import 'features/membership/presentation/screens/barber_shop/membership_management_screen.dart';

// Telas legadas ainda em migraÃ§Ã£o para Riverpod
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/main_shell.dart';
import 'screens/barber/barber_shell.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/client/barbershop_detail_screen.dart';
import 'screens/client/service_detail_screen.dart';
import 'screens/client/booking_screen.dart';
import 'screens/client/product_detail_screen.dart';
import 'screens/client/cart_screen.dart';
import 'screens/client/review_screen.dart';
import 'screens/client/ai_assistant_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await SupabaseService.initialize();
  runApp(
    const ProviderScope(child: BarberHubApp()),
  );
}

class BarberHubApp extends ConsumerWidget {
  const BarberHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return provider.MultiProvider(
      providers: [
        // MELHORIA #12 â€” TODO: remover apÃ³s migrar RegisterScreen e
        // ForgotPasswordScreen para Riverpod.
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        provider.ChangeNotifierProvider(create: (_) => AppDataProvider()),
        provider.ChangeNotifierProvider(create: (_) => CartProvider()),
        provider.ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        // BUG #2 CORRIGIDO: LegacyAuthAdapter injetado no MultiProvider.
        provider.ChangeNotifierProvider(create: (_) => LegacyAuthAdapter()),
      ],
      // BUG #2 CORRIGIDO: _AuthBridge inserido na Ã¡rvore de widgets.
      child: _AuthBridge(
        child: MaterialApp(
          title: 'Barber Hub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: (settings) {
            Widget? page;
            switch (settings.name) {
              case AppRoutes.splash:
                page = const SplashScreen();
                break;
              // MELHORIA #12: LoginScreen Riverpod.
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
                final initialIndex =
                    settings.arguments is int ? settings.arguments as int : 0;
                page = MainShell(initialIndex: initialIndex);
                break;
              // BUG #1 CORRIGIDO: rota barberShopHome adicionada.
              case AppRoutes.barberShopHome:
                page = const BarberShopShell();
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
              case AppRoutes.aiAssistant:
                page = const AiAssistantScreen();
                break;

              // â”€â”€ Membership â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              case AppRoutes.membershipPlans:
                page = const MembershipPlansScreen();
                break;
              case AppRoutes.membershipManagement:
                page = const MembershipManagementScreen();
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
      ),
    );
  }

  // MELHORIA #8: _buildRoutes() removido â€” era cÃ³digo morto.
}

class _AuthBridge extends ConsumerWidget {
  final Widget child;
  const _AuthBridge({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      final adapter = context.read<LegacyAuthAdapter>();
      adapter.syncFromAuthState(next);
    });
    final adapter = context.read<LegacyAuthAdapter>();
    adapter.setLogoutCallback(
      () => ref.read(authNotifierProvider.notifier).logout(),
    );
    return child;
  }
}
