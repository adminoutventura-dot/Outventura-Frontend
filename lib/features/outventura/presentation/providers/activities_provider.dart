import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/data/models/activity_model.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';

// Lista oficial de actividades que escucha la pantalla
final AsyncNotifierProvider<ActivitiesNotifier, List<Activity>>
activitiesProvider = AsyncNotifierProvider<ActivitiesNotifier, List<Activity>>(
  ActivitiesNotifier.new,
);

final Provider<List<Activity>> allActivitiesProvider = Provider<List<Activity>>((ref) {
  ref.watch(activitiesProvider);
  return ref.read(activitiesProvider.notifier).allActivities;
});

// Actividades recientes para el Dashboard
final recentActivitiesProvider = Provider.family<List<Activity>, int>((ref, count) {
  return (ref.watch(activitiesProvider).value ?? []).take(count).toList();
});

class ActivitiesNotifier extends AsyncNotifier<List<Activity>> {
  int currentPage = 1;
  int totalPages = 1;
  final int _itemsPerPage = 3; 

  // Almacén local de seguridad para guardar todo el catálogo que mande el NestJS
  List<Activity> _allActivities = [];

  List<Activity> get allActivities => _allActivities;

  // Estado de los filtros activos en la botonera de la app
  String _query = '';
  Category? _categoria;
  int? _dificultad; // Filtro por dificultad (nivel)
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  int? _guideId; // Filtro por guía

