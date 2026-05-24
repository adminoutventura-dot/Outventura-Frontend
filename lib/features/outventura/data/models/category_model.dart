import 'package:outventura/features/outventura/domain/entities/category.dart';

/// Modelo de categoría: extiende [Category] añadiendo la deserialización desde JSON del backend.
/// El JSON esperado es: { id_category: int, code: String, description: String? }
class CategoryModel extends Category {
  const CategoryModel({super.id, required super.code, super.description});

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id_category'] as int?,
      code: map['code'] as String,
      description: map['description'] as String?,
    );
  }
}
