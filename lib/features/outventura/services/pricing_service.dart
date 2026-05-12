import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

// Calcula el precio total de una solicitud: precio excursión × participantes + alquiler materiales.
// TEMPORAL: lógica local mientras no hay backend.
double calcularPrecioSolicitud({
  required int? idExcursion,
  required int numeroParticipantes,
  required Map<int, int> materialesSolicitados,
  required List<Activity> excursiones,
  required List<Equipamiento> equipamientos,
}) {
  // Si no hay excursión asociada, el precio es 0 (no se puede calcular).
  if (idExcursion == null) {
    return 0;
  }

  // Busca la excursión por su ID. Si no se encuentra, el precio es 0 (no se puede calcular).
  final int index = excursiones.indexWhere((Activity e) => e.id == idExcursion);
  if (index == -1) {
    return 0;
  }

  // Si se encuentra la excursión, calcula el precio total.
  final Activity excursion = excursiones[index];
  // Precio base de la excursión.
  double total = excursion.price * numeroParticipantes;


  // Calcula la diferencia entre la fecha de fin y la de inicio, obteniendo una Duration.
  // .inDays - Convierte esa duración a días enteros.
  // .clamp(1, 999) - Asegura que el número de días sea al menos 1 y no más de 999.
  final int dias = excursion.endDate.difference(excursion.initDate).inDays.clamp(1, 999);
  
  // Guarda los equipamientos en un mapa para acceso rápido por ID (idEquipamiento → Equipamiento).
  final Map<int, Equipamiento> equipPorId = {};
  for (final Equipamiento e in equipamientos) {
    equipPorId[e.id] = e;
  }

  // Suma el costo de alquiler de cada material solicitado: precioAlquilerDiario × cantidad × días.
  for (final MapEntry<int, int> entry in materialesSolicitados.entries) {
    final Equipamiento? equip = equipPorId[entry.key];
    if (equip != null) {
      total = equip.pricePerDay * entry.value * dias + total;
    }
  }

  return total;
}

// Calcula el total de cargos por daños a equipamientos.
// TEMPORAL: lógica local mientras no hay backend.
double calcularCargoDanios({
  required Map<int, int> cantidadesDaniadas,
  required List<Equipamiento> equipamientos,
}) {
  double total = 0;
  for (final MapEntry<int, int> entry in cantidadesDaniadas.entries) {
    final Iterable<Equipamiento> coincidencias = equipamientos.where(
      (Equipamiento e) => e.id == entry.key,
    );
    if (coincidencias.isNotEmpty) {
      total = coincidencias.first.damageFee * entry.value + total;
    }
  }
  return total;
}

// Convierte una lista de líneas de reserva en un mapa {idEquipamiento → cantidad}.
Map<int, int> materialesDesdeLineas(List<({int idEquipamiento, int cantidad})> lineas) {
  final Map<int, int> materiales = {};
  for (final linea in lineas) {
    materiales[linea.idEquipamiento] = linea.cantidad;
  }
  return materiales;
}
