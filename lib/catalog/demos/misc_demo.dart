import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_tab.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/core/widgets/app_buttons.dart';

class MiscDemo extends StatefulWidget {
  const MiscDemo({super.key});

  @override
  State<MiscDemo> createState() => _MiscDemoState();
}

class _MiscDemoState extends State<MiscDemo> {
  int _selectedTab = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<CategoriaActividad> _seleccionados = [];

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Otros Widgets')),
      floatingActionButton: AddFab(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AddFab pressed')));
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('AppTab – Barra de pestañas simple', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (i) {
              final String label = ['Inicio', 'Explorar', 'Favoritos', 'Perfil'][i];
              return Expanded(
                child: AppTab(
                  label: label,
                  seleccionado: _selectedTab == i,
                  onTap: () => setState(() => _selectedTab = i),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),
          Text('ConfirmDialog – Diálogo de confirmación', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Mostrar diálogo de confirmación',
            onPressed: () async {
              final bool ok = await showConfirmDialog(
                context: context,
                title: 'Eliminar elemento',
                content: '¿Estás seguro de que quieres eliminar este elemento?',
                isDanger: true,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Confirmado' : 'Cancelado')));
            },
          ),

          const SizedBox(height: 24),
          Text('AppFilterChipFormField – Selector múltiple integrado en Form', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppFilterChipFormField(
                  seleccionados: _seleccionados,
                  onToggle: (CategoriaActividad c) => setState(() {
                    if (_seleccionados.contains(c)) {
                      _seleccionados.remove(c);
                    } else {
                      _seleccionados.add(c);
                    }
                  }),
                  validator: (List<CategoriaActividad>? val) {
                    if (val == null || val.isEmpty) return 'Selecciona al menos una categoría';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Validar selección',
                  onPressed: () async {
                    final bool ok = _formKey.currentState?.validate() ?? false;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'OK' : 'Error')));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
