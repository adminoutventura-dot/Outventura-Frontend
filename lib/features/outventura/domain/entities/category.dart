// Las categorías ahora son 100% DINÁMICAS y se sincronizan en tiempo real
// con la base de datos de PostgreSQL a través del backend en NestJS.

class Category {
  final int? id;
  final String code;
  final String? description;

  const Category({this.id, required this.code, this.description});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id_category'] as int?,
      code: (map['code'] ?? '') as String,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id_category': id,
    'code': code,
    if (description != null) 'description': description,
  };

  Category copyWith({
    int? id,
    String? code,
    String? description,
  }) {
    return Category(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
    );
  }
  
  // Sigue comparando por 'code' para que los Chips del filtro reconozcan duplicados
  @override
  bool operator ==(Object other) => 
      other is Category && other.code == code; 

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Category($code)';
}