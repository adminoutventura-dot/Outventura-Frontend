import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/id_generator.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/services/pricing_service.dart';
import 'package:outventura/l10n/app_localizations.dart';

class RequestFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController participantesCtrl = TextEditingController();

  int? idActividad;
  int get numeroParticipantes => int.tryParse(participantesCtrl.text) ?? 1;
  RequestStatus estado = RequestStatus.pendiente;
  int? idExperto;
  int? idUsuario;
  int? idReserva;
  Map<int, int> materialesSolicitados = {};

  bool editando = false;
  Request? seleccionado;

  bool validar() {
    if (formKey.currentState == null) return false;
    return formKey.currentState!.validate();
  }

  // Carga los datos de una solicitud en el formulario para su edición.
  void cargarSolicitud(Request solicitud) {
    editando = true;
    seleccionado = solicitud;
    idActividad = solicitud.activityId;
    participantesCtrl.text = '${solicitud.participantCount}';
    estado = solicitud.status;
    idExperto = solicitud.expertId;
    idUsuario = solicitud.userId;
    idReserva = solicitud.reservationId;
    materialesSolicitados = Map<int, int>.from(solicitud.requestedMaterials);
  }

  // Aplica los valores de la actividad seleccionada y el usuario.
  void aplicarValoresIniciales({int? idActividad, int? idUsuario}) {
    this.idActividad = idActividad;
    this.idUsuario = idUsuario;
    if (participantesCtrl.text.trim().isEmpty) {
      participantesCtrl.text = '1';
    }
  }

  // Calcula el total de materiales solicitados sumando las cantidades de cada equipamiento.
  void establecerCantidadMaterial(int idEquipamiento, int cantidad) {
    if (cantidad <= 0) {
      materialesSolicitados.remove(idEquipamiento);
      return;
    }
    materialesSolicitados[idEquipamiento] = cantidad;
  }

  // Crea una nueva solicitud a partir de los datos del formulario.
  Request? crearSolicitud(List<Activity> actividades, List<Equipment> equipamientos) {
    if (!validar()) {
      return null;
    }

    // TEMPORAL: idEntero() se elimina cuando el backend asigne IDs reales. precio vendrá del backend.
    final int id = seleccionado?.id ?? GeneradorId.idEntero();
    final double precio = calcularPrecioTotal(actividades, equipamientos);

    return Request(
      id: id,
      activityId: idActividad!,
      participantCount: numeroParticipantes,
      status: estado,
      expertId: idExperto,
      userId: idUsuario,
      reservationId: idReserva,
      requestedMaterials: Map<int, int>.from(materialesSolicitados),
      totalPrice: precio,
    );
  }

  // Convierte una lista de líneas de reserva en un mapa {idEquipamiento → cantidad}.
  Map<int, int> materialesDesdeLineas(List<ReservationLine> lineas) {
    final Map<int, int> materiales = {};
    for (final ReservationLine linea in lineas) {
      materiales[linea.equipmentId] = linea.quantity;
    }
    return materiales;
  }

  // Convierte el mapa en lista de LineaReserva, filtrando los que tengan cantidad 0.
  List<ReservationLine> lineasDesdeMateriales() {
    return materialesSolicitados.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) =>
              ReservationLine(equipmentId: entry.key, quantity: entry.value),
        )
        .toList();
  }

  // Busca la actividad seleccionada en la lista de actividades disponibles.
  Activity? buscarActividadSeleccionada(List<Activity> actividades) {
    if (idActividad == null) {
      return null;
    }
    for (final Activity e in actividades) {
      if (e.id == idActividad) {
        return e;
      }
    }
    return null;
  }

  // TEMPORAL: reemplazar por GET /api/precio-solicitud con parámetros. El backend calculará el precio total.
  // Recalcula los materiales solicitados basándose en la actividad seleccionada y el número de participantes.
  void recalcularMateriales(List<Activity> actividades) {
    // Si ya existe una reserva asociada, no sobreescribir las cantidades.
    if (idReserva != null) {
      return;
    }
    // Si no hay actividad seleccionada, limpia los materiales solicitados.
    final Activity? actividad = buscarActividadSeleccionada(actividades);
    if (actividad == null) {
      materialesSolicitados = {};
      return;
    }

    final int participantes = numeroParticipantes;
    // Variable que guarda las entradas del mapa materialesPorParticipante para poder recorrerlas.
    final Iterable<MapEntry<int, int>> plantilla = actividad.materialsPerParticipant.entries;
    final Map<int, int> recalculado = {};

    for (final MapEntry<int, int> entry in plantilla) {
      // Calcula la cantidad total para este material multiplicando la cantidad por persona por el número de participantes.
      final int total = entry.value * participantes;

      // Materiales que su cantidad total sea mayor que 0.
      if (total > 0) {
        recalculado[entry.key] = total;
      }
    }

    materialesSolicitados = recalculado;
  }

  // TEMPORAL: el backend creará la reserva y devolverá el ID real. Eliminar GeneradorId.idEntero() de aquí.
  // Construye una reserva a partir de la solicitud actual.
  Reservation? construirReserva(List<Activity> actividades) {
    if (idUsuario == null) {
      return null;
    }

    // Crea las líneas de reserva a partir de los materiales solicitados.
    final List<ReservationLine> lineas = lineasDesdeMateriales();
    if (lineas.isEmpty) {
      return null;
    }

    final Activity? actividad = buscarActividadSeleccionada(actividades);
    final DateTime inicio = actividad?.initDate ?? DateTime.now();
    final DateTime fin = actividad?.endDate ?? inicio.add(const Duration(days: 1));

    final Reservation reserva = Reservation(
      id: GeneradorId.idEntero(),
      userId: idUsuario!,
      lines: lineas,
      activityId: idActividad,
      startDate: inicio,
      endDate: fin,
      status: ReservationStatus.pendiente,
    );

    idReserva = reserva.id;
    return reserva;
  }

  // Busca una reserva por su ID en una lista de reservas.
  Reservation? buscarReserva(List<Reservation> reservas, int id) {
    for (final Reservation r in reservas) {
      if (r.id == id) {
        return r;
      }
    }
    return null;
  }

  // Sincroniza la reserva existente con los datos actuales de la solicitud.
  Reservation? sincronizarReserva(Request solicitud, List<Reservation> reservas) {
    // Obtiene el ID de la reserva asociada a la solicitud.
    final int? idRes = solicitud.reservationId;
    if (idRes == null) {
      return null;
    }
    
    // Busca esa reserva en la lista por su ID. 
    final Reservation? reserva = buscarReserva(reservas, idRes);
    if (reserva == null) {
      return null;
    }

    // Convierte los materiales actuales del formulario (materialesSolicitados) en líneas de reserva.
    final List<ReservationLine> lineas = lineasDesdeMateriales();
    if (lineas.isEmpty) {
      return null;
    }

    // Devuelve una copia de la reserva original con los datos actualizados.
    return reserva.copyWith(
      userId: solicitud.userId ?? reserva.userId,
      activityId: solicitud.activityId,
      lines: lineas,
    );
  }

  // Crea una reserva a partir de los datos actuales. Devuelve null si hay error de validación.
  Reservation? crearReserva(List<Activity> actividades) {
    final Reservation? reserva = construirReserva(actividades);
    return reserva;
  }

  // Sincroniza la reserva asociada a la solicitud con los datos actuales. Devuelve la reserva actualizada.
  Reservation? sincronizarReservaConSolicitud(Request solicitud, List<Reservation> reservas) {
    final Reservation? actualizada = sincronizarReserva(solicitud, reservas);
    return actualizada;
  }

  // Devuelve la reserva actual, o null si no hay ninguna asociada.
  Reservation? buscarReservaActual(List<Reservation> reservas) {
    if (idReserva == null) {
      return null;
    }
    return buscarReserva(reservas, idReserva!);
  }

  // Comprueba si la reserva asociada sigue existiendo en la lista.
  bool reservaExiste(List<Reservation> reservas) {
    if (idReserva == null) {
      return false;
    }
    return reservas.any((Reservation r) => r.id == idReserva);
  }

  // Actualiza los materiales del formulario a partir de la reserva resultado.
  void actualizarDesdeReserva(Reservation resultado) {
    materialesSolicitados = materialesDesdeLineas(resultado.lines);
  }

  // Calcula el precio total de la solicitud delegando al servicio de pricing.
  double calcularPrecioTotal(List<Activity> actividades, List<Equipment> equipamientos) {
    return calcularPrecioSolicitud(
      idActividad: idActividad,
      numeroParticipantes: numeroParticipantes,
      materialesSolicitados: materialesSolicitados,
      actividades: actividades,
      equipamientos: equipamientos,
    );
  }

  bool get tieneMateriales {
    return materialesSolicitados.values.any((int v) => v > 0);
  }

  String? mensajeErrorReserva(BuildContext context) {
    if (idUsuario == null) {
      return AppLocalizations.of(context)!.selectClientForReservation;
    }
    if (!tieneMateriales) {
      return AppLocalizations.of(context)!.addAtLeastOneMaterial;
    }
    return null;
  }

  void limpiar() {
    editando = false;
    seleccionado = null;
    idActividad = null;
    participantesCtrl.clear();
    estado = RequestStatus.pendiente;
    idExperto = null;
    idUsuario = null;
    idReserva = null;
    materialesSolicitados = {};
  }

  void dispose() {
    participantesCtrl.dispose();
  }

  // Crea una reserva a partir de los datos actuales del formulario.
  // Si hay un error de validación, muestra un snackbar y devuelve null.
  Reservation? crearReservaDesdeSolicitud({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final String? error = mensajeErrorReserva(context);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return null;
    }
    final List<Activity> actividades = ref.read(activitiesProvider).value ?? [];
    final Reservation? reserva = crearReserva(actividades);
    if (reserva != null) {
      ref.read(reservationsProvider.notifier).agregar(reserva);
    }
    return reserva;
  }
}
