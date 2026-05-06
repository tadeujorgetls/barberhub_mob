/// Enumeração central de perfis de usuário do Barber Hub.
/// Definida em core/ para ser importada por qualquer feature sem criar
/// dependências circulares.
enum UserRole {
  /// Usuário cliente que agenda serviços
  client,

  /// Proprietário/gestor de uma barbearia (novo perfil - Prompt 1)
  barberShop,

  /// Barbeiro funcionário (legado)
  barber,

  /// Administrador do sistema (legado)
  admin,
}

extension UserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.client:
        return 'Cliente';
      case UserRole.barberShop:
        return 'Barbearia';
      case UserRole.barber:
        return 'Barbeiro';
      case UserRole.admin:
        return 'Administrador';
    }
  }

  bool get isClient => this == UserRole.client;
  bool get isBarberShop => this == UserRole.barberShop;
  bool get isBarber => this == UserRole.barber;
  bool get isAdmin => this == UserRole.admin;
}
