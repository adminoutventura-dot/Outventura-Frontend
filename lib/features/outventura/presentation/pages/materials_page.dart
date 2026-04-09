import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/data/fakes/materiales_fake.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/material.dart' as entity;
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/excursion_category_tab.dart';
import 'package:outventura/features/outventura/presentation/widgets/material_card.dart';

class MaterialsPage extends StatefulWidget {
  const MaterialsPage({super.key});

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  CategoriaActividad? _selectedCategory;

  // Filtra los materiales según la categoría seleccionada
  List<entity.Material> get _filteredMaterials {
    if (_selectedCategory == null) {
      return materialesFake;
    }
    return materialesFake
        .where((material) => material.categoria == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiales'),
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
      body: Column(
        // Barra de categorías
        children: [
          Row(
            children: [
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

          // Lista de materiales filtrados
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredMaterials.isEmpty ? 1 : _filteredMaterials.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (_filteredMaterials.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay materiales para esta categoría.',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }
                final material = _filteredMaterials[index];
                return MaterialCard(
                  material: material,
                  onEditar: () {
                    
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
