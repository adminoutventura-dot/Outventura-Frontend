enum UserRole {
  superadmin,
  admin,
  usuario,
  invitado;

  // Devuelve el nombre legible del rol.
  String get nombre {
    switch (this) {
      case UserRole.superadmin:
        return 'Superadmin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.usuario:
        return 'Usuario';
      case UserRole.invitado:
        return 'Invitado';
    }
  }

  String get code {
    switch (this) {
      case UserRole.superadmin:
        return 'SUPER';
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.usuario:
        return 'USER';
      case UserRole.invitado:
        return 'GUEST';
    }
  }

  // Crea un rol a partir del valor en texto que devuelve el backend.
  static UserRole fromString(String value) {
    for (UserRole rol in UserRole.values) {
      if (rol.code == value) {
        return rol;
      }
    }
    return UserRole.invitado;
  }
}
