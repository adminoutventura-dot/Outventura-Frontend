import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/l10n/app_localizations.dart';

Future<BookingLine?> mostrarDialogoLineaReserva({
  required BuildContext context,
  required List<Equipment> equipamientos,
  BookingLine? initialLinea,
  bool validateStock = true,
}) {
  return showDialog<BookingLine>(
    context: context,
    builder: (BuildContext ctx) => _LineaReservaDialog(
      equipamientos: equipamientos,
      initialLinea: initialLinea,
      validateStock: validateStock,
    ),
  );
}

class _LineaReservaDialog extends StatefulWidget {
  final List<Equipment> equipamientos;
  final BookingLine? initialLinea;
  final bool validateStock;

  const _LineaReservaDialog({
    required this.equipamientos,
    required this.initialLinea,
    this.validateStock = true,
  });

  @override
  State<_LineaReservaDialog> createState() => _LineaReservaDialogState();
}

class _LineaReservaDialogState extends State<_LineaReservaDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late int? _idEquipamiento;
  late final TextEditingController _cantCtrl;

  @override
  void initState() {
    super.initState();
    // Si hay línea inicial (edición), precarga el equipamiento y la cantidad.
    // Si no (creación), el equipamiento queda vacío y la cantidad por defecto es 1.
    _idEquipamiento = widget.initialLinea?.equipmentId;
    _cantCtrl = TextEditingController(
      text: widget.initialLinea != null ? '${widget.initialLinea!.quantity}' : '1',
    );
  }

  @override
  void dispose() {
    _cantCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return AlertDialog(
      // El título varía según si es creación o edición de línea.
      title: Text(widget.initialLinea == null ? s.addLine : s.editLine),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selector de equipamiento
            AppDropdownField<Equipment>(
              value: _idEquipamiento,
              items: widget.equipamientos,
              itemValue: (e) => e.id,
              itemLabel: (e) => e.title,
              prefixIcon: Icons.inventory_2_outlined,
              label: s.equipment,
              hint: s.noneSelected,
              isRequired: true,
              onChanged: (int? v) => setState(() => _idEquipamiento = v),
            ),
            const SizedBox(height: 16),

            // Campo de cantidad (mínimo 1)
            CustomInputField(
              controller: _cantCtrl,
              labelText: s.quantity,
              prefixIcon: Icons.layers_outlined,
              keyboardType: TextInputType.number,
              validator: (String? v) {
                final int? n = int.tryParse(v ?? '');
                if (n == null || n < 1) return s.invalidQuantity;
                
                // Validar contra el stock disponible del equipamiento seleccionado
                if (widget.validateStock && _idEquipamiento != null) {
                  Equipment? selectedEquipment;
                  try {
                    selectedEquipment = widget.equipamientos.firstWhere((e) => e.id == _idEquipamiento);
                  } catch (e) {
                    // TODO: Equipment not found
                  }
                  
                  if (selectedEquipment != null && n > selectedEquipment.units) {
                    return s.insufficientStock(selectedEquipment.units, _idEquipamiento!);
                  }
                }
                
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        // Cancelar sin guardar cambios
        SecondaryButton(
          label: s.cancel,
          onPressed: () => Navigator.pop(context),
          backgroundColor: Theme.of(context).colorScheme.surface,
          borderColor: Theme.of(context).colorScheme.primary,
        ),
        
        // Confirmar: valida el formulario y devuelve la BookingLine resultante.
        PrimaryButton(
          label: s.confirm,
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              BookingLine(
                equipmentId: _idEquipamiento!,
                quantity: int.parse(_cantCtrl.text),
              ),
            );
          },
        ),
      ],
    );
  }
}