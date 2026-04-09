import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

// Fake excursion catalog data.
final List<Excursion> excursionCatalog = [
  // Excursión de senderismo y montaña en Mallorca.
  Excursion(
    id: 1,
    puntoInicio: 'Puerto de Sóller',
    puntoFin: 'Torre Picada',
    categorias: [CategoriaActividad.acuatica, CategoriaActividad.montania],
    numeroParticipantes: 20,
    descripcion: 'Ruta sencilla con vistas al mar y a la montaña en la costa de Mallorca.',
    estado: EstadoExcursion.disponible,
    fechaInicio: DateTime(2026, 5, 1, 9, 0),
    fechaFin: DateTime(2026, 5, 1, 12, 0),
  ),

  // Excursión en kayak por el Delta del Ebro.
  Excursion(
    id: 2,
    puntoInicio: 'Deltebre',
    puntoFin: 'Isla de Buda',
    imageAsset: 'assets/images/Camino.jpg',
    categorias: [CategoriaActividad.acuatica],
    numeroParticipantes: 15,
    descripcion: 'Recorrido en kayak por el Delta del Ebro, ideal para principiantes.',
    estado: EstadoExcursion.disponible,
    fechaInicio: DateTime(2026, 6, 10, 10, 0),
    fechaFin: DateTime(2026, 6, 10, 14, 0),
  ),

  // Ruta de escalada en los Picos de Europa.
  Excursion(
    id: 3,
    puntoInicio: 'Fuente Dé',
    puntoFin: 'Torre de los Horcados Rojos',
    imageAsset: 'assets/images/Camino.jpg',
    categorias: [CategoriaActividad.acuatica, CategoriaActividad.montania],
    numeroParticipantes: 10,
    descripcion: 'Ascensión técnica.',
    estado: EstadoExcursion.disponible,
    fechaInicio: DateTime(2026, 7, 15, 8, 0),
    fechaFin: DateTime(2026, 7, 16, 18, 0),
  ),

  // Excursión con raquetas de nieve en los Pirineos.
  Excursion(
    id: 4,
    puntoInicio: 'Benasque',
    puntoFin: 'Pico Cerler',
    imageAsset: 'assets/images/Camino.jpg',
    categorias: [CategoriaActividad.nieve],
    numeroParticipantes: 12,
    descripcion: 'Ruta guiada con raquetas de nieve por el valle de Benasque.',
    estado: EstadoExcursion.disponible,
    fechaInicio: DateTime(2026, 12, 20, 9, 0),
    fechaFin: DateTime(2026, 12, 20, 15, 0),
  ),
];

// Backward-compatible alias (legacy Spanish name).
final List<Excursion> catalogoExcursiones = excursionCatalog;