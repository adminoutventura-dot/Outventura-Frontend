import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/outventura/data/models/category_model.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';

final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/category'); 
      final dynamic data = response.data;
      final List<dynamic> rawList = data is Map && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data as List<dynamic>);
      return rawList
          .map((e) => CategoryModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<Category> agregar(Category categoria) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/category', data: categoria.toMap());
      final dynamic data = response.data;
      final Map<String, dynamic> map = data is Map && data['data'] is Map
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      final Category created = CategoryModel.fromMap(map);
      ref.invalidateSelf();
      return created;
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> actualizar(Category viejo, Category nuevo) async {
    if (viejo.id == null) {
      throw StateError('Category has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/category/${viejo.id}', data: nuevo.toMap());
      ref.invalidateSelf();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> eliminar(Category categoria) async {
    if (categoria.id == null) {
      throw StateError('Category has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/category/${categoria.id}');
      ref.invalidateSelf();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }
}