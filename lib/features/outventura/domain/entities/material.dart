import 'activity_category.dart';

// Estados posibles de un material.
enum EstadoMaterial {
  disponible,
  reservado,
  mantenimiento,
  fueraDeServicio;

  // Devuelve el nombre del estado.
  String get nombre {
    switch (this) {
      case EstadoMaterial.disponible:
        return 'Disponible';
      case EstadoMaterial.reservado:
        return 'Reservado';
      case EstadoMaterial.mantenimiento:
        return 'En mantenimiento';
      case EstadoMaterial.fueraDeServicio:
        return 'Fuera de servicio';
    }
  }

  // Crea un estado a partir del valor en texto que devuelve el backend.
  static EstadoMaterial fromString(String value) {
    for (var estado in EstadoMaterial.values) {
      if (estado.name == value.toLowerCase()) {
        return estado;
      }
    }
    return EstadoMaterial.disponible;
  }
}

// Entidad de material.
class Material {
  final int id;
  final String nombre;
  final String? descripcion;
  final List<CategoriaActividad> categorias;
  final int stock;
  final EstadoMaterial estado;
  final double precioAlquilerDiario;
  final double tarifaDanios;
  final String? imageAsset;

  const Material({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.categorias,
    required this.stock,
    required this.estado,
    required this.precioAlquilerDiario,
    required this.tarifaDanios,
    this.imageAsset,
  });

  // Crea un Material a partir del JSON que devuelve el backend.
  factory Material.fromMap(Map<String, dynamic> map) {
    return Material(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      categorias: (map['categorias'] as List<dynamic>)
          .map((dynamic e) => CategoriaActividad.fromString(e as String))
          .toList(),
      stock: map['stock'] as int,
      estado: EstadoMaterial.fromString(map['estado'] as String),
      precioAlquilerDiario: (map['precioAlquilerDiario'] as num).toDouble(),
      tarifaDanios: (map['tarifaDanios'] as num).toDouble(),
      imageAsset: map['imageAsset'] as String?,
    );
  }

  // Crea un nuevo material a partir del actual, permitiendo modificar algunos campos.
  Material copyWith({
    String? nombre,
    String? descripcion,
    List<CategoriaActividad>? categorias,
    int? stock,
    EstadoMaterial? estado,
    double? precioAlquilerDiario,
    double? tarifaDanios,
    String? imageAsset,
  }) {
    return Material(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categorias: categorias ?? this.categorias,
      stock: stock ?? this.stock,
      estado: estado ?? this.estado,
      precioAlquilerDiario: precioAlquilerDiario ?? this.precioAlquilerDiario,
      tarifaDanios: tarifaDanios ?? this.tarifaDanios,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}
