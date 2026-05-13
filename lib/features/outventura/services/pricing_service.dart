import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';

// Calcula el precio total de una solicitud: precio actividad × participantes + alquiler materiales.
// TEMPORAL: lógica local mientras no hay backend.
double calcularPrecioSolicitud({
  required int? idActividad,
  required int numeroParticipantes,
  required Map<int, int> materialesSolicitados,
  required List<Activity> actividades,
  required List<Equipment> equipamientos,
}) {
  // Si no hay actividad asociada, el precio es 0 (no se puede calcular).
  if (idActividad == null) {
    return 0;
  }

  // Busca la actividad por su ID. Si no se encuentra, el precio es 0 (no se puede calcular).
  final int index = actividades.indexWhere((Activity e) => e.id == idActividad);
  if (index == -1) {
    return 0;
  }

  // Si se encuentra la actividad, calcula el precio total.
  final Activity actividad = actividades[index];
  // Precio base de la actividad.
  double total = actividad.price * numeroParticipantes;


  // Calcula la diferencia entre la fecha de fin y la de inicio, obteniendo una Duration.
  // .inDays - Convierte esa duración a días enteros.
  // .clamp(1, 999) - Asegura que el número de días sea al menos 1 y no más de 999.
  final int dias = actividad.endDate.difference(actividad.initDate).inDays.clamp(1, 999);
  
  // Guarda los equipamientos en un mapa para acceso rápido por ID (idEquipamiento → Equipamiento).
  final Map<int, Equipment> equipPorId = {};
  for (final Equipment e in equipamientos) {
    equipPorId[e.id] = e;
  }

  // Suma el costo de alquiler de cada material solicitado: precioAlquilerDiario × cantidad × días.
  for (final MapEntry<int, int> entry in materialesSolicitados.entries) {
    final Equipment? equip = equipPorId[entry.key];
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
  required List<Equipment> equipamientos,
}) {
  double total = 0;
  for (final MapEntry<int, int> entry in cantidadesDaniadas.entries) {
    final Iterable<Equipment> coincidencias = equipamientos.where(
      (Equipment e) => e.id == entry.key,
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
