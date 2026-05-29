// Por simplicidad en el desarrollo del frontend, las categorías 
// se gestionan de forma ESTÁTICA y LOCAL mediante el array 'values' y sus constantes.
//
// Aunque el backend (NestJS + PostgreSQL) tiene las categorías dinámicas y protegidas,
// el móvil las ignora para evitar sobrecarga de peticiones de red.
//
// Si se añade una nueva categoría en la base de datos, se debe picar aquí a mano

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
  static const Category hiking = Category(code: 'HIKING');

  // Lista de todas las categorías conocidas (equivale a enum.values).
  static const List<Category> values = [acuatico, nieve, montana, camping, hiking];

  // Crea una Category a partir del código (String).
  // Usado cuando el backend devuelve un código de categoría como string suelto.
  static Category fromCode(String code) {
    return values.firstWhere(
      (Category c) => c.code == code,
      orElse: () => Category(code: code),
    );
  }
  
  // Cambia el comportamiento del operador '==' para esta clase.
  // En lugar de comparar si están en el mismo sitio de la memoria RAM,
  // compara si el contenido de su texto ('code') es exactamente el mismo.
  @override
  bool operator ==(Object other) => 
      other is Category && other.code == code;

  // Genera un identificador numérico único para el objeto basado en su 'code'.
  // Es obligatorio reescribirlo al cambiar el operador '==' para que 
  // las colecciones como Sets (filtros) y Maps funcionen sin duplicados.
  @override
  int get hashCode => code.hashCode;

  // Personaliza cómo se muestra el objeto al hacer un 'print()' en la consola.
  // En vez de imprimir 'Instance of Category', imprimirá 'Category(MOUNTAIN)',
  // haciendo que la depuración de errores sea más fácil.
  @override
  String toString() => 'Category($code)';
}