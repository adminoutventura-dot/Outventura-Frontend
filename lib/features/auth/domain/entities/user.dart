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
  Map<String, dynamic> toMap() {
    // Convierte el código string de UserRole al ID numérico que espera PostgreSQL
    final int idDelRol = switch (role.code) {
      'SUPER' => 1,
      'ADMIN' => 2,
      'GUIDE' => 3,
      'USER' => 4,
      _ => 4, // Por defecto asigna rol de usuario normal
    };

    return {
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'photo': photo,
      'status': active,
      'roleId': idDelRol,
    };
  }
}