  @override
  Future<List<Activity>> build() async {
    try {
      final dio = ref.read(dioProvider);
      
      final response = await dio.get(
        '/activity',
        queryParameters: {'limit': 99999}, 
      );

      final List<dynamic> data = response.data['data'] as List<dynamic>;
      
      _allActivities = data
          .map((e) => ActivityModel.fromMap(e as Map<String, dynamic>))
          .toList();

      // Procesa la segmentación de 3 en 3 sobre el total
      return _procesarFiltrosYPaginas();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  /// Filtra sobre el 100% de los datos y luego los pagina cada 3
  List<Activity> _procesarFiltrosYPaginas() {
    List<Activity> resultado = _allActivities;

    // Filtro por Guía (se aplica antes de la paginación)
    if (_guideId != null) {
      resultado = resultado.where((act) => act.guideId == _guideId).toList();
    }

    // Filtro por Categoría (Compara de forma segura por código o ID)
    if (_categoria != null) {
      resultado = resultado.where((act) => 
        act.categories.any((c) => c.id == _categoria!.id || c.code == _categoria!.code)
      ).toList();
    }

    // Filtro por Dificultad (nivel)
    if (_dificultad != null) {
      resultado = resultado.where((act) => act.difficulty == _dificultad).toList();
    }

    // Filtro por Fecha Desde
    if (_fechaDesde != null) {
      resultado = resultado.where((act) => !act.endDate.isBefore(_fechaDesde!)).toList();
    }

    // Filtro por Fecha Hasta
    if (_fechaHasta != null) {
      resultado = resultado.where((act) => !act.initDate.isAfter(_fechaHasta!)).toList();
    }

    // Filtro por el Buscador de texto superior
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      resultado = resultado.where((act) => 
        act.title.toLowerCase().contains(q) || 
        (act.startEndPoint ?? '').toLowerCase().contains(q)
      ).toList();
    }

    // Si los filtros dejan la lista vacía, resetea la paginación a 1/1
    if (resultado.isEmpty) {
      currentPage = 1;
      totalPages = 1;
      return [];
    }

    // CALCULO REAL DE PÁGINAS SOBRE EL RESULTADO FILTRADO EN EL MÓVIL
    totalPages = (resultado.length / _itemsPerPage).ceil();
    
    // Control de desbordamiento de páginas
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;

    // Extrae los 3 elementos que corresponden a la página visualizada
    final int indiceInicio = (currentPage - 1) * _itemsPerPage;
    final int indiceFin = indiceInicio + _itemsPerPage;
    
    return resultado.sublist(
      indiceInicio, 
      indiceFin > resultado.length ? resultado.length : indiceFin
    );
  }

  // Vinculado a la barra de búsqueda en tiempo real
  void aplicarFiltroTexto(String texto) {
    _query = texto;
    currentPage = 1; 
    state = AsyncData(_procesarFiltrosYPaginas());
  }

  // Vinculado al botón de confirmar del modal de filtros avanzados
  void aplicarFiltrosAvanzados({
    Category? categoria,
    int? dificultad,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) {
    _categoria = categoria;
    _dificultad = dificultad;
    _fechaDesde = fechaDesde;
    _fechaHasta = fechaHasta;
    currentPage = 1;
    state = AsyncData(_procesarFiltrosYPaginas());
  }

  // Filtro por guía (independiente de los filtros avanzados para que no se
  // pierda al aplicar categoría/dificultad/fechas).
  void aplicarFiltroGuia(int? guideId) {
    _guideId = guideId;
    currentPage = 1;
    state = AsyncData(_procesarFiltrosYPaginas());
  }

  // Control de los botones de cambio de página < 1 / X >
  void cambiarPagina(int nuevaPagina) {
    if (nuevaPagina < 1 || nuevaPagina > totalPages || nuevaPagina == currentPage) {
      return;
    }
    currentPage = nuevaPagina;
    state = AsyncData(_procesarFiltrosYPaginas());
  }

  // POST /activity
  Future<Activity> agregar(Activity actividad) async {
    try {
      final dio = ref.read(dioProvider);
      final Map<String, dynamic> datosAEnviar = actividad.toMap();

      if (datosAEnviar['guideId'] == null) {
        final usuarioLogueado = ref.read(currentUserProvider);
        if (usuarioLogueado != null) {
          final dynamic userDynamic = usuarioLogueado;
          try {
            datosAEnviar['guideId'] =
                userDynamic.guideId ??
                userDynamic.id_guide ??
                userDynamic.guide?.id;
          } catch (_) {}
        }
      }

      if (datosAEnviar['guideId'] != null) {
        final int? parsedId = int.tryParse(datosAEnviar['guideId'].toString());
        if (parsedId != null) datosAEnviar['guideId'] = parsedId;
      }

      final response = await dio.post('/activity', data: datosAEnviar);
      final Activity created = ActivityModel.fromMap(response.data as Map<String, dynamic>);

      ref.invalidateSelf();

      return created;
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // PATCH /activity/:id
  Future<void> actualizar(Activity viejo, Activity nuevo) async {
    if (viejo.id == null) throw StateError('Activity has no id');
    try {
      final dio = ref.read(dioProvider);
      final Map<String, dynamic> datosAEnviar = nuevo.toMap();

      bool mismaFecha(DateTime a, DateTime b) {
        return a.toUtc().millisecondsSinceEpoch == b.toUtc().millisecondsSinceEpoch;
      }

      if (mismaFecha(viejo.initDate, nuevo.initDate)) {
        datosAEnviar.remove('init_date');
      }
      if (mismaFecha(viejo.endDate, nuevo.endDate)) {
        datosAEnviar.remove('end_date');
      }

      await dio.patch('/activity/${viejo.id}', data: datosAEnviar);

      ref.invalidateSelf();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // DELETE /activity/:id
  Future<void> eliminar(Activity actividad) async {
    if (actividad.id == null) throw StateError('Activity has no id');
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/activity/${actividad.id}');
      ref.invalidateSelf();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }
}

// Lista de actividades para los Dropdowns (filtra localmente actividades
// futuras del allActivitiesProvider, evitando una petición HTTP separada
// que podría quedar desfasada respecto al listado principal).
final Provider<List<Activity>> availableActivitiesProvider =
    Provider<List<Activity>>((ref) {
  final List<Activity> all = ref.watch(allActivitiesProvider);
  final now = DateTime.now();
  return all.where((a) => !a.initDate.isBefore(now)).toList();
});