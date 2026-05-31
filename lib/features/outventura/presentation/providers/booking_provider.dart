import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart' as user_providers;
import 'package:outventura/features/outventura/data/models/booking_model.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/services/resolvers.dart';

class _LineSnapshot {
  final int id;
  final int? equipmentId;
  final int? activityId;
  final int quantity;

  const _LineSnapshot({
    required this.id,
    required this.equipmentId,
    required this.activityId,
    required this.quantity,
  });

  String? get key {
    if (equipmentId != null) return 'equipment:$equipmentId';
    if (activityId != null) return 'activity:$activityId';
    return null;
  }
}

int _statusIdFrom(WorkflowStatus status) {
  switch (status.code) {
    case 'PENDING':
      return 1;
    case 'ACCEPTED':
      return 2;
    case 'IN_PROGRESS':
      return 3;
    case 'FINISHED':
      return 4;
    case 'CANCELLED':
      return 5;
    default:
      return 1;
  }
}

Map<String, dynamic> _createBookingPayload(Booking reserva) {
  return {
    'userId': reserva.userId,
    'init_date': reserva.startDate.toIso8601String(),
    'end_date': reserva.endDate.toIso8601String(),
  };
}

Map<String, dynamic> _createBookingUpdatePayload(Booking viejo, Booking nuevo) {
  final Map<String, dynamic> payload = {};

  if (viejo.userId != nuevo.userId) {
    payload['userId'] = nuevo.userId;
  }

  if (!viejo.startDate.isAtSameMomentAs(nuevo.startDate)) {
    payload['init_date'] = nuevo.startDate.toIso8601String();
  }

  if (!viejo.endDate.isAtSameMomentAs(nuevo.endDate)) {
    payload['end_date'] = nuevo.endDate.toIso8601String();
  }

  if (viejo.status != nuevo.status) {
    payload['statusId'] = _statusIdFrom(nuevo.status);
  }

  return payload;
}

Map<String, int> _aggregateDesiredLines(List<BookingLine> lines) {
  final Map<String, int> aggregated = {};
  for (final line in lines) {
    if (line.quantity <= 0) continue;
    final String? key = line.equipmentId != null
        ? 'equipment:${line.equipmentId}'
        : line.activityId != null
            ? 'activity:${line.activityId}'
            : null;
    if (key == null) continue;
    aggregated[key] = (aggregated[key] ?? 0) + line.quantity;
  }
  return aggregated;
}

bool _sameAggregatedLines(List<BookingLine> a, List<BookingLine> b) {
  final left = _aggregateDesiredLines(a);
  final right = _aggregateDesiredLines(b);
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}

Map<String, dynamic> _createLinePayload({
  required int bookingId,
  required String key,
  required int quantity,
}) {
  final parts = key.split(':');
  final type = parts.first;
  final id = int.tryParse(parts.last);
  if (id == null) {
    return {'bookingId': bookingId, 'quantity': quantity};
  }
  return {
    'bookingId': bookingId,
    'quantity': quantity,
    if (type == 'equipment') 'equipmentId': id,
    if (type == 'activity') 'activityId': id,
  };
}

List<dynamic> _extractListPayload(dynamic raw) {
  if (raw is List) return raw;
  if (raw is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'lines',
      'bookingLines',
      'booking_lines',
    ]) {
      final value = raw[key];
      if (value is List) return value;
    }
  }
  return const [];
}

int? _parseNestedId(Map<String, dynamic> map, String relationKey, String idKey) {
  final relation = map[relationKey];
  if (relation is! Map<String, dynamic>) return null;
  return relation[idKey] as int? ?? relation['id'] as int?;
}

int? _parseBookingIdFromLine(Map<String, dynamic> map) {
  return map['bookingId'] as int? ??
      map['booking_id'] as int? ??
      _parseNestedId(map, 'booking', 'id_booking');
}

int? _parseLineId(Map<String, dynamic> map) {
  return map['id_line'] as int? ??
      map['idLine'] as int? ??
      map['id'] as int?;
}

int? _parseEquipmentIdFromLine(Map<String, dynamic> map) {
  final dynamic equipment = map['equipment'];
  if (equipment is int) return equipment;
  return map['equipmentId'] as int? ??
      map['equipment_id'] as int? ??
      map['id_equipment'] as int? ??
      _parseNestedId(map, 'equipment', 'id_equipment');
}

