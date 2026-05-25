class UserRole {
  final int? id;
  final String code;
  final String? description;

  const UserRole({this.id, required this.code, this.description});

  static const UserRole superadmin = UserRole(code: 'SUPER');
  static const UserRole admin = UserRole(code: 'ADMIN');
  static const UserRole guia = UserRole(code: 'GUIDE');
  static const UserRole usuario = UserRole(code: 'USER');
  static const UserRole invitado = UserRole(code: 'GUEST');

  static const List<UserRole> values = [superadmin, admin, guia, usuario, invitado];

  // Crea un rol a partir del código que devuelve el backend (e.g. 'ADMIN').
  static UserRole fromCode(String code) {
    return values.firstWhere((r) => r.code == code, orElse: () => invitado);
  }

  // Crea un rol a partir del objeto JSON del backend.
  static UserRole fromMap(Map<String, dynamic> map) {
    final code = map['code'] as String? ?? 'GUEST';
    return UserRole(
      id: map['id_role'] as int?,
      code: code,
      description: map['description'] as String?,
    );
  }

  @override
  bool operator ==(Object other) => other is UserRole && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'UserRole($code)';
}
