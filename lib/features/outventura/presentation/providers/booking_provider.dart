import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
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
    case 'CONFIRMED':
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

List<_LineSnapshot> _parseLineSnapshots(List<dynamic> data) {
  return data
      .whereType<Map<String, dynamic>>()
      .map(_parseLineSnapshot)
      .whereType<_LineSnapshot>()
      .toList();
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

  for (final param in const ['bookingId', 'booking_id', 'id_booking']) {
    try {
      final response = await dio.get(
        '/booking-line',
        queryParameters: {param: bookingId},
      );
      final snapshots = _parseLineSnapshots(_extractListPayload(response.data));
      if (snapshots.isNotEmpty) return snapshots;
    } catch (_) {
      continue;
    }
  }

  final grouped = cache ?? await _fetchAllBookingLinesGrouped(dio);
  return grouped[bookingId] ?? const [];
}

// 🌟 LA MAGIA SUCEDE AQUÍ: List en lugar de Map para no machacar líneas
Booking _mergeBookingLines(
  Booking booking,
  List<_LineSnapshot> fetched,
) {
  final List<BookingLine> mergedLines = [];

  // 1. Añadimos todas las líneas que ya tenía el booking
  for (final line in booking.lines) {
    mergedLines.add(line);
  }

  // 2. Comparamos los snapshots de la API con lo que ya tenemos.
  for (final snapLine in _linesFromSnapshots(fetched)) {
    // Verificamos si esta línea (con este ID de base de datos) ya está en mergedLines
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
      // Si la línea ya existía en la reserva cargada pero el API no devolvió su id,
      // no la recreamos (evita el error de 48h al editar reservas existentes).
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

// Enum para controlar qué pestaña está viendo el usuario
enum TipoReserva { todas, materiales, actividades }

// Lista completa de reservas. GET /booking.
final AsyncNotifierProvider<ReservationsNotifier, List<Booking>>
reservationsProvider =
    AsyncNotifierProvider<ReservationsNotifier, List<Booking>>(
      ReservationsNotifier.new,
    );

// Filtra reservas en el frontend por usuario, estado, rango de fechas, texto libre Y TIPO DE RESERVA.
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
      final List<User> usuarios = ref.watch(usuariosProvider).value ?? [];
      final List<Activity> actividades =
          ref.watch(activitiesProvider).value ?? [];

      return asyncTodas.whenData((List<Booking> todas) {
        List<Booking> base = todas;

        // 1. Filtro opcional por usuario (vista cliente)
        if (params.idUsuario != null) {
          base = base
              .where((Booking r) => r.userId == params.idUsuario)
              .toList();
        }

        // 2. Filtro opcional por estado
        if (params.estado != null) {
          base = base.where((Booking r) => r.status == params.estado).toList();
        }

        // 3. Rangos de fecha
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

        // Por tipo de reserva (Pestañas de la UI)
        if (params.tipo == TipoReserva.materiales) {
          base = base
              .where((b) => !b.lines.any((l) => l.activityId != null))
              .toList();
        } else if (params.tipo == TipoReserva.actividades) {
          base = base
              .where((b) => b.lines.any((l) => l.activityId != null))
              .toList();
        }

        // 5. Filtro por texto libre
        if (params.query.isEmpty) {
          return base;
        }

        final String q = params.query.toLowerCase();
        return base.where((Booking r) {
          final String nombreU = resolverNombreUsuario(
            r.userId,
            usuarios,
          ).toLowerCase();

          // Busca la primera línea que tenga actividad para sacar su nombre
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

// Número de reservas/solicitudes pendientes (para badges)
final pendingBookingsCountProvider = Provider.family<int, int>((ref, userId) {
  return (ref.watch(reservationsProvider).value ?? [])
      .where((s) => s.userId == userId && s.status == WorkflowStatus.pendiente)
      .length;
});

class ReservationsNotifier extends AsyncNotifier<List<Booking>> {
  Map<int, List<_LineSnapshot>>? _linesCache;

  @override
  Future<List<Booking>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/booking');
      final raw = response.data;

      final List<dynamic> data = raw is List
          ? raw
          : (raw['data'] as List<dynamic>);

      final bookings = data
          .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
          .toList();

      _linesCache = await _fetchAllBookingLinesGrouped(dio);

      return bookings
          .map(
            (booking) => _mergeBookingLines(
              booking,
              booking.id == null ? const [] : (_linesCache![booking.id!] ?? const []),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<Booking> agregar(Booking reserva) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/booking',
        data: _createBookingPayload(reserva),
      );
      final Booking created = BookingModel.fromMap(
        response.data as Map<String, dynamic>,
      );

      if (created.id != null && reserva.lines.isNotEmpty) {
        await _syncBookingLines(
          dio,
          created.id!,
          reserva.lines,
          cache: _linesCache,
        );
      }

      ref.invalidateSelf();
      return created;
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> actualizar(Booking viejo, Booking nuevo) async {
    if (viejo.id == null) throw StateError('Booking has no id');
    try {
      final dio = ref.read(dioProvider);
      _linesCache ??= await _fetchAllBookingLinesGrouped(dio);

      if (viejo.status != nuevo.status) {
        await dio.patch(
          '/booking/${viejo.id}',
          data: {'statusId': _statusIdFrom(nuevo.status)},
        );
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

  Future<void> rechazar(Booking reserva) async {
    final Booking rechazada = reserva.copyWith(
      status: WorkflowStatus.cancelada,
    );
    await actualizar(reserva, rechazada);
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