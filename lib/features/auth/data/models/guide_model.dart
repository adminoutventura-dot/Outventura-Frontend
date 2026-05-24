import 'package:outventura/features/auth/data/models/user_model.dart';
import 'package:outventura/features/auth/domain/entities/guide.dart';
import 'package:outventura/features/outventura/data/models/category_model.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';

/// Modelo de guía: extiende [Guide] añadiendo la deserialización desde JSON del backend.
class GuideModel extends Guide {
  const GuideModel({
    super.id,
    required super.userId,
    required super.credentials,
    super.categories,
    super.user,
  });

  factory GuideModel.fromMap(Map<String, dynamic> map) {
    return GuideModel(
      id: map['id_guide'] as int?,
      userId: map['userId'] as int,
      credentials: map['credentials'] as String,
      categories: (map['categories'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(CategoryModel.fromMap)
          .toList() as List<Category>,
      user: map['user'] != null
          ? UserModel.fromMap(map['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
