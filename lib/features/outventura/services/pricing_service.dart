import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';

// Calcula el precio de coste de reservas de materiales básandose en los días transcurridos.
double calcularPrecioReserva({
  required List<BookingLine> lineas,
  required DateTime fechaDesde,
  required DateTime fechaHasta,
  required List<Equipment> equipamientos,
}) {
  final int dias = fechaHasta.difference(fechaDesde).inDays.clamp(1, 999);
  final Map<int, Equipment> equipPorId = {
    for (final Equipment e in equipamientos) e.id!: e,
  };
  double total = 0;

  for (final BookingLine linea in lineas) {
    if (linea.equipmentId != null) {
      final Equipment? equip = equipPorId[linea.equipmentId];
      if (equip != null) {
        total += equip.pricePerDay * linea.quantity * dias;
      }
    }
  }
  return total;
}

// Mapea colecciones rápidas de registros de materiales.
Map<int, int> materialesDesdeLineas(
  List<({int idEquipamiento, int cantidad})> lineas,
) {
  final Map<int, int> materiales = {};
  for (final linea in lineas) {
    materiales[linea.idEquipamiento] = linea.cantidad;
  }
  return materiales;
}
