import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';

// Solicitudes de prueba con distintas categorías, fechas y estados.
final List<Solicitud> solicitudesFake = [
  // Ruta de senderismo y montaña en Mallorca, confirmada y con experto asignado.
  Solicitud(
    id: 1,
    puntoInicio: 'Puerto de Pollença',
    puntoFin: 'Puig Major',
    fechaInicio: DateTime(2026, 5, 10, 8, 0),
    fechaFin: DateTime(2026, 5, 10, 16, 0),
    categorias: [CategoriaActividad.montania, CategoriaActividad.acuatica],
    numeroParticipantes: 12,
    descripcion: 'Ruta circular por la Serra de Tramuntana con vistas al mar y al Puig Major.',
    estado: EstadoSolicitud.confirmada,
    idExperto: 1,
  ),

  // Descenso en kayak por el Delta del Ebro con acampada nocturna.
  Solicitud(
    id: 2,
    puntoInicio: 'Deltebre - Río Ebro',
    puntoFin: 'La Banya',
    fechaInicio: DateTime(2026, 6, 15, 9, 0),
    fechaFin: DateTime(2026, 6, 16, 18, 0),
    categorias: [CategoriaActividad.acuatica, CategoriaActividad.acampada],
    numeroParticipantes: 8,
    descripcion: 'Descenso en kayak por el Delta del Ebro.',
    estado: EstadoSolicitud.pendiente,
    idExperto: 2,
  ),

  // Ascensión al pico más alto de la Península Ibérica.
  Solicitud(
    id: 3,
    puntoInicio: 'Hoya de la Mora',
    puntoFin: 'Cumbre del Mulhacén',
    fechaInicio: DateTime(2026, 7, 1, 5, 0),
    fechaFin: DateTime(2026, 7, 1, 19, 0),
    categorias: [CategoriaActividad.montania],
    numeroParticipantes: 6,
    descripcion: 'Ascensión al Mulhacén (3.479 m), el pico más alto de la Península Ibérica.',
    estado: EstadoSolicitud.pendiente,
    idExperto: 3,
  ),

  // Ruta con raquetas de nieve en los Pirineos, finalizada.
  Solicitud(
    id: 4,
    puntoInicio: 'Formigal',
    puntoFin: 'Pico Anayet',
    fechaInicio: DateTime(2026, 2, 20, 9, 0),
    fechaFin: DateTime(2026, 2, 20, 17, 0),
    categorias: [CategoriaActividad.nieve, CategoriaActividad.montania],
    numeroParticipantes: 10,
    descripcion: 'Ruta con raquetas de nieve por el Pirineo aragonés hasta el Pico Anayet.',
    estado: EstadoSolicitud.finalizada,
    idExperto: 1,
  ),
];

