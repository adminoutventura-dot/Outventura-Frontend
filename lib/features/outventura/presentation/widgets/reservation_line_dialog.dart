import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/l10n/app_localizations.dart';

Future<ReservationLine?> mostrarDialogoLineaReserva({
  required BuildContext context,
  required List<Equipment> equipamientos,
  ReservationLine? initialLinea,
}) {
  return showDialog<ReservationLine>(
    context: context,
    builder: (BuildContext ctx) => _LineaReservaDialog(
      equipamientos: equipamientos,
      initialLinea: initialLinea,
    ),
  );
}

class _LineaReservaDialog extends StatefulWidget {
  final List<Equipment> equipamientos;
  final ReservationLine? initialLinea;

  const _LineaReservaDialog({
    required this.equipamientos,
    required this.initialLinea,
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
      title: Text(widget.initialLinea == null ? s.addLine : s.editLine),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            CustomInputField(
              controller: _cantCtrl,
              labelText: s.quantity,
              prefixIcon: Icons.layers_outlined,
              keyboardType: TextInputType.number,
              validator: (String? v) {
                final int? n = int.tryParse(v ?? '');
                if (n == null || n < 1) return s.invalidQuantity;
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        SecondaryButton(
          label: s.cancel,
          onPressed: () => Navigator.pop(context),
          backgroundColor: Theme.of(context).colorScheme.surface,
          borderColor: Theme.of(context).colorScheme.primary,
        ),
        PrimaryButton(
          label: s.confirm,
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              ReservationLine(
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