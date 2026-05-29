import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

/// Modelo de usuario: extiende [User] añadiendo la deserialización desde JSON del backend.
class UserModel extends User {
  const UserModel({
    super.id,
    required super.name,
    required super.surname,
    required super.email,
    super.phone,
    required super.role,
    super.photo,
    required super.active,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final roleRaw = map['role'];
    final UserRole role;
    if (roleRaw is String) {
      role = UserRole.fromCode(roleRaw);
    } else if (roleRaw is Map<String, dynamic>) {
      role = UserRole.fromMap(roleRaw);
    } else {
      role = UserRole.invitado;
    }

    return UserModel(
      id: map['id_user'] as int? ?? map['id'] as int? ?? 0,
      name: map['name'] as String,
      surname: map['surname'] as String? ?? '',
      email: map['email'] as String,
      phone: map['phone']?.toString(),
      role: role,
      photo: map['photo'] as String?,
      active: map['status'] as bool? ?? true,
    );
  }
}
