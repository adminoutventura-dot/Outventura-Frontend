import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/data/models/activity_model.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';

// Lista completa de actividades.
final AsyncNotifierProvider<ActivitiesNotifier, List<Activity>>
activitiesProvider = AsyncNotifierProvider<ActivitiesNotifier, List<Activity>>(
  ActivitiesNotifier.new,
);

// Filtra actividades en el frontend.
final filteredActivitiesProvider =
    Provider.family<
      AsyncValue<List<Activity>>,
      ({
        String query,
        Category? categoria,
        DateTime? fechaDesde,
        DateTime? fechaHasta,
      })
    >((ref, params) {
      final AsyncValue<List<Activity>> asyncTodas = ref.watch(
        activitiesProvider,
      );

      return asyncTodas.whenData((List<Activity> todas) {
        List<Activity> base = todas;

        if (params.categoria != null) {
          base = base
              .where((Activity e) => e.categories.contains(params.categoria))
              .toList();
        }
        if (params.fechaDesde != null) {
          base = base
              .where((Activity e) => !e.endDate.isBefore(params.fechaDesde!))
              .toList();
        }
        if (params.fechaHasta != null) {
          base = base
              .where((Activity e) => !e.initDate.isAfter(params.fechaHasta!))
              .toList();
        }
        if (params.query.isEmpty) {
          return base;
        }
        final String q = params.query.toLowerCase();
        return base
            .where(
              (Activity e) => '${e.title} ${e.startEndPoint ?? ''}'
                  .toLowerCase()
                  .contains(q),
            )
            .toList();
      });
    });

// Actividades recientes (Dashboard)
final recentActivitiesProvider = Provider.family<List<Activity>, int>((
  ref,
  count,
) {
  return (ref.watch(activitiesProvider).value ?? []).take(count).toList();
});

class ActivitiesNotifier extends AsyncNotifier<List<Activity>> {
  int currentPage = 1;
  int totalPages = 1;

  @override
  Future<List<Activity>> build() async {
    return _fetchPage(1);
  }

  // Descarga una página específica
  Future<List<Activity>> _fetchPage(int page) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/activity',
        queryParameters: {
          'page': page,
          'limit': 3, // Límite de 3 excursiones por página
        },
      );

      final List<dynamic> data = response.data['data'] as List<dynamic>;
      final meta = response.data['meta'];

      // Guardamos la página en la que estamos y el total
      currentPage = meta['page'];
      totalPages = meta['totalPages'];

      return data
          .map((e) => ActivityModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> cambiarPagina(int nuevaPagina) async {
    // Si intentamos ir a una página inválida o a la misma, no hacemos nada
    if (nuevaPagina < 1 ||
        nuevaPagina > totalPages ||
        nuevaPagina == currentPage) {
      return;
    }

    state = const AsyncLoading(); // Mostramos indicador de carga
    try {
      final newActivities = await _fetchPage(nuevaPagina);
      state = AsyncData(newActivities);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // POST /activity - CREACIÓN DE LA ACTIVIDAD
  Future<Activity> agregar(Activity actividad) async {
    try {
      final dio = ref.read(dioProvider);

      final Map<String, dynamic> datosAEnviar = actividad.toMap();

      if (datosAEnviar['guideId'] == null) {
        final usuarioLogueado = ref.read(currentUserProvider);
        if (usuarioLogueado != null) {
          final dynamic userDynamic = usuarioLogueado;
          try {
            // Intentamos mapear las distintas variantes de nombres que pueda tener en tu modelo de sesión
            datosAEnviar['guideId'] =
                userDynamic.guideId ??
                userDynamic.id_guide ??
                userDynamic.guide?.id;
          } catch (_) {
            print(
              " Si tu modelo de usuario no tiene el ID de guía mapeado, ignoramos el fallo silenciosamente",
            );
          }
        }
      }

      if (datosAEnviar['guideId'] != null) {
        final int? parsedId = int.tryParse(datosAEnviar['guideId'].toString());
        if (parsedId != null) {
          datosAEnviar['guideId'] = parsedId;
        }
      } else {
        // Alerta preventiva en la consola de depuración si se envía completamente vacío
        print(
          '⚠️ ALERTA OUTVENTURA: Estás intentando crear una actividad sin asignar un "guideId". El backend lo rechazará si no estás logueado como Guía con su ID correspondiente.',
        );
      }

      // 2. Enviamos la petición POST con el payload perfectamente estructurado
      final response = await dio.post('/activity', data: datosAEnviar);
      final Activity created = ActivityModel.fromMap(
        response.data as Map<String, dynamic>,
      );

      ref.invalidateSelf();
      ref.invalidate(availableActivitiesProvider);

      return created;
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // PATCH /activity/:id - actualiza la actividad en el backend y en la lista local.
  Future<void> actualizar(Activity viejo, Activity nuevo) async {
    if (viejo.id == null) {
      throw StateError('Activity has no id');
    }
    try {
      final dio = ref.read(dioProvider);

      final Map<String, dynamic> datosAEnviar = nuevo.toMap();

      // Helper rápido para estandarizar las fechas a texto idéntico
      String normalizarFecha(DateTime date) {
        final String iso = date.toIso8601String();
        return iso.endsWith('Z') ? iso : '${iso}Z';
      }

      if (normalizarFecha(viejo.initDate) == normalizarFecha(nuevo.initDate)) {
        datosAEnviar.remove('init_date');
      }
      if (normalizarFecha(viejo.endDate) == normalizarFecha(nuevo.endDate)) {
        datosAEnviar.remove('end_date');
      }

      final response = await dio.patch(
        '/activity/${viejo.id}',
        data: datosAEnviar,
      );

      final Activity actividadServidor = ActivityModel.fromMap(
        response.data as Map<String, dynamic>,
      );

      final List<Activity> listaActual = [...(state.value ?? [])];
      final int index = listaActual.indexWhere(
        (Activity e) => e.id == viejo.id,
      );

      if (index != -1) {
        listaActual[index] = actividadServidor;
      }

      state = AsyncData(listaActual);
      ref.invalidate(availableActivitiesProvider);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> eliminar(Activity actividad) async {
    if (actividad.id == null) throw StateError('Activity has no id');
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/activity/${actividad.id}');
      ref.invalidateSelf();
      ref.invalidate(availableActivitiesProvider);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }
}

// Lista de actividades para los Dropdowns
final AsyncNotifierProvider<AvailableActivitiesNotifier, List<Activity>>
availableActivitiesProvider =
    AsyncNotifierProvider<AvailableActivitiesNotifier, List<Activity>>(
      AvailableActivitiesNotifier.new,
    );

class AvailableActivitiesNotifier extends AsyncNotifier<List<Activity>> {
  @override
  Future<List<Activity>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/activity/available',
        queryParameters: {'limit': 100},
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => ActivityModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }
}
