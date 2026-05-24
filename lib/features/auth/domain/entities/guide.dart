import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';

class Guide {
  final int? id;
  final int userId;
  final String credentials;
  final List<Category> categories;
  final User? user;

  const Guide({
    this.id,
    required this.userId,
    required this.credentials,
    this.categories = const [],
    this.user,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'credentials': credentials,
    'categoryCodes': categories.map((Category c) => c.code).toList(),
  };

  Guide copyWith({
    int? id,
    int? userId,
    String? credentials,
    List<Category>? categories,
    User? user,
  }) {
    return Guide(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      credentials: credentials ?? this.credentials,
      categories: categories ?? this.categories,
      user: user ?? this.user,
    );
  }
}
