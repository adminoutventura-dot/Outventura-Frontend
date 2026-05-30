import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';

// Fake activity catalog data.
final List<Activity> activitiesFake = [
  // Actividad de senderismo y montaña en Mallorca.
  Activity(
    id: 1,
    title: 'Ruta Costa de Mallorca',
    description: 'Ruta sencilla con vistas al mar y a la montaña en la costa de Mallorca.',
    initDate: DateTime(2026, 5, 1, 9, 0),
    endDate: DateTime(2026, 5, 1, 12, 0),
    difficulty: 2,
    maxParticipants: 20,
    startEndPoint: 'Puerto de Soller - Torre Picada',
    categories: const [Category(code: 'AQUATIC'), Category(code: 'MOUNTAIN')],
    recommendedEquipmentIds: const [5, 6],
  ),

  // Actividad en kayak por el Delta del Ebro.
  Activity(
    id: 2,
    title: 'Kayak Delta del Ebro',
    description: 'Recorrido en kayak por el Delta del Ebro, ideal para principiantes.',
    initDate: DateTime(2026, 6, 10, 10, 0),
    endDate: DateTime(2026, 6, 10, 14, 0),
    difficulty: 1,
    maxParticipants: 15,
    startEndPoint: 'Deltebre - Isla de Buda',
    categories: const [Category(code: 'AQUATIC')],
    imageAsset: 'assets/images/Camino.jpg',
    recommendedEquipmentIds: const [3, 8],
  ),

  // Ruta de escalada en los Picos de Europa.
  Activity(
    id: 3,
    title: 'Ascensión Picos de Europa',
    description: 'Ascensión técnica con traexigentes.',
    initDate: DateTime(2026, 7, 15, 8, 0),
    endDate: DateTime(2026, 7, 16, 18, 0),
    difficulty: 4,
    maxParticipants: 10,
    startEndPoint: 'Fuente De - Torre de los Horcados Rojos',
    categories: const [Category(code: 'AQUATIC'), Category(code: 'MOUNTAIN')],
    imageAsset: 'assets/images/Camino.jpg',
    recommendedEquipmentIds: const [7, 8, 6],
  ),

  // Actividad con raquetas de nieve en los Pirineos.
  Activity(
    id: 4,
    title: 'Raquetas Valle de Benasque',
    description: 'Ruta guiada con raquetas de nieve por el valle de Benasque.',
    initDate: DateTime(2026, 12, 20, 9, 0),
    endDate: DateTime(2026, 12, 20, 15, 0),
    difficulty: 2,
    maxParticipants: 12,
    startEndPoint: 'Benasque - Pico Cerler',
    categories: const [Category(code: 'SNOW')],
    imageAsset: 'assets/images/Camino.jpg',
    recommendedEquipmentIds: const [9, 2, 6],
  ),

  // Actividad urbana.
  Activity(
    id: 5,
    title: 'Paseo Casco Antiguo',
    description: 'Paseo guiado de baja dificultad por el casco antiguo.',
    initDate: DateTime(2026, 8, 5, 18, 0),
    endDate: DateTime(2026, 8, 5, 20, 0),
    difficulty: 1,
    maxParticipants: 25,
    startEndPoint: 'Plaza Mayor - Mirador del Castillo',
    categories: const [Category(code: 'MOUNTAIN')],
    recommendedEquipmentIds: const [],
  ),

  // ── Actividades de esta semana (19–25 mayo 2026) para la gráfica ──
  Activity(
    id: 6,
    title: 'BTT Sierra Norte',
    description: 'Ruta en bicicleta de montaña por la Sierra Norte de Madrid.',
    initDate: DateTime(2026, 5, 19, 9, 0),
    endDate: DateTime(2026, 5, 19, 14, 0),
    difficulty: 3,
    maxParticipants: 8,
    startEndPoint: 'Somosierra - Buitrago del Lozoya',
    categories: const [Category(code: 'MOUNTAIN')],
    recommendedEquipmentIds: const [],
  ),

  Activity(
    id: 7,
    title: 'Paddle Surf Palma',
    description: 'Sesión de paddle surf en aguas tranquilas.',
    initDate: DateTime(2026, 5, 20, 10, 0),
    endDate: DateTime(2026, 5, 20, 13, 0),
    difficulty: 1,
    maxParticipants: 12,
    startEndPoint: 'Playa de Palma - Can Pastilla',
    categories: const [Category(code: 'AQUATIC')],
    recommendedEquipmentIds: const [],
  ),

  Activity(
    id: 8,
    title: 'Vía Ferrata Montserrat',
    description: 'Ascensión técnica por las agujas de Montserrat.',
    initDate: DateTime(2026, 5, 21, 8, 0),
    endDate: DateTime(2026, 5, 21, 16, 0),
    difficulty: 4,
    maxParticipants: 6,
    startEndPoint: 'Monistrol - Cavall Bernat',
    categories: const [Category(code: 'MOUNTAIN')],
    recommendedEquipmentIds: const [],
  ),

  Activity(
    id: 9,
    title: 'Ruta del Cares',
    description: 'Recorrido clásico por el desfiladero del río Cares.',
    initDate: DateTime(2026, 5, 22, 9, 0),
    endDate: DateTime(2026, 5, 22, 15, 0),
    difficulty: 2,
    maxParticipants: 20,
    startEndPoint: 'Caín - Poncebos',
    categories: const [Category(code: 'MOUNTAIN')],
    recommendedEquipmentIds: const [],
  ),

  Activity(
    id: 10,
    title: 'Kayak Cap de Creus',
    description: 'Excursión en kayak de mar por el cabo más oriental de la Península.',
    initDate: DateTime(2026, 5, 23, 9, 0),
    endDate: DateTime(2026, 5, 23, 13, 0),
    difficulty: 2,
    maxParticipants: 10,
    startEndPoint: 'Port de la Selva - Cap de Creus',
    categories: const [Category(code: 'AQUATIC')],
    recommendedEquipmentIds: const [],
  ),
];