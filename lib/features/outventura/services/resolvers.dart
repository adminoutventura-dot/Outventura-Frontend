import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

// --- Funciones de resolución ---

// Resuelve el nombre completo de un usuario por su ID.
String resolverNombreUsuario(int id, List<Usuario> usuarios) {
  final int index = usuarios.indexWhere((Usuario u) => u.id == id);
  if (index == -1) return 'Usuario desconocido';
  final Usuario u = usuarios[index];
  return '${u.nombre} ${u.apellidos}';
}

// Resuelve el nombre de una excursión por su ID (formato "PuntoInicio → PuntoFin").
String? resolverNombreExcursion(int? id, List<Excursion> excursiones) {
  if (id == null) return null;
  final int index = excursiones.indexWhere((Excursion e) => e.id == id);
  if (index == -1) return null;
  final Excursion e = excursiones[index];
  return '${e.puntoInicio} → ${e.puntoFin}';
}

// Resuelve el nombre de un equipamiento por su ID.
String resolverNombreEquipamiento(int id, List<Equipamiento> equipamientos) {
  final int index = equipamientos.indexWhere((Equipamiento e) => e.id == id);
  return index != -1 ? equipamientos[index].nombre : 'Desconocido';
}

// Resuelve la imagen de un equipamiento por su ID.
String? resolverImagenEquipamiento(int id, List<Equipamiento> equipamientos) {
  final int index = equipamientos.indexWhere((Equipamiento e) => e.id == id);
  return index != -1 ? equipamientos[index].imagenAsset : null;
}
