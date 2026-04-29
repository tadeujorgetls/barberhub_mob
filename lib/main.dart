import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/auth_provider.dart';
import 'models/app_data_provider.dart';
import 'models/cart_provider.dart';
import 'models/onboarding_provider.dart';
import 'routes/app_routes.dart';
import 'screens/login_screen.dart';
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
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const BarberHubApp());
}

class BarberHubApp extends StatelessWidget {
  const BarberHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppDataProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
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
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(
              opacity: CurvedAnimation(
                  parent: animation, curve: Curves.easeOut),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 280),
          );
        },
      ),
    );
  }
}
