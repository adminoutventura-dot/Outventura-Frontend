import 'activity_category.dart';

// Estados posibles de un material.
enum EstadoEquipamiento {
  disponible,
  reservado,
  mantenimiento,
  fueraDeServicio;

  // Devuelve el nombre legible del estado.
  String get label {
    switch (this) {
      case EstadoEquipamiento.disponible:
        return 'Disponible';
      case EstadoEquipamiento.reservado:
        return 'Reservado';
      case EstadoEquipamiento.mantenimiento:
        return 'En mantenimiento';
      case EstadoEquipamiento.fueraDeServicio:
        return 'Fuera de servicio';
    }
  }

  // Crea un estado a partir del valor en texto que devuelve el backend.
  static EstadoEquipamiento fromString(String value) {
    for (EstadoEquipamiento status in EstadoEquipamiento.values) {
      if (status.label.toLowerCase() == value.toLowerCase()) {
        return status;
      }
    }
    return EstadoEquipamiento.disponible;
  }
}

// Entidad de material.
class Equipamiento {
  final int id;
  final String nombre;
  final String? descripcion;
  final List<CategoriaActividad> categorias;
  final int stock;
  final EstadoEquipamiento estado;
  final double precioAlquilerDiario;
  final double cargoPorDanio;
  final String? imagenAsset;

  const Equipamiento({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.categorias,
    required this.stock,
    required this.estado,
    required this.precioAlquilerDiario,
    required this.cargoPorDanio,
    this.imagenAsset,
  });

  // Crea un Material a partir del JSON que devuelve el backend.
  factory Equipamiento.fromMap(Map<String, dynamic> map) {
    return Equipamiento(
      id: map['id'] as int,
      nombre: map['name'] as String,
      descripcion: map['description'] as String?,
      // Convierte la lista JSON de categorías en una lista de objetos CategoriaActividad.
      categorias: (map['categories'] as List<dynamic>)
          .map((e) => CategoriaActividad.fromString(e as String))
          .toList(),
      stock: map['stock'] as int,
      estado: EstadoEquipamiento.fromString(map['status'] as String),
      precioAlquilerDiario: (map['dailyRentalPrice'] as num).toDouble(),
      cargoPorDanio: (map['damageFee'] as num).toDouble(),
      imagenAsset: map['imageAsset'] as String?,
    );
  }

  // Crea un nuevo material a partir del actual, permitiendo modificar algunos campos.
  Equipamiento copyWith({
    String? nombre,
    String? descripcion,
    List<CategoriaActividad>? categorias,
    int? stock,
    EstadoEquipamiento? estado,
    double? precioAlquilerDiario,
    double? cargoPorDanio,
    String? imagenAsset,
  }) {
    return Equipamiento(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categorias: categorias ?? this.categorias,
      stock: stock ?? this.stock,
      estado: estado ?? this.estado,
      precioAlquilerDiario: precioAlquilerDiario ?? this.precioAlquilerDiario,
      cargoPorDanio: cargoPorDanio ?? this.cargoPorDanio,
      imagenAsset: imagenAsset ?? this.imagenAsset,
    );
  }
}
