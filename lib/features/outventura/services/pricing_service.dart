import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

// Calcula el precio total de una solicitud: precio excursión × participantes + alquiler materiales.
double calcularPrecioSolicitud({
  required int? idExcursion,
  required int numeroParticipantes,
  required Map<int, int> materialesSolicitados,
  required List<Excursion> excursiones,
  required List<Equipamiento> equipamientos,
}) {
  if (idExcursion == null) return 0;
  final int index = excursiones.indexWhere((Excursion e) => e.id == idExcursion);
  if (index == -1) return 0;
  final Excursion excursion = excursiones[index];

  // Precio base de la excursión.
  double total = excursion.precio * numeroParticipantes;

  // Precio de los materiales: precio diario × cantidad × días de la excursión.
  final int dias = excursion.fechaFin.difference(excursion.fechaInicio).inDays.clamp(1, 999);
  final Map<int, Equipamiento> equipPorId = {
    for (final Equipamiento e in equipamientos) e.id: e,
  };
  for (final MapEntry<int, int> entry in materialesSolicitados.entries) {
    final Equipamiento? equip = equipPorId[entry.key];
    if (equip != null) {
      total += equip.precioAlquilerDiario * entry.value * dias;
    }
  }

  return total;
}

// Calcula el total de cargos por daños a equipamientos.
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
      total += coincidencias.first.cargoPorDanio * entry.value;
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
