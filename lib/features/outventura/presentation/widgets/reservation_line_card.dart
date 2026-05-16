import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/l10n/app_localizations.dart';

class ReservationLineCard extends StatelessWidget {
  final ReservationLine linea;
  final Equipment equipamiento;
  final int cantidadDaniada;
  final bool esCliente;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? menosCoste;
  final VoidCallback? masCoste;

  const ReservationLineCard({
    super.key,
    required this.linea,
    required this.equipamiento,
    required this.cantidadDaniada,
    this.esCliente = false,
    required this.onEdit,
    required this.onDelete,
    this.menosCoste,
    this.masCoste,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final double totalDanio = cantidadDaniada * equipamiento.damageFee;

    // Solo se muestra la sección inferior de gestión de averías si NO es cliente
    final bool mostrarSeccionDanios = !esCliente;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Icono, Nombre + Precio unitario, Cantidad y Acciones
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(equipamiento.title, style: tt.bodyMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${s.priceEur(equipamiento.pricePerDay.toStringAsFixed(2))}/ud.',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TagWidget(
                  text: 'x${linea.quantity}',
                  backgroundColor: cs.secondary.withValues(alpha: 0.15),
                  textColor: cs.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                ActionIcon(
                  icon: Icons.edit_outlined,
                  size: 18,
                  color: cs.tertiary,
                  onTap: onEdit,
                ),
                const SizedBox(width: 8),
                ActionIcon(
                  icon: Icons.delete_outline,
                  size: 18,
                  color: cs.error,
                  onTap: onDelete,
                ),
              ],
            ),
            
            // --- SECCIÓN DE DAÑOS (SOLO PARA TRABAJADORES/ADMINS) ---
            if (mostrarSeccionDanios) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marca cantidad de unidades dañadas:',
                          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        Text(
                          '${s.damageCharge}: ${s.damageFeePerUnit(equipamiento.damageFee.toStringAsFixed(2))}',
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: menosCoste,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      '$cantidadDaniada / ${linea.quantity}',
                      style: tt.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add), 
                    onPressed: masCoste,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Divider(
                color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                thickness: 1,
                height: 0,
              ),

              // Total por daños en esta línea
              if (cantidadDaniada > 0) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${totalDanio.toStringAsFixed(2)} €',
                    style: tt.labelMedium?.copyWith(
                      color: cs.error,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}