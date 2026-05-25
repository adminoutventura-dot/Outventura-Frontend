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
    return UserModel(
      id: map['id_user'] as int? ?? 0,
      name: map['name'] as String,
      surname: map['surname'] as String? ?? '',
      email: map['email'] as String,
      phone: map['phone']?.toString(),
      role: map['role'] != null
          ? UserRole.fromMap(map['role'] as Map<String, dynamic>)
          : UserRole.invitado,
      photo: map['photo'] as String?,
      active: map['status'] as bool? ?? true,
    );
  }
}
