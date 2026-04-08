# Barber Hub 💈

App mobile de barbearia construído com Flutter — estrutura inicial com fluxo de autenticação completo.

---

## 🚀 Como rodar

```bash
# 1. Instale as dependências
flutter pub get

# 2. Execute o app
flutter run
```

> Requer Flutter 3.10+ e Dart 3.0+

---

## 🗂️ Estrutura do projeto

```
lib/
├── main.dart                      # Entry point + rotas
│
├── theme/
│   └── app_theme.dart             # Tema escuro (cores, tipografia, componentes)
│
├── models/
│   ├── user_model.dart            # Modelo de usuário
│   └── auth_provider.dart        # Estado de autenticação (Provider)
│
├── routes/
│   └── app_routes.dart            # Constantes de rotas
│
├── widgets/
│   └── app_widgets.dart           # Componentes reutilizáveis
│       ├── BarberLogo             # Ícone de tesoura (CustomPainter)
│       ├── BrandHeader            # Cabeçalho com logo + nome
│       ├── AppTextField           # Campo de texto estilizado
│       ├── PrimaryButton          # Botão principal com loading
│       ├── DividerWithText        # Divider com label
│       └── GoldAccent             # Linha decorativa dourada
│
└── screens/
    ├── login_screen.dart          # Tela de login
    ├── register_screen.dart       # Tela de cadastro
    ├── forgot_password_screen.dart # Recuperação de senha
    └── home_screen.dart           # Home (placeholder)
```

---

## 🔑 Credenciais de teste

| Campo  | Valor                    |
|--------|--------------------------|
| E-mail | carlos@barberhub.com     |
| Senha  | 123456                   |

---

## 🎨 Design

- **Tema**: Dark com acentos dourados
- **Tipografia**: Cormorant Garamond (display) + Jost (body)
- **Paleta**: Preto profundo `#0A0A0A` + Dourado `#D4A853`
- **Animações**: Fade + Slide ao entrar nas telas, loading states nos botões

---

## 🔧 Dependências

| Pacote         | Versão  | Uso                          |
|----------------|---------|------------------------------|
| `provider`     | ^6.1.1  | Gerenciamento de estado       |
| `google_fonts` | ^6.1.0  | Tipografia (Jost + Cormorant) |

---

## 📱 Fluxo de telas

```
Login ──────────────────────→ Home
  │                              ↑
  ├──→ Cadastro ────────────────┘
  │
  └──→ Recuperar Senha
```
