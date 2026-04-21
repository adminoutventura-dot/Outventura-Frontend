import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/equipment_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/excursion_category_tab.dart';
import 'package:outventura/features/outventura/presentation/widgets/equipment_card.dart';

class EquipmentPage extends ConsumerStatefulWidget {
  const EquipmentPage({super.key});

  @override
  ConsumerState<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends ConsumerState<EquipmentPage> {
  CategoriaActividad? _categoriaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final List<Equipamiento> equipamientos = ref.watch(equipamientosProvider);

    List<Equipamiento> equipamientosFiltrados;
    if (_categoriaSeleccionada == null) {
      equipamientosFiltrados = equipamientos;
    } else {
      equipamientosFiltrados = equipamientos
          .where((e) => e.categorias.contains(_categoriaSeleccionada))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipamiento'),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.inverseSurface, cs.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Equipamiento? nuevo = await Navigator.of(context).push<Equipamiento>(
            MaterialPageRoute(builder: (_) => const EquipmentFormPage()),
          );
          if (nuevo != null) {
            ref.read(equipamientosProvider.notifier).agregar(nuevo);
          }
        },
        backgroundColor: cs.secondaryContainer,
        foregroundColor: cs.onSecondary,
        elevation: 2,
        shape: CircleBorder(
          side: BorderSide(color: cs.onSecondary, width: 3),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        // Barra de categorías
        children: [
          Row(
            children: [
              Expanded(
                child: ExcursionCategoryTab(
                  label: 'Todos',
                  seleccionado: _categoriaSeleccionada == null,
                  onTap: () => setState(() => _categoriaSeleccionada = null),
                ),
              ),
              for (final CategoriaActividad categoria in CategoriaActividad.values)
                Expanded(
                  child: ExcursionCategoryTab(
                    label: categoria.label,
                    seleccionado: _categoriaSeleccionada == categoria,
                    onTap: () => setState(() => _categoriaSeleccionada = categoria),
                  ),
                ),
            ],
          ),

          // Lista de materiales filtrados
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              // Si no hay materiales muestra un mensaje en lugar de la lista.
              itemCount: equipamientosFiltrados.isEmpty ? 1 : equipamientosFiltrados.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                if (equipamientosFiltrados.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay equipamientos para esta categoría.',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                final Equipamiento equipamiento = equipamientosFiltrados[index];
                return EquipmentCard(
                  equipamiento: equipamiento,
                  onEditar: () async {
                    final Equipamiento? actualizado = await Navigator.of(context).push<Equipamiento>(
                      MaterialPageRoute(
                        builder: (_) => EquipmentFormPage(equipamiento: equipamiento),
                      ),
                    );
                    if (actualizado != null) {
                      ref.read(equipamientosProvider.notifier).actualizar(equipamiento, actualizado);
                    }
                  },
                  onEliminar: () async {
                    final bool confirm = await showConfirmDialog(
                      context: context,
                      title: 'Eliminar equipamiento',
                      content: '¿Eliminar "${equipamiento.nombre}"?',
                    );
                    if (confirm) {
                      ref.read(equipamientosProvider.notifier).eliminar(equipamiento);
                    }
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
