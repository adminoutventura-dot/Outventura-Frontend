import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';

Future<LineaReserva?> mostrarDialogoLineaReserva({
  required BuildContext context,
  required List<Equipamiento> equipamientos,
  LineaReserva? initialLinea,
}) {
  
  int? idEquipamiento = initialLinea?.idEquipamiento;
  final TextEditingController cantCtrl = TextEditingController(
    text: initialLinea != null ? '${initialLinea.cantidad}' : '1',
  );

  return showDialog<LineaReserva>(
    context: context,
    builder: (BuildContext ctx) => StatefulBuilder(
      builder: (BuildContext ctx, void Function(void Function()) setDialogState) {
        final ColorScheme cs = Theme.of(ctx).colorScheme;

        return AlertDialog(
          title: Text(initialLinea == null ? 'Anadir linea' : 'Editar linea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TODO: Cambiar a un dropdown con búsqueda si la lista de equipamientos es muy larga (crear widget).
              DropdownButtonFormField<int>(
                initialValue: idEquipamiento,
                decoration: InputDecoration(
                  labelText: 'Equipamiento',
                  prefixIcon: Icon(
                    Icons.inventory_2_outlined,
                    color: cs.primary.withAlpha(150),
                    size: 22,
                  ),
                  border: const UnderlineInputBorder(),
                ),
                items: equipamientos
                    .map(
                      (Equipamiento equip) => DropdownMenuItem<int>(
                        value: equip.id,
                        child: Text(equip.nombre),
                      ),
                    )
                    .toList(),
                onChanged: (int? v) => setDialogState(() => idEquipamiento = v),
              ),
              const SizedBox(height: 16),
              // TODO: Cambiar el TextField por un Stepper o algo similar para evitar problemas de input no numerico (crear widget). 
              TextField(
                controller: cantCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  prefixIcon: Icon(
                    Icons.layers_outlined,
                    color: cs.primary.withAlpha(150),
                    size: 22,
                  ),
                  border: const UnderlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (idEquipamiento == null) {
                  return;
                }

                final int cantidad = int.tryParse(cantCtrl.text) ?? 1;
                Navigator.pop(
                  ctx,
                  LineaReserva(
                    idEquipamiento: idEquipamiento!,
                    cantidad: cantidad < 1 ? 1 : cantidad,
                  ),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    ),
  ).whenComplete(() => cantCtrl.dispose());
}