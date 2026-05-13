import 'role.dart';

class User {
  final int id;
  final String name;
  final String surname;
  final String email;
  final String? phone;
  final UserRole role;
  final String? photo;
  final bool active;

  const User({
    required this.id,
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
    // Guardar el valor de 'role' sin importar su formato.
    final dynamic roleValue = map['role'];

    // Comprueba si el campo 'role' es un String o un Map, y si es un Map, extrae el 'code'.
    final String? roleCode = roleValue is String
        ? roleValue
        : (roleValue is Map<String, dynamic> ? roleValue['code'] as String? : null);
    final String roleText = roleCode ?? 'GUEST';
    return User(
      id: (map['id_user'] ?? map['id']) as int,
      name: map['name'] as String,
      surname: map['surname'] as String,
      email: map['email'] as String,
      phone: map['phone']?.toString(),
      role: UserRole.fromString(roleText),
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
}