int? _parseActivityIdFromLine(Map<String, dynamic> map) {
  final dynamic activity = map['activity'];
  if (activity is int) return activity;
  return map['activityId'] as int? ??
      map['activity_id'] as int? ??
      map['id_activity'] as int? ??
      _parseNestedId(map, 'activity', 'id_activity');
}

_LineSnapshot? _parseLineSnapshot(Map<String, dynamic> map) {
  final int? lineId = _parseLineId(map);
  if (lineId == null) return null;

  final int? equipmentId = _parseEquipmentIdFromLine(map);
  final int? activityId = _parseActivityIdFromLine(map);
  if (equipmentId == null && activityId == null) return null;

  return _LineSnapshot(
    id: lineId,
    equipmentId: equipmentId,
    activityId: activityId,
    quantity: int.tryParse(map['quantity'].toString()) ?? 0,
  );
}


List<_LineSnapshot> _snapshotsFromBookingLines(List<BookingLine> lines) {
  return lines
      .where((line) => line.id != null)
      .map(
        (line) => _LineSnapshot(
          id: line.id!,
          equipmentId: line.equipmentId,
          activityId: line.activityId,
          quantity: line.quantity,
        ),
      )
      .where((line) => line.key != null)
      .toList();
}

List<BookingLine> _linesFromSnapshots(List<_LineSnapshot> snapshots) {
  return snapshots
      .map(
        (line) => BookingLine(
          id: line.id,
          equipmentId: line.equipmentId,
          activityId: line.activityId,
          quantity: line.quantity,
        ),
      )
      .toList();
}

Future<Map<int, List<_LineSnapshot>>> _fetchAllBookingLinesGrouped(
  Dio dio,
) async {
  final response = await dio.get('/booking-line');
  final List<dynamic> data = _extractListPayload(response.data);
  final Map<int, List<_LineSnapshot>> grouped = {};

  for (final item in data) {
    if (item is! Map<String, dynamic>) continue;
    final snapshot = _parseLineSnapshot(item);
    if (snapshot == null) continue;

    final int? bookingId = _parseBookingIdFromLine(item);
    if (bookingId == null) continue;
    grouped.putIfAbsent(bookingId, () => []).add(snapshot);
  }

  return grouped;
}

Future<List<_LineSnapshot>> _fetchBookingLines(
  Dio dio,
  int bookingId, {
  Map<int, List<_LineSnapshot>>? cache,
}) async {
  if (cache != null && cache.containsKey(bookingId)) {
    return cache[bookingId]!;
  }

  if (cache != null) {
    return cache[bookingId] ?? const [];
  }

  try {
    final response = await dio.get(
      '/booking-line',
      queryParameters: {'bookingId': bookingId},
    );
    final List<dynamic> rawList = _extractListPayload(response.data);
    final List<_LineSnapshot> snapshots = [];
    for (final item in rawList) {
      if (item is! Map<String, dynamic>) continue;
      final parsedId = _parseBookingIdFromLine(item);
      if (parsedId == bookingId) {
        final snap = _parseLineSnapshot(item);
        if (snap != null) {
          snapshots.add(snap);
        }
      }
    }
    return snapshots;
  } catch (_) {
    final grouped = await _fetchAllBookingLinesGrouped(dio);
    return grouped[bookingId] ?? const [];
  }
}

Booking _mergeBookingLines(
  Booking booking,
  List<_LineSnapshot> fetched,
) {
  final List<BookingLine> mergedLines = [];

  for (final line in booking.lines) {
    mergedLines.add(line);
  }

  for (final snapLine in _linesFromSnapshots(fetched)) {
    final bool alreadyExists = mergedLines.any((l) => l.id == snapLine.id);
    
    if (!alreadyExists) {
      mergedLines.add(snapLine);
    }
  }

  if (mergedLines.isEmpty) return booking;
  return booking.copyWith(lines: mergedLines);
}

