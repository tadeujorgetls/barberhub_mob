# Guia de Migração — BarberHub Mobile

Documento de rastreamento da migração de `provider` (legado) para `flutter_riverpod`
e da estrutura `lib/screens/` para `lib/features/*/presentation/screens/`.

---

## Status atual

### Autenticação

| Tela | Caminho atual | Estado de migração |
|---|---|---|
| Splash | `lib/features/auth/presentation/screens/splash_screen.dart` | ✅ Riverpod |
| Login | `lib/features/auth/presentation/screens/login_screen.dart` | ✅ Riverpod |
| Register | `lib/screens/register_screen.dart` | ⏳ Legado (Provider) |
| Forgot Password | `lib/screens/forgot_password_screen.dart` | ⏳ Legado (Provider) |

### Área do cliente

| Tela | Caminho atual | Estado de migração |
|---|---|---|
| Main Shell | `lib/screens/main_shell.dart` | ⏳ Legado |
| Barbershop List | `lib/features/client/presentation/screens/` | ✅ Riverpod |
| Barbershop Detail | `lib/screens/client/barbershop_detail_screen.dart` | ⏳ Legado |
| Booking | `lib/screens/client/booking_screen.dart` | ⏳ Legado |
| Product Detail | `lib/screens/client/product_detail_screen.dart` | ⏳ Legado |
| Cart | `lib/screens/client/cart_screen.dart` | ⏳ Legado |
| Review | `lib/screens/client/review_screen.dart` | ⏳ Legado |
| Service Detail | `lib/screens/client/service_detail_screen.dart` | ⏳ Legado |

### Área da barbearia (proprietário)

| Tela | Caminho atual | Estado de migração |
|---|---|---|
| Barber Shop Shell | `lib/features/barber_shop/presentation/screens/` | ✅ Riverpod |
| Dashboard | `lib/features/barber_shop/presentation/screens/` | ✅ Riverpod |
| Agenda | `lib/features/barber_shop/presentation/screens/` | ✅ Riverpod |
| Barbeiros | `lib/features/barber_shop/presentation/screens/` | ✅ Riverpod |
| Serviços | `lib/features/barber_shop/presentation/screens/` | 🔧 Riverpod (placeholder) |
| Produtos | `lib/features/barber_shop/presentation/screens/` | ✅ Riverpod |
| Configurações | `lib/features/barber_shop/presentation/screens/` | ✅ Riverpod |

### Área legada (barbeiro funcionário / admin)

| Tela | Caminho atual | Estado de migração |
|---|---|---|
| Barber Shell | `lib/screens/barber/barber_shell.dart` | ⏳ Legado — usa LegacyAuthAdapter |
| Admin Shell | `lib/screens/admin/admin_shell.dart` | ⏳ Legado — usa LegacyAuthAdapter |

---

## Próximos passos para completar a migração

### Passo 1 — Migrar RegisterScreen e ForgotPasswordScreen

Criar as versões Riverpod em `lib/features/auth/presentation/screens/`:

```
lib/features/auth/presentation/screens/register_screen.dart
lib/features/auth/presentation/screens/forgot_password_screen.dart
```

Ambas devem usar `ref.read(authNotifierProvider.notifier)` no lugar de
`context.read<AuthProvider>()`.

Após concluído, em `lib/main.dart`:
1. Remover `import 'screens/register_screen.dart'` e `import 'screens/forgot_password_screen.dart'`
2. Adicionar `import 'features/auth/presentation/screens/register_screen.dart'`
3. Adicionar `import 'features/auth/presentation/screens/forgot_password_screen.dart'`
4. Remover `provider.ChangeNotifierProvider(create: (_) => AuthProvider())` do MultiProvider
5. Remover `import 'models/auth_provider.dart'`

### Passo 2 — Migrar telas do cliente

Mover cada tela de `lib/screens/client/` para
`lib/features/client/presentation/screens/`, substituindo `context.read<AppDataProvider>()`
por providers Riverpod correspondentes.

### Passo 3 — Migrar shells legados (barber/admin)

As telas em `lib/screens/barber/` e `lib/screens/admin/` já recebem estado via
`LegacyAuthAdapter` (ponte entre Riverpod e Provider, corrigida no ZIP 2).
A migração completa envolve remover a dependência do `LegacyAuthAdapter` e usar
`ref.watch(authNotifierProvider)` diretamente.

### Passo 4 — Implementar BarberShopServicesScreen

A tela existe em `lib/features/barber_shop/presentation/screens/barber_shop_services_screen.dart`
como placeholder. Implementar a listagem e CRUD de serviços usando o
`ShopManagementNotifier` existente (adicionar `GetServicesUseCase`,
`AddServiceUseCase`, `UpdateServiceUseCase`, `DeleteServiceUseCase`).

### Passo 5 — Remover lib/screens/ ao final

Quando todas as telas estiverem migradas, remover a pasta `lib/screens/` e as
referências remanescentes nos imports do `main.dart`.

---

## Padrão de bridge durante a migração

Enquanto telas legadas (Provider) coexistem com as novas (Riverpod), o
`LegacyAuthAdapter` serve como ponte:

```
AuthNotifier (Riverpod)
        │ ref.listen
        ▼
   _AuthBridge (widget na raiz)
        │ adapter.syncFromAuthState()
        ▼
LegacyAuthAdapter (ChangeNotifier)
        │ context.read<LegacyAuthAdapter>()
        ▼
  Telas legadas (barber, admin)
```

Não criar novos providers legados. Toda nova tela deve usar Riverpod.

---

_Atualizado em: maio/2026_
