import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

class Guide {
  final int? id;
  final int userId;
  final Category specialty;
  final String credentials;
  final User? user;

  const Guide({
    this.id,
    required this.userId,
    required this.specialty,
    required this.credentials,
    this.user,
  });

  factory Guide.fromMap(Map<String, dynamic> map) {
    return Guide(
      id: (map['id_guide'] ?? map['id']) as int,
      userId: map['userId'] as int,
      specialty: Category.fromString(map['specialty'] as String),
      credentials: map['credentials'] as String,
      user: map['user'] != null
          ? User.fromMap(map['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'specialty': specialty.code,
    'credentials': credentials,
  };

  Guide copyWith({
    int? id,
    int? userId,
    Category? specialty,
    String? credentials,
    User? user,
  }) {
    return Guide(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      specialty: specialty ?? this.specialty,
      credentials: credentials ?? this.credentials,
      user: user ?? this.user,
    );
  }
}
