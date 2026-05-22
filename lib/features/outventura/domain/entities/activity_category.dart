// Categoría de actividad. Entidad que refleja la tabla category del backend.
// Se usan constantes estáticas para los valores conocidos, y la clase admite
// cualquier categoría futura que devuelva el backend sin cambios en el front.
class Category {
  final int? id;
  final String code;
  final String? description;

  const Category({this.id, required this.code, this.description});

  // Constantes para los valores actuales (usadas en fakes y filtros).
  static const Category acuatico = Category(code: 'AQUATIC');
  static const Category nieve = Category(code: 'SNOW');
  static const Category montana = Category(code: 'MOUNTAIN');
  static const Category camping = Category(code: 'CAMPING');

  // Lista de todas las categorías conocidas (equivale a enum.values).
  static const List<Category> values = [acuatico, nieve, montana, camping];

  // Crea una Category a partir del código (String).
  // Usado cuando el backend devuelve un código de categoría como string suelto.
  static Category fromCode(String code) {
    return values.firstWhere(
      (Category c) => c.code == code,
      orElse: () => Category(code: code),
    );
  }

  // Crea una Category a partir del objeto completo que devuelve el backend.
  // Usado para Activity.categories y Equipment.categories (relación M:N).
  // Formato esperado: { id_category: int, code: String, description: String? }
  factory Category.fromMap(Map<String, dynamic> map) {
    final String code = map['code'] as String;
    // Si es una constante conocida, la devuelve para mantener igualdad por referencia.
    final Category? conocida = values.cast<Category?>().firstWhere(
      (Category? c) => c?.code == code,
      orElse: () => null,
    );
    return conocida ?? Category(
      id: map['id_category'] as int?,
      code: code,
      description: map['description'] as String?,
    );
  }

  @override
  bool operator ==(Object other) => other is Category && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Category($code)';
}
