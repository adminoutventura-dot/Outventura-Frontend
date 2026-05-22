class UserRole {
  final String code;

  const UserRole({required this.code});

  static const UserRole superadmin = UserRole(code: 'SUPER');
  static const UserRole admin      = UserRole(code: 'ADMIN');
  static const UserRole usuario    = UserRole(code: 'USER');
  static const UserRole invitado   = UserRole(code: 'GUEST');

  static const List<UserRole> values = [superadmin, admin, usuario, invitado];

  // Crea un rol a partir del código que devuelve el backend (e.g. 'ADMIN').
  static UserRole fromCode(String code) {
    return values.firstWhere((r) => r.code == code, orElse: () => invitado);
  }

  @override
  bool operator ==(Object other) => other is UserRole && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'UserRole($code)';
}
