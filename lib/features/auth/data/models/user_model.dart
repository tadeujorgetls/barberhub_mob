import 'package:barber_hub/core/constants/user_role.dart';
import 'package:barber_hub/features/auth/domain/entities/user_entity.dart';

/// Modelo de dados: estende [UserEntity] com serialização JSON.
/// Separa preocupações de domínio (entidade) das de infraestrutura (JSON).
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.linkedId,
  });

  factory UserModel.fromEntity(UserEntity e) => UserModel(
        id: e.id,
        name: e.name,
        email: e.email,
        role: e.role,
        linkedId: e.linkedId,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'client';
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.client,
    );
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: role,
      linkedId: json['linkedId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        if (linkedId != null) 'linkedId': linkedId,
      };
}
