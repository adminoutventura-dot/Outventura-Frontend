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
  @override
  Future<List<Booking>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/booking');
      final raw = response.data;

      final List<dynamic> data = raw is List
          ? raw
          : (raw['data'] as List<dynamic>);

      return data
          .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<Booking> agregar(Booking reserva) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/booking', data: reserva.toMap());
      final Booking created = BookingModel.fromMap(
        response.data as Map<String, dynamic>,
      );
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
      final response = await dio.patch(
        '/booking/${viejo.id}',
        data: nuevo.toMap(),
      );
      final Booking reservaServidor = BookingModel.fromMap(
        response.data as Map<String, dynamic>,
      );

      final List<Booking> listaActual = [...(state.value ?? [])];
      final int index = listaActual.indexWhere((Booking r) => r.id == viejo.id);

      if (index != -1) {
        listaActual[index] = reservaServidor;
      }

      state = AsyncData(listaActual);
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
