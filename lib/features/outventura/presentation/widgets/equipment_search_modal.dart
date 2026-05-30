import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/l10n/app_localizations.dart';

/// Abre un diálogo flotante de multi-selección informativa para asociar 
/// materiales recomendados a una actividad, incluyendo barra de búsqueda interna.
Future<Map<int, int>?> showEquipmentSearchModal({
  required BuildContext context,
  required List<Equipment> equipments,
  required Map<int, int> initialSelected,
}) {
  return showDialog<Map<int, int>>(
    context: context,
    builder: (context) => EquipmentSearchModal(
      equipments: equipments,
      initialSelected: initialSelected,
    ),
  );
}

class EquipmentSearchModal extends StatefulWidget {
  final List<Equipment> equipments;
  final Map<int, int> initialSelected;

  const EquipmentSearchModal({
    super.key,
    required this.equipments,
    required this.initialSelected,
  });

  @override
  State<EquipmentSearchModal> createState() => _EquipmentSearchModalState();
}

class _EquipmentSearchModalState extends State<EquipmentSearchModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  late Map<int, int> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = Map.from(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    final filteredList = widget.equipments.where((eq) {
      final matchesName = eq.title.toLowerCase().contains(_query.toLowerCase());
      final matchesCat = eq.categories.any((c) => c.code.toLowerCase().contains(_query.toLowerCase()));
      return matchesName || matchesCat;
    }).toList();

    return AlertDialog(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      // Geometría corporativa de diálogos alineada con tus inputs
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text('Seleccionar Material', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)), // TODO: hardcodeado
      content: SizedBox(
        width: double.maxFinite, 
        height: 400, 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomInputField(
              controller: _searchCtrl,
              labelText: 'Buscar por nombre o categoría...', // TODO: hardcodeado
              prefixIcon: Icons.search,
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _searchCtrl.clear();
                        _query = '';
                      }),
                    )
                  : null,
              onChanged: (val) => setState(() => _query = val),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Text(
                        'No hay resultados', // TODO: hardcodeado
                        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, idx) {
                        final Equipment item = filteredList[idx];
                        final int idEquip = item.id!;
                        final bool marcado = _tempSelected.containsKey(idEquip);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            // Capa de color translúcido
                            color: marcado 
                                ? cs.primary.withValues(alpha: 0.12) 
                                : cs.surface,
                            borderRadius: BorderRadius.circular(16), 
                            border: Border.all(
                              color: marcado 
                                  ? cs.primary 
                                  : cs.onSurfaceVariant.withValues(alpha: 0.2), 
                              width: 1.5,
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            leading: Icon(
                              Icons.inventory_2_outlined, 
                              size: 18, 
                              color: marcado ? cs.primary : cs.primary.withValues(alpha: 0.7),
                            ),
                            title: Text(
                              item.title,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: marcado ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: item.categories.isNotEmpty
                                ? Text(
                                    item.categories.map((c) => c.code).join(', '),
                                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                  )
                                : null,
                            trailing: Checkbox(
                              value: marcado,
                              activeColor: cs.primary,
                              // Suaviza el borde del checkbox deseleccionado
                              side: BorderSide(color: cs.onSurfaceVariant.withValues(alpha: 0.4), width: 1.5),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (marcado) {
                                    _tempSelected.remove(idEquip);
                                  } else {
                                    _tempSelected[idEquip] = 1;
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        SecondaryButton(
          label: s.cancel,
          onPressed: () => Navigator.pop(context),
          backgroundColor: cs.surface,
          borderColor: cs.primary,
        ),
        PrimaryButton(
          label: s.confirm,
          onPressed: () => Navigator.pop(context, _tempSelected),
        ),
      ],
    );
  }
}