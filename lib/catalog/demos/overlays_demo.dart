import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/outventura/data/fakes/equipment_fake.dart';
import 'package:outventura/features/outventura/data/fakes/reservations_fake.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_dialogs.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_dialog.dart';

class OverlaysDemo extends StatelessWidget {
  const OverlaysDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Diálogos & Overlays')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // showConfirmDialog – Peligro
          Text('showConfirmDialog – Peligro', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Eliminar elemento',
            icon: Icons.delete_outline,
            backgroundColor: cs.error,
            onPressed: () => showConfirmDialog(
              context: context,
              title: 'Eliminar elemento',
              content: '¿Seguro que quieres eliminar este elemento? Esta acción no se puede deshacer.',
            ),
          ),

          // showConfirmDialog – Acción segura
          const SizedBox(height: 24),
          Text('showConfirmDialog – Acción segura', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Confirmar acción',
            icon: Icons.check,
            onPressed: () => showConfirmDialog(
              context: context,
              title: 'Confirmar',
              content: '¿Confirmar esta acción?',
              confirmLabel: 'Confirmar',
              isDanger: false,
            ),
          ),

          // Reservation dialogs
          const SizedBox(height: 24),
          Text('Diálogos de reserva', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SecondaryButton(
                label: 'Aprobar',
                borderColor: cs.primary,
                backgroundColor: cs.surface,
                onPressed: () => mostrarDialogoAprobacion(context, reservationsFake[0], () {}),
              ),
              SecondaryButton(
                label: 'Rechazar',
                borderColor: cs.error,
                backgroundColor: cs.surface,
                onPressed: () => mostrarDialogoRechazo(context, reservationsFake[0], () {}),
              ),
              SecondaryButton(
                label: 'Cancelar',
                borderColor: cs.tertiary,
                backgroundColor: cs.surface,
                onPressed: () => mostrarDialogoCancelacion(context, reservationsFake[0], () {}),
              ),
              SecondaryButton(
                label: 'Registrar devolución',
                borderColor: cs.secondary,
                backgroundColor: cs.surface,
                onPressed: () => mostrarDialogoDevolucion(context, reservationsFake[0], () {}),
              ),
            ],
          ),

          // mostrarDialogoLineaReserva – Nueva línea
          const SizedBox(height: 24),
          Text('mostrarDialogoLineaReserva – Nueva línea', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Añadir línea',
            icon: Icons.add,
            borderColor: cs.primary,
            backgroundColor: cs.surface,
            onPressed: () => mostrarDialogoLineaReserva(
              context: context,
              equipamientos: equipmentFake,
            ),
          ),

          // mostrarDialogoLineaReserva – Editar línea
          const SizedBox(height: 16),
          Text('mostrarDialogoLineaReserva – Editar línea', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Editar línea',
            icon: Icons.edit_outlined,
            borderColor: cs.secondary,
            backgroundColor: cs.surface,
            onPressed: () => mostrarDialogoLineaReserva(
              context: context,
              equipamientos: equipmentFake,
              initialLinea: reservationsFake[0].lines.first,
            ),
          ),

        ],
      ),
    );
  }
}
