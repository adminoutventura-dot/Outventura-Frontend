import 'activity_category.dart';

// Estados posibles de un material.
enum EstadoEquipamiento {
  disponible,
  agotado,
  mantenimiento,
  fueraDeServicio;

  // Devuelve el nombre legible del estado.
  String get label {
    switch (this) {
      case EstadoEquipamiento.disponible:
        return 'Disponible';
      case EstadoEquipamiento.agotado:
        return 'Agotado';
      case EstadoEquipamiento.mantenimiento:
        return 'En mantenimiento';
      case EstadoEquipamiento.fueraDeServicio:
        return 'Fuera de servicio';
    }
  }

  // Crea un estado a partir del valor en texto que devuelve el backend.
  static EstadoEquipamiento fromString(String value) {
    switch (value.toUpperCase()) {
      case 'AVAILABLE':
        return EstadoEquipamiento.disponible;
      case 'DEPLETED':
        return EstadoEquipamiento.agotado;
      case 'REPAIR':
        return EstadoEquipamiento.mantenimiento;
      case 'RETIRED':
        return EstadoEquipamiento.fueraDeServicio;
      case 'RESERVADO':
        return EstadoEquipamiento.agotado;
    }
    // Fallback: compara con el label en español
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
  final int stockTotal;
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
    required this.stockTotal,
    required this.estado,
    required this.precioAlquilerDiario,
    required this.cargoPorDanio,
    this.imagenAsset,
  });

  // Crea un Material a partir del JSON que devuelve el backend.
  factory Equipamiento.fromMap(Map<String, dynamic> map) {
    // El estado puede venir como objeto {code, description} o como string directo
    final dynamic statusRaw = map['status'];
    final String statusCode = statusRaw is Map<String, dynamic>
        ? (statusRaw['code'] as String? ?? '')
        : (statusRaw as String? ?? '');

    return Equipamiento(
      id: (map['idEquipment'] ?? map['id']) as int,
      nombre: (map['title'] ?? map['name']) as String,
      descripcion: map['description'] as String?,
      // Convierte la lista JSON de categorías en una lista de objetos CategoriaActividad.
      categorias: (map['categories'] as List<dynamic>?)
              ?.map((dynamic e) => CategoriaActividad.fromString(e as String))
              .toList() ??
          [],
      stock: map['stock'] as int? ?? 0,
      stockTotal: (map['units'] ?? map['stockTotal'] ?? map['stock']) as int? ?? 0,
      estado: EstadoEquipamiento.fromString(statusCode),
      precioAlquilerDiario: (map['pricePerDay'] ?? map['dailyRentalPrice'] as dynamic)?.toDouble() ?? 0.0,
      cargoPorDanio: (map['damageFee'] as num?)?.toDouble() ?? 0.0,
      imagenAsset: (map['imageUrl'] ?? map['imageAsset']) as String?,
    );
  }

  // Crea un nuevo material a partir del actual, permitiendo modificar algunos campos.
  Equipamiento copyWith({
    String? nombre,
    String? descripcion,
    List<CategoriaActividad>? categorias,
    int? stock,
    int? stockTotal,
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
      stockTotal: stockTotal ?? this.stockTotal,
      estado: estado ?? this.estado,
      precioAlquilerDiario: precioAlquilerDiario ?? this.precioAlquilerDiario,
      cargoPorDanio: cargoPorDanio ?? this.cargoPorDanio,
      imagenAsset: imagenAsset ?? this.imagenAsset,
    );
  }
}
