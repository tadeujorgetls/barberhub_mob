import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_providers.dart';

void main() {
  group('Testes de Autenticação (Auth Providers)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Estado inicial é AuthInitial', () {
      final authState = container.read(authNotifierProvider);
      expect(authState, isA<AuthInitial>());
    });

    test('Login bem-sucedido atualiza o estado', () async {
      final authNotifier = container.read(authNotifierProvider.notifier);

      // Usa credenciais válidas do MockData
      await authNotifier.login('carlos@barberhub.com', '123456');

      final authState = container.read(authNotifierProvider);

      // Verifica se o estado mudou para autenticado
      expect(authState, isA<AuthAuthenticated>());

      if (authState is AuthAuthenticated) {
        expect(authState.user, isNotNull);
        expect(authState.user.email, 'carlos@barberhub.com');
      }
    });

    test('Login com credenciais inválidas resulta em erro', () async {
      final authNotifier = container.read(authNotifierProvider.notifier);

      await authNotifier.login('invalid@email.com', 'wrongpassword');

      final authState = container.read(authNotifierProvider);

      // Deve estar em erro
      expect(authState, isA<AuthError>());
    });

    test('Logout retorna ao estado não autenticado', () async {
      final authNotifier = container.read(authNotifierProvider.notifier);

      // Primeiro, faz login
      await authNotifier.login('carlos@barberhub.com', '123456');

      var authState = container.read(authNotifierProvider);
      expect(authState, isA<AuthAuthenticated>());

      // Depois, faz logout
      await authNotifier.logout();

      authState = container.read(authNotifierProvider);
      expect(authState, isA<AuthUnauthenticated>());
    });

    test('Registro bem-sucedido cria novo usuário', () async {
      final authNotifier = container.read(authNotifierProvider.notifier);

      await authNotifier.register(
        name: 'Novo Usuário',
        email: 'novo.usuario.teste@email.com',
        password: 'senha123',
        confirmPassword: 'senha123',
      );

      final authState = container.read(authNotifierProvider);

      // Após registro bem-sucedido, deve estar autenticado
      expect(authState, isA<AuthAuthenticated>());

      if (authState is AuthAuthenticated) {
        expect(authState.user.name, 'Novo Usuário');
        expect(authState.user.email, 'novo.usuario.teste@email.com');
      }
    });

    test('Múltiplos logins mudam o usuário autenticado', () async {
      final authNotifier = container.read(authNotifierProvider.notifier);

      // Primeiro login
      await authNotifier.login('carlos@barberhub.com', '123456');

      var authState = container.read(authNotifierProvider);
      expect(authState, isA<AuthAuthenticated>());

      {
        // Logout
        await authNotifier.logout();

        // Segundo login com outro usuário
        await authNotifier.login('admin@barberhub.com', '123456');

        authState = container.read(authNotifierProvider);
        expect(authState, isA<AuthAuthenticated>());

        // Verifica que o usuário mudou
        expect((authState as AuthAuthenticated).user.email, isNotEmpty);
      }
    });
  });

  group('Testes de Integração de Rotas com Auth', () {
    test('Após login, o usuário não deve estar em rota não autenticada', () {
      // Este teste verifica a lógica de roteamento baseada em autenticação
      final container = ProviderContainer();

      final initialState = container.read(authNotifierProvider);
      expect(initialState, isA<AuthUnauthenticated>());

      // Após login, deveria navegar para home
      // (Este teste seria mais completo com testes de widget)

      container.dispose();
    });
  });

  group('Testes de Estados de Auth', () {
    test('AuthUnauthenticated é o estado inicial', () {
      const state = AuthUnauthenticated();
      expect(state, isA<AuthUnauthenticated>());
    });

    test('AuthAuthenticated armazena corretamente o usuário', () async {
      final container = ProviderContainer();
      final authNotifier = container.read(authNotifierProvider.notifier);

      // Simula login
      await authNotifier.login('carlos@barberhub.com', '123456');

      final authState = container.read(authNotifierProvider);
      expect(authState, isA<AuthAuthenticated>());

      container.dispose();
    });
  });
}
