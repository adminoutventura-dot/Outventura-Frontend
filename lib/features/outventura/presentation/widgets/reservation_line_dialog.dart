import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';

Future<LineaReserva?> mostrarDialogoLineaReserva({
  required BuildContext context,
  required List<Equipamiento> equipamientos,
  LineaReserva? initialLinea,
}) {
  return showDialog<LineaReserva>(
    context: context,
    builder: (BuildContext ctx) => _LineaReservaDialog(
      equipamientos: equipamientos,
      initialLinea: initialLinea,
    ),
  );
}

class _LineaReservaDialog extends StatefulWidget {
  final List<Equipamiento> equipamientos;
  final LineaReserva? initialLinea;

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
    _idEquipamiento = widget.initialLinea?.idEquipamiento;
    _cantCtrl = TextEditingController(
      text: widget.initialLinea != null ? '${widget.initialLinea!.cantidad}' : '1',
    );
  }

  @override
  void dispose() {
    _cantCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialLinea == null ? 'Añadir línea' : 'Editar línea'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDropdownField<Equipamiento>(
              value: _idEquipamiento,
              items: widget.equipamientos,
              itemValue: (e) => e.id,
              itemLabel: (e) => e.nombre,
              prefixIcon: Icons.inventory_2_outlined,
              label: 'Equipamiento',
              hint: 'Ninguno',
              isRequired: true,
              onChanged: (int? v) => setState(() => _idEquipamiento = v),
            ),
            const SizedBox(height: 16),
            CustomInputField(
              controller: _cantCtrl,
              labelText: 'Cantidad',
              prefixIcon: Icons.layers_outlined,
              keyboardType: TextInputType.number,
              validator: (String? v) {
                final int? n = int.tryParse(v ?? '');
                if (n == null || n < 1) return 'Introduce una cantidad válida';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        SecondaryButton(
          label: 'Cancelar',
          onPressed: () => Navigator.pop(context),
          backgroundColor: Theme.of(context).colorScheme.surface,
          borderColor: Theme.of(context).colorScheme.primary,
        ),
        PrimaryButton(
          label: 'Confirmar',
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              LineaReserva(
                idEquipamiento: _idEquipamiento!,
                cantidad: int.parse(_cantCtrl.text),
              ),
            );
          },
        ),
      ],
    );
  }
}