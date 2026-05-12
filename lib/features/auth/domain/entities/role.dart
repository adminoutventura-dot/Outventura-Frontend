enum TipoRol {
  superadmin,
  admin,
  usuario,
  invitado;

  // Devuelve el nombre legible del rol.
  String get nombre {
    switch (this) {
      case TipoRol.superadmin:
        return 'Superadmin';
      case TipoRol.admin:
        return 'Admin';
      case TipoRol.usuario:
        return 'Usuario';
      case TipoRol.invitado:
        return 'Invitado';
    }
  }

  String get code {
    switch (this) {
      case TipoRol.superadmin:
        return 'SUPER';
      case TipoRol.admin:
        return 'ADMIN';
      case TipoRol.usuario:
        return 'USER';
      case TipoRol.invitado:
        return 'GUEST';
    }
  }

  // Crea un rol a partir del valor en texto que devuelve el backend.
  static TipoRol fromString(String value) {
    for (TipoRol rol in TipoRol.values) {
      if (rol.code == value) {
        return rol;
      }
    }
    return TipoRol.invitado;
  }
}
