# Migração Provider → Riverpod

## Status da Migração

### ✅ Completo

- **AuthNotifier**: Completamente em Riverpod (`features/auth/presentation/providers/`)
- **auth_notifierProvider**: Implementado com `StateNotifierProvider`
- **Testes de Auth**: Criados em `test/auth_test.dart`
- **Testes de Rotas**: Criados em `test/routes_test.dart`
- **Refatoração de Rotas**: Convertido de `switch` para `Map`

### 🔄 Em Progresso

- **AppDataProvider** → Novo: `appDataProvider` em `lib/core/providers/app_providers.dart`
  - Mantém estado global de barbearias, serviços, barbeiros
  - Carrega dados do Supabase
  - Suporta seleção de barbearia

- **CartProvider** → Novo: `cartProvider` em `lib/core/providers/app_providers.dart`
  - Gerencia carrinho de compras
  - Suporta adicionar, remover, atualizar quantidade
  - Calcula total automaticamente

- **OnboardingProvider** → Novo: `onboardingProvider` em `lib/core/providers/app_providers.dart`
  - Rastreia conclusão do onboarding
  - Fornece métodos para marcar como completo/resetar

### ⏳ Próximos Passos

1. **Remover providers legados do main.dart**
   - Remover `AuthProvider` de `provider.MultiProvider`
   - Remover `AppDataProvider` de `provider.MultiProvider`
   - Remover `CartProvider` de `provider.MultiProvider`
   - Remover `OnboardingProvider` de `provider.MultiProvider`

2. **Atualizar telas para usar novos providers**
   - Screens legadas devem ser refatoradas para usar `ref.watch(appDataProvider)`
   - Screens legadas devem ser refatoradas para usar `ref.watch(cartProvider)`
   - Screens legadas devem ser refatoradas para usar `ref.watch(onboardingProvider)`

3. **LegacyAuthAdapter**
   - Pode ser mantido como bridge temporário
   - Deve sincronizar com `authNotifierProvider`
   - Será removido quando todas as telas forem migradas

4. **Testar tudo**
   - Rodar testes: `flutter test`
   - Validar navegação
   - Validar autenticação
   - Validar estados globais

## Estrutura de Providers

### Auth (Já Riverpod)
```dart
authNotifierProvider -> StateNotifierProvider<AuthNotifier, AuthState>
```

### App Data (Novo Riverpod)
```dart
appDataProvider -> StateNotifierProvider<AppDataNotifier, AppDataState>
```

### Cart (Novo Riverpod)
```dart
cartProvider -> StateNotifierProvider<CartNotifier, CartState>
```

### Onboarding (Novo Riverpod)
```dart
onboardingProvider -> StateNotifierProvider<OnboardingNotifier, OnboardingState>
```

## Melhorias Implementadas

1. **Remoção de duplicidade**: Deletado `lib/routes/app_routes.dart` (mantendo apenas `lib/core/routes/app_routes.dart`)
2. **Fallback para rotas**: Adicionada página `_NotFoundPage` para rotas inexistentes
3. **Mapa de rotas**: Convertido `switch` em `Map<String, WidgetBuilder>` no `onGenerateRoute`
4. **Separação de classes**: `MembershipPlansArgs` movido para arquivo próprio
5. **Testes reais**: Criados testes de rotas e autenticação

## Referências

- [Flutter Riverpod](https://riverpod.dev/)
- [StateNotifierProvider](https://riverpod.dev/docs/providers/state_notifier_provider)
- [Migration Guide](https://riverpod.dev/docs/migration/from_provider)
