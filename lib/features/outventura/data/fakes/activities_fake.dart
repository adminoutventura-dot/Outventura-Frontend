import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

// Fake activity catalog data.
final List<Activity> activitiesFake = [
  // Actividad de senderismo y montaña en Mallorca.
  Activity(
    id: 1,
    title: 'Senderismo costa de Mallorca',
    description: 'Ruta sencilla con vistas al mar y a la montaña en la costa de Mallorca.',
    initDate: DateTime(2026, 5, 1, 9, 0),
    endDate: DateTime(2026, 5, 1, 12, 0),
    difficulty: 2,
    maxParticipants: 20,
    startEndPoint: 'Puerto de Soller - Torre Picada',
    categories: [ActivityCategory.acuatico, ActivityCategory.montana],
    status: ActivityStatus.disponible,
    price: 35.0,
    materialsPerParticipant: {5: 1, 6: 2},
  ),

  // Actividad en kayak por el Delta del Ebro.
  Activity(
    id: 2,
    title: 'Kayak en el Delta del Ebro',
    description: 'Recorrido en kayak por el Delta del Ebro, ideal para principiantes.',
    initDate: DateTime(2026, 6, 10, 10, 0),
    endDate: DateTime(2026, 6, 10, 14, 0),
    difficulty: 1,
    maxParticipants: 15,
    startEndPoint: 'Deltebre - Isla de Buda',
    categories: [ActivityCategory.acuatico],
    imageAsset: 'assets/images/Camino.jpg',
    status: ActivityStatus.disponible,
    price: 55.0,
    materialsPerParticipant: {3: 1, 8: 1},
  ),

  // Ruta de escalada en los Picos de Europa.
  Activity(
    id: 3,
    title: 'Escalada Picos de Europa',
    description: 'Ascension tecnica con tramos exigentes.',
    initDate: DateTime(2026, 7, 15, 8, 0),
    endDate: DateTime(2026, 7, 16, 18, 0),
    difficulty: 4,
    maxParticipants: 10,
    startEndPoint: 'Fuente De - Torre de los Horcados Rojos',
    categories: [ActivityCategory.acuatico, ActivityCategory.montana],
    imageAsset: 'assets/images/Camino.jpg',
    status: ActivityStatus.disponible,
    price: 90.0,
    materialsPerParticipant: {7: 1, 8: 1, 6: 1},
  ),

  // Actividad con raquetas de nieve en los Pirineos.
  Activity(
    id: 4,
    title: 'Raquetas en Benasque',
    description: 'Ruta guiada con raquetas de nieve por el valle de Benasque.',
    initDate: DateTime(2026, 12, 20, 9, 0),
    endDate: DateTime(2026, 12, 20, 15, 0),
    difficulty: 2,
    maxParticipants: 12,
    startEndPoint: 'Benasque - Pico Cerler',
    categories: [ActivityCategory.nieve],
    imageAsset: 'assets/images/Camino.jpg',
    status: ActivityStatus.disponible,
    price: 70.0,
    materialsPerParticipant: {9: 1, 2: 1, 6: 2},
  ),

  // Actividad urbana.
  Activity(
    id: 5,
    title: 'Paseo casco antiguo',
    description: 'Paseo guiado de baja dificultad por el casco antiguo.',
    initDate: DateTime(2026, 8, 5, 18, 0),
    endDate: DateTime(2026, 8, 5, 20, 0),
    difficulty: 1,
    maxParticipants: 25,
    startEndPoint: 'Plaza Mayor - Mirador del Castillo',
    categories: [ActivityCategory.montana],
    status: ActivityStatus.noDisponible,
    price: 20.0,
    materialsPerParticipant: {},
  ),

];
