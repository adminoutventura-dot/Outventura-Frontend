import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/excursion_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_tab.dart';
import 'package:outventura/features/outventura/presentation/widgets/excursion_card.dart';

class ExcursionsPage extends ConsumerStatefulWidget {
  const ExcursionsPage({super.key});

  @override
  ConsumerState<ExcursionsPage> createState() => _ExcursionsPageState();
}

class _ExcursionsPageState extends ConsumerState<ExcursionsPage> {
  CategoriaActividad? _categoriaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final List<Excursion> excursiones = ref.watch(excursionesProvider);

    List<Excursion> excursionesFiltradas;
    if (_categoriaSeleccionada == null) {
      excursionesFiltradas = excursiones;
    } else {
      excursionesFiltradas = excursiones
          .where((Excursion e) => e.categorias.contains(_categoriaSeleccionada))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Excursiones'),
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
      
      floatingActionButton: AddFab(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ExcursionFormPage()),
        ),
      ),

      body: Column(
        // Barra de categorías
        children: [
          Row(
            children: [
              Expanded(
                child: AppTab(
                  label: 'Todos',
                  seleccionado: _categoriaSeleccionada == null,
                  onTap: () => setState(() => _categoriaSeleccionada = null),
                ),
              ),
              for (final CategoriaActividad categoria in CategoriaActividad.values)
                Expanded(
                  child: AppTab(
                    label: categoria.label,
                    seleccionado: _categoriaSeleccionada == categoria,
                    onTap: () => setState(() => _categoriaSeleccionada = categoria),
                  ),
                ),
            ],
          ),

          // Lista de excursiones filtradas
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: excursionesFiltradas.isEmpty ? 1 : excursionesFiltradas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                if (excursionesFiltradas.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay excursiones para esta categoría.',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }
                final Excursion excursion = excursionesFiltradas[index];
                return ExcursionCard(
                  excursion: excursion,
                  onEditar: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext _) => ExcursionFormPage(excursion: excursion),
                    ),
                  ),
                  onEliminar: () async {
                    final bool confirm = await showConfirmDialog(
                      context: context,
                      title: 'Eliminar excursión',
                      content: '¿Eliminar "${excursion.puntoInicio} → ${excursion.puntoFin}"?',
                    );
                    if (confirm) {
                      ref.read(excursionesProvider.notifier).eliminar(excursion);
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
