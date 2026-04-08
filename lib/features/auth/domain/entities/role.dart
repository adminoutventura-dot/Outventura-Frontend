enum TipoRol {
  superadmin,
  admin,
  experto,
  usuario,
  invitado;

  // Devuelve el nombre legible del rol.
  String get nombre {
    switch (this) {
      case TipoRol.superadmin:
        return 'Superadmin';
      case TipoRol.admin:
        return 'Admin';
      case TipoRol.experto:
        return 'Experto';
      case TipoRol.usuario:
        return 'Usuario';
      case TipoRol.invitado:
        return 'Invitado';
    }
  }

  // Crea un rol a partir del valor en texto que devuelve el backend.
  static TipoRol fromString(String value) {
    for (var rol in TipoRol.values) {
      if (rol.name == value.toLowerCase()) {
        return rol;
      }
    }
    return TipoRol.invitado;
  }
  
}