Future<void> _syncBookingLines(
  Dio dio,
  int bookingId,
  List<BookingLine> desiredLines, {
  Map<int, List<_LineSnapshot>>? cache,
  List<BookingLine>? fallbackExistingLines,
}) async {
  List<_LineSnapshot> existingLines =
      await _fetchBookingLines(dio, bookingId, cache: cache);

  if (existingLines.isEmpty && fallbackExistingLines != null) {
    existingLines = _snapshotsFromBookingLines(fallbackExistingLines);
  }

  final Map<String, _LineSnapshot> existingByKey = {
    for (final line in existingLines) line.key!: line,
  };

  final Map<String, int> desiredByKey = _aggregateDesiredLines(desiredLines);
  final Set<String> fallbackKeys = {
    if (fallbackExistingLines != null)
      for (final line in fallbackExistingLines)
        if (line.equipmentId != null) 'equipment:${line.equipmentId}',
    if (fallbackExistingLines != null)
      for (final line in fallbackExistingLines)
        if (line.activityId != null) 'activity:${line.activityId}',
  };

  for (final entry in desiredByKey.entries) {
    final existing = existingByKey.remove(entry.key);
    if (existing == null) {
      if (fallbackKeys.contains(entry.key)) {
        continue;
      }
      await dio.post(
        '/booking-line',
        data: _createLinePayload(
          bookingId: bookingId,
          key: entry.key,
          quantity: entry.value,
        ),
      );
      continue;
    }
    if (existing.quantity != entry.value) {
      await dio.patch(
        '/booking-line/${existing.id}',
        data: {'quantity': entry.value},
      );
    }
  }

  for (final remaining in existingByKey.values) {
    await dio.delete('/booking-line/${remaining.id}');
  }
}

enum TipoReserva { todas, materiales, actividades }

final AsyncNotifierProvider<ReservationsNotifier, List<Booking>>
reservationsProvider =
    AsyncNotifierProvider<ReservationsNotifier, List<Booking>>(
      ReservationsNotifier.new,
    );

final filteredReservationsProvider =
    Provider.family<
      AsyncValue<List<Booking>>,
      ({
        String query,
        int? idUsuario,
        WorkflowStatus? estado,
        DateTime? fechaDesde,
        DateTime? fechaHasta,
        TipoReserva tipo,
      })
    >((ref, params) {
      final AsyncValue<List<Booking>> asyncTodas = ref.watch(
        reservationsProvider,
      );
      final List<User> usuarios = ref.watch(user_providers.usuariosProvider).value ?? [];
      final List<Activity> actividades =
          ref.watch(activitiesProvider).value ?? [];

      return asyncTodas.whenData((List<Booking> todas) {
        List<Booking> base = todas;

        if (params.idUsuario != null) {
          base = base
              .where((Booking r) => r.userId == params.idUsuario)
              .toList();
        }

        if (params.estado != null) {
          base = base.where((Booking r) => r.status == params.estado).toList();
        }

        if (params.fechaDesde != null) {
          base = base
              .where((Booking r) => !r.endDate.isBefore(params.fechaDesde!))
              .toList();
        }
        if (params.fechaHasta != null) {
          base = base
              .where((Booking r) => !r.startDate.isAfter(params.fechaHasta!))
              .toList();
        }

        if (params.tipo == TipoReserva.materiales) {
          base = base
              .where((b) => !b.lines.any((l) => l.activityId != null))
              .toList();
        } else if (params.tipo == TipoReserva.actividades) {
          base = base
              .where((b) => b.lines.any((l) => l.activityId != null))
              .toList();
        }

        if (params.query.isEmpty) {
          return base;
        }

        final String q = params.query.toLowerCase();
        return base.where((Booking r) {
          final String nombreU = resolverNombreUsuario(
            r.userId,
            usuarios,
          ).toLowerCase();

          final lineAct = r.lines
              .where((l) => l.activityId != null)
              .firstOrNull;
          final String nombreAct = lineAct != null
              ? (resolverNombreActividad(lineAct.activityId, actividades) ?? '')
                    .toLowerCase()
              : '';

          return nombreU.contains(q) || nombreAct.contains(q);
        }).toList();
      });
    });

final pendingBookingsCountProvider = Provider.family<int, int>((ref, userId) {
  return (ref.watch(reservationsProvider).value ?? [])
      .where((s) => s.userId == userId && s.status == WorkflowStatus.pendiente)
      .length;
});

class ReservationsNotifier extends AsyncNotifier<List<Booking>> {
  int currentPage = 1;
  int totalPages = 1;
  final int _itemsPerPage = 3;

  Map<int, List<_LineSnapshot>>? _linesCache;
  List<Booking> _allBookings = [];

  List<Booking> get allBookings => _allBookings;

