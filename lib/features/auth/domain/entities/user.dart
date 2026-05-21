import 'role.dart';

class User {
  final int? id;
  final String name;
  final String surname;
  final String email;
  final String? phone;
  final UserRole role;
  final String? photo;
  final bool active;

  const User({
    this.id,
    required this.name,
    required this.surname,
    required this.email,
    this.phone,
    required this.role,
    this.photo,
    required this.active,
  });

  // Crea un Usuario a partir del JSON del backend.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id_user'] ?? 0 as int?,
      name: map['name'] as String,
      surname: map['surname'] as String? ?? '',
      email: map['email'] as String,
      phone: map['phone']?.toString(),
      role: UserRole.fromString(map['role'] as String? ?? 'GUEST'),
      photo: map['photo'] as String?,
      active: map['status'] as bool? ?? true,
    );
  }

  // Crea un nuevo usuario a partir del actual, permitiendo modificar algunos campos.
  User copyWith({
    String? name,
    String? surname,
    String? email,
    String? phone,
    UserRole? role,
    String? photo,
    bool? active,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photo: photo ?? this.photo,
      active: active ?? this.active,
    );
  }

  // Comprueba si el usuario tiene un rol específico.
  bool tieneRol(UserRole tipoRol) {
    if (role == tipoRol) {
      return true;
    } else {
      return false;
    }
  }

  // Convierte el usuario a un mapa para enviar al backend.
  Map<String, dynamic> toMap() => {
    'name': name,
    'surname': surname,
    'email': email,
    'phone': phone,
    'photo': photo,
    'status': active,
  };
}
