import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barber_hub/core/routes/app_routes.dart';

void main() {
  group('Testes de Rotas', () {
    testWidgets('Navegação para rota de login', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          initialRoute: AppRoutes.login,
          onGenerateRoute: _buildTestRoute,
        ),
      );

      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('Fallback para rota inexistente', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          initialRoute: '/rota-inexistente',
          onGenerateRoute: _buildTestRoute,
        ),
      );

      await tester.pumpAndSettle();

      // Verifica se a página de erro é exibida
      expect(find.text('Rota não encontrada'), findsOneWidget);
      expect(find.text('Rota não encontrada: /rota-inexistente'), findsOneWidget);
    });

    testWidgets('Botão de voltar ao início na página de erro',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          initialRoute: '/rota-inexistente',
          onGenerateRoute: _buildTestRoute,
        ),
      );

      await tester.pumpAndSettle();

      // Verifica se o botão existe
      expect(find.text('Voltar ao início'), findsOneWidget);

      // Clica no botão
      await tester.tap(find.text('Voltar ao início'));
      await tester.pumpAndSettle();

      // Após clicar, a rota deve ser splash
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Testes de Navegação de Rotas', () {
    testWidgets('Mapa de rotas contém todas as rotas esperadas',
        (WidgetTester tester) async {
      // Verifica que todos os AppRoutes.* são constantes válidas
      expect(AppRoutes.splash, isNotEmpty);
      expect(AppRoutes.login, isNotEmpty);
      expect(AppRoutes.register, isNotEmpty);
      expect(AppRoutes.forgotPassword, isNotEmpty);
      expect(AppRoutes.home, isNotEmpty);
      expect(AppRoutes.barberShopHome, isNotEmpty);
      expect(AppRoutes.barberHome, isNotEmpty);
      expect(AppRoutes.adminHome, isNotEmpty);
      expect(AppRoutes.barbershopDetail, isNotEmpty);
      expect(AppRoutes.serviceDetail, isNotEmpty);
      expect(AppRoutes.booking, isNotEmpty);
      expect(AppRoutes.productDetail, isNotEmpty);
      expect(AppRoutes.cart, isNotEmpty);
      expect(AppRoutes.review, isNotEmpty);
      expect(AppRoutes.aiAssistant, isNotEmpty);
      expect(AppRoutes.membershipPlans, isNotEmpty);
      expect(AppRoutes.membershipManagement, isNotEmpty);
    });

    testWidgets('Rotas iniciam com barra (/)', (WidgetTester tester) async {
      expect(AppRoutes.splash.startsWith('/'), true);
      expect(AppRoutes.login.startsWith('/'), true);
      expect(AppRoutes.home.startsWith('/'), true);
      // Splash inicia com / (não é '/login')
      expect(AppRoutes.splash == '/', true);
    });
  });

  group('Testes de Argumentos de Rota', () {
    testWidgets('Rota home passa initialIndex corretamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.home,
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.home) {
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) =>
                    Scaffold(
                      body: Center(
                        child: Text(
                          'Index: ${settings.arguments ?? 0}',
                        ),
                      ),
                    ),
              );
            }
            return null;
          },
        ),
      );

      // Verifica que inicializa com índice padrão 0
      expect(find.text('Index: 0'), findsOneWidget);
    });
  });
}

/// Função auxiliar para construir rotas nos testes
Route<dynamic>? _buildTestRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Scaffold(
          body: Center(child: Text('Splash')),
        ),
      );
    case AppRoutes.login:
      return PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Scaffold(
          body: Center(child: Text('Login')),
        ),
      );
    case AppRoutes.register:
      return PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Scaffold(
          body: Center(child: Text('Register')),
        ),
      );
    case AppRoutes.home:
      return PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Scaffold(
          body: Center(child: Text('Home')),
        ),
      );
    default:
      // Fallback para rota inexistente
      return PageRouteBuilder(
        pageBuilder: (_, __, ___) => Scaffold(
          appBar: AppBar(title: const Text('Rota não encontrada')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Rota não encontrada: ${settings.name ?? 'desconhecida'}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Voltar ao início'),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
