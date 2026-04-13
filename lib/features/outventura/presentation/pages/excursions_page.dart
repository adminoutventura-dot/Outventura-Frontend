import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/data/fakes/excursiones_fake.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/presentation/pages/excursion_form_page.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/excursion_category_tab.dart';
import 'package:outventura/features/outventura/presentation/widgets/excursion_card.dart';

class ExcursionsPage extends StatefulWidget {
  const ExcursionsPage({super.key});

  @override
  State<ExcursionsPage> createState() => _ExcursionsPageState();
}

class _ExcursionsPageState extends State<ExcursionsPage> {
  CategoriaActividad? _selectedCategory;


  // Filtra las excursiones según la categoría seleccionada
  List<Excursion> get _filteredExcursions {
    if (_selectedCategory == null) {
      return excursionCatalog;
    }
    return excursionCatalog
        .where((excursion) => excursion.categorias.contains(_selectedCategory))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Excursiones'),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ cs.inverseSurface, cs.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ExcursionFormPage()),
        ),
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
                  selected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
              ),
              for (final categoria in CategoriaActividad.values)
                Expanded(
                  child: ExcursionCategoryTab(
                    label: categoria.nombre,
                    selected: _selectedCategory == categoria,
                    onTap: () => setState(() => _selectedCategory = categoria),
                  ),
                ),
            ],
          ),

          // Lista de excursiones filtradas
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredExcursions.isEmpty ? 1 : _filteredExcursions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (_filteredExcursions.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay excursiones para esta categoría.',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }
                final excursion = _filteredExcursions[index];
                return ExcursionCard(
                  excursion: excursion,
                  onEditar: () => {

                  },
                  onEliminar: () {

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
