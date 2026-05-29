import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';

// Resuelve el nombre completo de un usuario por su identificador.
String resolverNombreUsuario(int id, List<User> usuarios) {
  final int index = usuarios.indexWhere((User u) => u.id == id);
  if (index == -1) return 'Usuario desconocido';
  final User u = usuarios[index];
  return '${u.name} ${u.surname}';
}

// Resuelve el nombre de una actividad por su identificador utilizando su propiedad descriptiva 'title'.
String? resolverNombreActividad(int? id, List<Activity> actividades) {
  if (id == null) return null;
  final int index = actividades.indexWhere((Activity e) => e.id == id);
  if (index == -1) return null;
  return actividades[index].title;
}

// Resuelve el nombre de un equipamiento de forma segura.
String resolverNombreEquipamiento(int id, List<Equipment> equipamientos) {
  final int index = equipamientos.indexWhere((Equipment e) => e.id == id);
  return index != -1 ? equipamientos[index].title : 'Desconocido';
}

// Resuelve la ruta del recurso gráfico asociado a un material.
String? resolverImagenEquipamiento(int id, List<Equipment> equipamientos) {
  final int index = equipamientos.indexWhere((Equipment e) => e.id == id);
  return index != -1 ? equipamientos[index].imageAsset : null;
}
