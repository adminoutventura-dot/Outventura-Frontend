import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/id_generator.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/services/pricing_service.dart';
import 'package:outventura/l10n/app_localizations.dart';

class RequestFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController participantesCtrl = TextEditingController();

  int? idExcursion;
  int get numeroParticipantes => int.tryParse(participantesCtrl.text) ?? 1;
  EstadoSolicitud estado = EstadoSolicitud.pendiente;
  int? idExperto;
  int? idUsuario;
  int? idReserva;
  Map<int, int> materialesSolicitados = {};

  bool editando = false;
  Solicitud? seleccionado;

  bool validar() {
    if (formKey.currentState == null) return false;
    return formKey.currentState!.validate();
  }

  // Carga los datos de una solicitud en el formulario para su edición.
  void cargarSolicitud(Solicitud solicitud) {
    editando = true;
    seleccionado = solicitud;
    idExcursion = solicitud.idExcursion;
    participantesCtrl.text = '${solicitud.numeroParticipantes}';
    estado = solicitud.estado;
    idExperto = solicitud.idExperto;
    idUsuario = solicitud.idUsuario;
    idReserva = solicitud.idReserva;
    materialesSolicitados = Map<int, int>.from(solicitud.materialesSolicitados);
  }

  // Aplica los valores de la excursión seleccionada y el usuario.
  void aplicarValoresIniciales({int? idExcursion, int? idUsuario}) {
    this.idExcursion = idExcursion;
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
  Solicitud? crearSolicitud(List<Activity> excursiones, List<Equipamiento> equipamientos) {
    if (!validar()) {
      return null;
    }

    // TEMPORAL: idEntero() se elimina cuando el backend asigne IDs reales. precio vendrá del backend.
    final int id = seleccionado?.id ?? GeneradorId.idEntero();
    final double precio = calcularPrecioTotal(excursiones, equipamientos);

    return Solicitud(
      id: id,
      idExcursion: idExcursion!,
      numeroParticipantes: numeroParticipantes,
      estado: estado,
      idExperto: idExperto,
      idUsuario: idUsuario,
      idReserva: idReserva,
      materialesSolicitados: Map<int, int>.from(materialesSolicitados),
      precioTotal: precio,
    );
  }

  // Convierte una lista de líneas de reserva en un mapa {idEquipamiento → cantidad}.
  Map<int, int> materialesDesdeLineas(List<LineaReserva> lineas) {
    final Map<int, int> materiales = {};
    for (final LineaReserva linea in lineas) {
      materiales[linea.idEquipamiento] = linea.cantidad;
    }
    return materiales;
  }

  // Convierte el mapa en lista de LineaReserva, filtrando los que tengan cantidad 0.
  List<LineaReserva> lineasDesdeMateriales() {
    return materialesSolicitados.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) =>
              LineaReserva(idEquipamiento: entry.key, cantidad: entry.value),
        )
        .toList();
  }

  // Busca la excursión seleccionada en la lista de excursiones disponibles.
  Activity? buscarExcursionSeleccionada(List<Activity> excursiones) {
    if (idExcursion == null) {
      return null;
    }
    for (final Activity e in excursiones) {
      if (e.id == idExcursion) {
        return e;
      }
    }
    return null;
  }

  // TEMPORAL: reemplazar por GET /api/precio-solicitud con parámetros. El backend calculará el precio total.
  // Recalcula los materiales solicitados basándose en la excursión seleccionada y el número de participantes.
  void recalcularMateriales(List<Activity> excursiones) {
    // Si ya existe una reserva asociada, no sobreescribir las cantidades.
    if (idReserva != null) {
      return;
    }
    // Si no hay excursión seleccionada, limpia los materiales solicitados.
    final Activity? excursion = buscarExcursionSeleccionada(excursiones);
    if (excursion == null) {
      materialesSolicitados = {};
      return;
    }

    final int participantes = numeroParticipantes;
    // Variable que guarda las entradas del mapa materialesPorParticipante para poder recorrerlas.
    final Iterable<MapEntry<int, int>> plantilla = excursion.materialsPerParticipant.entries;
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
  Reserva? construirReserva(List<Activity> excursiones) {
    if (idUsuario == null) {
      return null;
    }

    // Crea las líneas de reserva a partir de los materiales solicitados.
    final List<LineaReserva> lineas = lineasDesdeMateriales();
    if (lineas.isEmpty) {
      return null;
    }

    final Activity? excursion = buscarExcursionSeleccionada(excursiones);
    final DateTime inicio = excursion?.initDate ?? DateTime.now();
    final DateTime fin = excursion?.endDate ?? inicio.add(const Duration(days: 1));

    final Reserva reserva = Reserva(
      id: GeneradorId.idEntero(),
      idUsuario: idUsuario!,
      lineas: lineas,
      idExcursion: idExcursion,
      fechaInicio: inicio,
      fechaFin: fin,
      estado: EstadoReserva.pendiente,
    );

    idReserva = reserva.id;
    return reserva;
  }

  // Busca una reserva por su ID en una lista de reservas.
  Reserva? buscarReserva(List<Reserva> reservas, int id) {
    for (final Reserva r in reservas) {
      if (r.id == id) {
        return r;
      }
    }
    return null;
  }

  // Sincroniza la reserva existente con los datos actuales de la solicitud.
  Reserva? sincronizarReserva(Solicitud solicitud, List<Reserva> reservas) {
    // Obtiene el ID de la reserva asociada a la solicitud.
    final int? idRes = solicitud.idReserva;
    if (idRes == null) {
      return null;
    }
    
    // Busca esa reserva en la lista por su ID. 
    final Reserva? reserva = buscarReserva(reservas, idRes);
    if (reserva == null) {
      return null;
    }

    // Convierte los materiales actuales del formulario (materialesSolicitados) en líneas de reserva.
    final List<LineaReserva> lineas = lineasDesdeMateriales();
    if (lineas.isEmpty) {
      return null;
    }

    // Devuelve una copia de la reserva original con los datos actualizados.
    return reserva.copyWith(
      idUsuario: solicitud.idUsuario ?? reserva.idUsuario,
      idExcursion: solicitud.idExcursion,
      lineas: lineas,
    );
  }

  // Crea una reserva a partir de los datos actuales. Devuelve null si hay error de validación.
  Reserva? crearReserva(List<Activity> excursiones) {
    final Reserva? reserva = construirReserva(excursiones);
    return reserva;
  }

  // Sincroniza la reserva asociada a la solicitud con los datos actuales. Devuelve la reserva actualizada.
  Reserva? sincronizarReservaConSolicitud(Solicitud solicitud, List<Reserva> reservas) {
    final Reserva? actualizada = sincronizarReserva(solicitud, reservas);
    return actualizada;
  }

  // Devuelve la reserva actual, o null si no hay ninguna asociada.
  Reserva? buscarReservaActual(List<Reserva> reservas) {
    if (idReserva == null) {
      return null;
    }
    return buscarReserva(reservas, idReserva!);
  }

  // Comprueba si la reserva asociada sigue existiendo en la lista.
  bool reservaExiste(List<Reserva> reservas) {
    if (idReserva == null) {
      return false;
    }
    return reservas.any((Reserva r) => r.id == idReserva);
  }

  // Actualiza los materiales del formulario a partir de la reserva resultado.
  void actualizarDesdeReserva(Reserva resultado) {
    materialesSolicitados = materialesDesdeLineas(resultado.lineas);
  }

  // Calcula el precio total de la solicitud delegando al servicio de pricing.
  double calcularPrecioTotal(List<Activity> excursiones, List<Equipamiento> equipamientos) {
    return calcularPrecioSolicitud(
      idExcursion: idExcursion,
      numeroParticipantes: numeroParticipantes,
      materialesSolicitados: materialesSolicitados,
      excursiones: excursiones,
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
    idExcursion = null;
    participantesCtrl.clear();
    estado = EstadoSolicitud.pendiente;
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
  Reserva? crearReservaDesdeSolicitud({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final String? error = mensajeErrorReserva(context);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return null;
    }
    final List<Activity> excursiones = ref.read(excursionesProvider).value ?? [];
    final Reserva? reserva = crearReserva(excursiones);
    if (reserva != null) {
      ref.read(reservasProvider.notifier).agregar(reserva);
    }
    return reserva;
  }
}
