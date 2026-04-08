import 'role.dart';

class Usuario {
  final int id;
  final String nombre;
  final String apellidos;
  final String email;
  final String? telefono;
  final TipoRol rol;
  final String? foto;
  final bool activo;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.email,
    this.telefono,
    required this.rol,
    this.foto,
    required this.activo,
  });

  // Crea un Usuario a partir del JSON del backend.
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      apellidos: map['apellidos'] as String,
      email: map['email'] as String,
      telefono: map['telefono']?.toString(),
      rol: TipoRol.fromString(map['rol'] as String),
      foto: map['foto'] as String?,
      activo: map['estado'] as bool,
    );
  }

  // Crea un nuevo usuario a partir del actual, permitiendo modificar algunos campos.
  Usuario copyWith({
    String? nombre,
    String? apellidos,
    String? email,
    String? telefono,
    TipoRol? rol,
    String? foto,
    bool? activo,
  }) {
    return Usuario(
      id: id,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      foto: foto ?? this.foto,
      activo: activo ?? this.activo,
    );
  }

  // Comprueba si el usuario tiene un rol específico.
  bool tieneRol(TipoRol tipoRol) {
    if (rol == tipoRol) {
      return true;
    } else {
      return false;
    }
  }
}
