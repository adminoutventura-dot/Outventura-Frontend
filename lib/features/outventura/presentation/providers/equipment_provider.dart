import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/data/models/equipment_model.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

final equipmentStatusesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/equipment-status');
  return response.data as List<dynamic>;
});

final equipmentProvider =
    AsyncNotifierProvider<EquipmentNotifier, List<Equipment>>(
      EquipmentNotifier.new,
    );

class EquipmentNotifier extends AsyncNotifier<List<Equipment>> {
  int currentPage = 1;
  int totalPages = 1;
  final int _itemsPerPage = 3; 

  List<Equipment> _allEquipment = [];

  String _query = '';
  int? _estado;
  Category? _categoria;

  @override
  Future<List<Equipment>> build() async {
    final usuario = ref.watch(currentUserProvider);
    
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/equipment',
        queryParameters: {'limit': 99999},
      );
      
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      
      _allEquipment = data
          .map((e) => EquipmentModel.fromMap(e as Map<String, dynamic>))
          .toList();

      return _procesarFiltrosYPaginas(usuario);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  List<Equipment> _procesarFiltrosYPaginas(dynamic usuario) {
    List<Equipment> resultado = _allEquipment;

    final bool esClienteOInvitado = usuario == null ||
        usuario.role.code == 'INVITADO' ||
        usuario.role.code == 'GUEST' ||
        usuario.role.code == 'USER'; // 'USER' equivale a vuestro rol de Cliente

    if (esClienteOInvitado) {
      // Si es cliente/invitado, forzamos que SOLO vea materiales con estado 'AVAILABLE'
      resultado = resultado.where((Equipment e) => e.status?.code == 'AVAILABLE').toList();
    }

    // 1. Filtro por Estado (Solo aplicable si el rol permite ver más estados)
    if (_estado != null) {
      resultado = resultado.where((Equipment e) => e.statusId == _estado).toList();
    }

    // 2. Filtro por Categoría
    if (_categoria != null) {
      resultado = resultado.where((Equipment e) => e.categories.contains(_categoria)).toList();
    }

    // 3. Filtro por Texto del Buscador
    if (_query.isNotEmpty) {
      final String q = _query.toLowerCase();
      resultado = resultado.where((Equipment e) => e.title.toLowerCase().contains(q)).toList();
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
    final usuario = ref.read(currentUserProvider);
    state = AsyncData(_procesarFiltrosYPaginas(usuario));
  }

  void aplicarFiltrosAvanzados({int? estado, Category? categoria}) {
    _estado = estado;
    _categoria = categoria;
    currentPage = 1; 
    final usuario = ref.read(currentUserProvider);
    state = AsyncData(_procesarFiltrosYPaginas(usuario));
  }

  void cambiarPagina(int nuevaPagina) {
    if (nuevaPagina < 1 || nuevaPagina > totalPages || nuevaPagina == currentPage) {
      return;
    }
    currentPage = nuevaPagina;
    final usuario = ref.read(currentUserProvider);
    state = AsyncData(_procesarFiltrosYPaginas(usuario));
  }

  Future<Equipment> agregar(Equipment equipamiento) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/equipment', data: equipamiento.toMap());
      final Equipment created = EquipmentModel.fromMap(response.data as Map<String, dynamic>);
      ref.invalidateSelf();
      return created;
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> actualizar(Equipment viejo, Equipment nuevo) async {
    if (viejo.id == null) throw StateError('Equipment has no id');
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/equipment/${viejo.id}', data: nuevo.toMap());
      ref.invalidateSelf(); 
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> eliminar(Equipment equipamiento) async {
    if (equipamiento.id == null) throw StateError('Equipment has no id');
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/equipment/${equipamiento.id}');
      ref.invalidateSelf();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }
}