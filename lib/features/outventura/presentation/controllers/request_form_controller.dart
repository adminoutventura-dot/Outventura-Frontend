import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/id_generator.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';

class SolicitudFormController {
  // Referencia al WidgetRef para leer/escribir providers
  final WidgetRef _ref;

  // Constructor que recibe el WidgetRef para acceder a los providers necesarios.
  SolicitudFormController(this._ref);

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
  Solicitud? crearSolicitud(List<Excursion> excursiones, List<Equipamiento> equipamientos) {
    if (!validar()) {
      return null;
    }

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
  Excursion? buscarExcursionSeleccionada(List<Excursion> excursiones) {
    if (idExcursion == null) {
      return null;
    }
    for (final Excursion e in excursiones) {
      if (e.id == idExcursion) {
        return e;
      }
    }
    return null;
  }

  // Recalcula los materiales solicitados basándose en la excursión seleccionada y el número de participantes.
  void recalcularMateriales(List<Excursion> excursiones) {
    // Si ya existe una reserva asociada, no sobreescribir las cantidades.
    if (idReserva != null) {
      return;
    }
    // Si no hay excursión seleccionada, limpia los materiales solicitados.
    final Excursion? excursion = buscarExcursionSeleccionada(excursiones);
    if (excursion == null) {
      materialesSolicitados = {};
      return;
    }

    final int participantes = numeroParticipantes;
    // Variable que guarda las entradas del mapa materialesPorParticipante para poder recorrerlas.
    final Iterable<MapEntry<int, int>> plantilla = excursion.materialesPorParticipante.entries;
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

  // Construye una reserva a partir de la solicitud actual.
  Reserva? construirReserva(List<Excursion> excursiones) {
    if (idUsuario == null) {
      return null;
    }

    // Crea las líneas de reserva a partir de los materiales solicitados.
    final List<LineaReserva> lineas = lineasDesdeMateriales();
    if (lineas.isEmpty) {
      return null;
    }

    final Excursion? excursion = buscarExcursionSeleccionada(excursiones);
    final DateTime inicio = excursion?.fechaInicio ?? DateTime.now();
    final DateTime fin = excursion?.fechaFin ?? inicio.add(const Duration(days: 1));

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

  // Crea una reserva y la añade al provider. Devuelve null si hay error de validación.
  Reserva? crearReserva() {
    final Reserva? reserva = construirReserva(_ref.read(excursionesProvider));
    if (reserva == null) {
      return null;
    }
    _ref.read(reservasProvider.notifier).agregar(reserva);
    return reserva;
  }

  // Sincroniza la reserva asociada a la solicitud con los datos actuales, actualizando el provider.
  void sincronizarReservaConSolicitud(Solicitud solicitud) {
    // Reservas actuales.
    final List<Reserva> reservas = _ref.read(reservasProvider);

    // Reserva actualizada con los datos de la solicitud. 
    final Reserva? actualizada = sincronizarReserva(solicitud, reservas);
    if (actualizada == null) {
      return;
    }

    // Reserva original antes de la actualización.
    final Reserva? original = buscarReserva(reservas, solicitud.idReserva!);

    // Si no hay reserva original, significa que es una nueva reserva que debe añadirse.
    if (original != null) {
      _ref.read(reservasProvider.notifier).actualizar(original, actualizada);
    }
  }

  // Devuelve la reserva actual del provider, o null si no hay ninguna asociada.
  Reserva? buscarReservaActual() {
    if (idReserva == null) {
      return null;
    }
    return buscarReserva(_ref.read(reservasProvider), idReserva!);
  }

  // Comprueba si la reserva asociada sigue existiendo en el provider.
  bool reservaExiste() {
    if (idReserva == null) {
      return false;
    }
    return _ref.read(reservasProvider).any((Reserva r) => r.id == idReserva);
  }

  // Actualiza la reserva en el provider y sincroniza los materiales del formulario.
  void actualizarDesdeReserva(Reserva original, Reserva resultado) {
    _ref.read(reservasProvider.notifier).actualizar(original, resultado);
    materialesSolicitados = materialesDesdeLineas(resultado.lineas);
  }

  // Calcula el precio total de la solicitud: precio excursión × participantes + alquiler materiales.
  double calcularPrecioTotal(List<Excursion> excursiones, List<Equipamiento> equipamientos) {
    final Excursion? excursion = buscarExcursionSeleccionada(excursiones);
    if (excursion == null) {
      return 0;
    }

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

  bool get tieneMateriales {
    return materialesSolicitados.values.any((int v) => v > 0);
  }

  String? get mensajeErrorReserva {
    if (idUsuario == null) {
      return 'Selecciona un cliente para reservar materiales.';
    }
    if (!tieneMateriales) {
      return 'Añade al menos un material para crear la reserva.';
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
}
