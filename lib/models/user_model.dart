enum UserRole { client, barber, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.client,
  });

  String get roleLabel {
    switch (role) {
      case UserRole.client:
        return 'Cliente';
      case UserRole.barber:
        return 'Barbeiro';
      case UserRole.admin:
        return 'Administrador';
    }
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