  String _query = '';
  WorkflowStatus? _estado;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  TipoReserva _tipo = TipoReserva.todas;
  int? _guideId; // Filtro por guía

  @override
  Future<List<Booking>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/booking',
        queryParameters: {'page': 1, 'limit': 99999},
      );
      final raw = response.data;

      final List<dynamic> data = raw is List
          ? raw
          : (raw['data'] as List<dynamic>);

      final bookings = data
          .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
          .toList();

      _linesCache = await _fetchAllBookingLinesGrouped(dio);

      _allBookings = bookings
          .map(
            (booking) => _mergeBookingLines(
              booking,
              booking.id == null ? const [] : (_linesCache![booking.id!] ?? const []),
            ),
          )
          .toList();

      return _procesarFiltrosYPaginas();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  List<Booking> _procesarFiltrosYPaginas() {
    List<Booking> resultado = _allBookings;

    // Filtro por Guía (se aplica antes de la paginación)
    if (_guideId != null) {
      final actividades = ref.read(activitiesProvider).value ?? [];
      resultado = resultado.where((res) {
        return res.lines.any((l) {
          if (l.activityId == null) return false;
          final act = actividades.where((a) => a.id == l.activityId).firstOrNull;
          return act?.guideId == _guideId;
        });
      }).toList();
    }

    // Filtro por Estado
    if (_estado != null) {
      resultado = resultado.where((r) => r.status == _estado).toList();
    }

    // Filtro por Fecha Desde
    if (_fechaDesde != null) {
      resultado = resultado.where((r) => !r.endDate.isBefore(_fechaDesde!)).toList();
    }

    // Filtro por Fecha Hasta
    if (_fechaHasta != null) {
      resultado = resultado.where((r) => !r.startDate.isAfter(_fechaHasta!)).toList();
    }

    // Filtro por Tipo
    if (_tipo == TipoReserva.materiales) {
      resultado = resultado.where((b) => !b.lines.any((l) => l.activityId != null)).toList();
    } else if (_tipo == TipoReserva.actividades) {
      resultado = resultado.where((b) => b.lines.any((l) => l.activityId != null)).toList();
    }

    // Filtro por Texto
    if (_query.isNotEmpty) {
      final usuarios = ref.read(user_providers.usuariosProvider).value ?? [];
      final actividades = ref.read(activitiesProvider).value ?? [];
      final String q = _query.toLowerCase();

      resultado = resultado.where((Booking r) {
        final String nombreU = resolverNombreUsuario(r.userId, usuarios).toLowerCase();

        final lineAct = r.lines.where((l) => l.activityId != null).firstOrNull;
        final String nombreAct = lineAct != null
            ? (resolverNombreActividad(lineAct.activityId, actividades) ?? '').toLowerCase()
            : '';

        return nombreU.contains(q) || nombreAct.contains(q);
      }).toList();
    }

    if (resultado.isEmpty) {
      currentPage = 1;
      totalPages = 1;
      return [];
    }

    totalPages = (resultado.length / _itemsPerPage).ceil();

    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;

    final int indiceInicio = (currentPage - 1) * _itemsPerPage;
    final int indiceFin = indiceInicio + _itemsPerPage;

    return resultado.sublist(
      indiceInicio,
      indiceFin > resultado.length ? resultado.length : indiceFin
    );
  }

  void aplicarFiltroTexto(String texto) {
    _query = texto;
    currentPage = 1;
    state = AsyncData(_procesarFiltrosYPaginas());
  }

  void aplicarFiltrosAvanzados({
    WorkflowStatus? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    TipoReserva? tipo,
    int? guideId,
  }) {
    _estado = estado;
    _fechaDesde = fechaDesde;
    _fechaHasta = fechaHasta;
    if (tipo != null) _tipo = tipo;
    _guideId = guideId;
    currentPage = 1;
    state = AsyncData(_procesarFiltrosYPaginas());
  }

  void cambiarPagina(int nuevaPagina) {
    if (nuevaPagina < 1 || nuevaPagina > totalPages || nuevaPagina == currentPage) {
      return;
    }
    currentPage = nuevaPagina;
    state = AsyncData(_procesarFiltrosYPaginas());
  }

  // MÉTODO AGREGAR ULTRA PROTEGIDO CONTRA ERRORES SILENCIOSOS
  Future<Booking> agregar(Booking reserva) async {
    // Si la reserva contiene materiales, comprueba la antelación antes de tocar el servidor
    final bool tieneMateriales = reserva.lines.any((l) => l.equipmentId != null);
    if (tieneMateriales) {
      final DateTime ahora = DateTime.now();
      final DateTime limite48h = ahora.add(const Duration(hours: 48));
      
      if (reserva.startDate.isBefore(limite48h)) {
        // Frena la ejecución. No se enviará nada a la base de datos
        throw 'Las reservas de material se deben realizar con un mínimo de 48h de antelación.';
      }
    }

    int? idReservaCreada;
    try {
      final dio = ref.read(dioProvider);
      
      final response = await dio.post(
        '/booking',
        data: _createBookingPayload(reserva),
      );
      final Booking created = BookingModel.fromMap(
        response.data as Map<String, dynamic>,
      );

      idReservaCreada = created.id;

      if (idReservaCreada != null) {
        if (reserva.lines.isNotEmpty) {
          await _syncBookingLines(
            dio,
            idReservaCreada,
            reserva.lines,
            cache: _linesCache,
          );
        }

        if (reserva.status != WorkflowStatus.pendiente) {
          await dio.patch(
            '/booking/$idReservaCreada',
            data: {'statusId': _statusIdFrom(reserva.status)},
          );
        }
      }

      ref.invalidateSelf();
      ref.invalidate(user_providers.usuariosProvider);
      return created;
    } on DioException catch (e) {
      if (idReservaCreada != null) {
        try {
          await ref.read(dioProvider).delete('/booking/$idReservaCreada');
        } catch (_) {}
      }

      // Sincroniza la UI con la realidad del backend incluso en caso de error
      // para evitar que aparezcan "fantasmas" más tarde si el rollback falla.
      ref.invalidateSelf();

      final String errorTexto = e.response?.toString() ?? e.message ?? e.toString();
      if (errorTexto.contains("48h") || errorTexto.contains("mínim de 48h") || errorTexto.contains("material")) {
        throw 'Las reservas de material se deben realizar con un mínimo de 48h de antelación.';
      }

      throw parseDioError(e);
    } catch (e) {
      if (idReservaCreada != null) {
        try {
          await ref.read(dioProvider).delete('/booking/$idReservaCreada');
        } catch (_) {}
      }
      ref.invalidateSelf();
      
      final String txt = e.toString();
      if (txt.contains("48h") || txt.contains("mínim de 48h") || txt.contains("material")) {
        throw 'Las reservas de material se deben realizar con un mínimo de 48h de antelación.';
      }
      rethrow;
    }
  }

  Future<void> actualizar(Booking viejo, Booking nuevo) async {
    if (viejo.id == null) throw StateError('Booking has no id');
    try {
      final dio = ref.read(dioProvider);
      _linesCache ??= await _fetchAllBookingLinesGrouped(dio);

      final Map<String, dynamic> bookingPatch = _createBookingUpdatePayload(viejo, nuevo);
      if (bookingPatch.isNotEmpty) {
        await dio.patch('/booking/${viejo.id}', data: bookingPatch);
      }

      if (!_sameAggregatedLines(viejo.lines, nuevo.lines)) {
        await _syncBookingLines(
          dio,
          viejo.id!,
          nuevo.lines,
          cache: _linesCache,
          fallbackExistingLines: viejo.lines,
        );
      }

      ref.invalidateSelf();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> eliminar(Booking reserva) async {
    if (reserva.id == null) throw StateError('Booking has no id');
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/booking/${reserva.id}');
      final List<Booking> listaActual = [...(state.value ?? [])];
      listaActual.removeWhere((Booking r) => r.id == reserva.id);
      state = AsyncData(listaActual);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // Acciones de estado
  Future<void> aprobar(Booking reserva) async {
    final Booking aprobada = reserva.copyWith(
      status: WorkflowStatus.confirmada,
    );
    await actualizar(reserva, aprobada);
  }

  Future<void> cancelar(Booking reserva) async {
    final Booking cancelada = reserva.copyWith(
      status: WorkflowStatus.cancelada,
    );
    await actualizar(reserva, cancelada);
  }

  Future<void> registrarDevolucion(Booking reserva) async {
    final Booking devuelta = reserva.copyWith(
      status: WorkflowStatus.finalizada,
    );
    await actualizar(reserva, devuelta);
  }
}