import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class EquipmentCard extends StatefulWidget {
  final Equipment equipamiento;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final VoidCallback? onAlquilar;

  const EquipmentCard({
    super.key,
    required this.equipamiento,
    this.onEditar,
    this.onEliminar,
    this.onAlquilar,
  });

  @override
  State<EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends State<EquipmentCard> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    final Color statusColor = switch (widget.equipamiento.status) {
      EquipmentStatus.disponible      => cs.primary,
      EquipmentStatus.agotado         => cs.tertiary,
      EquipmentStatus.mantenimiento   => cs.onSurfaceVariant,
      EquipmentStatus.fueraDeServicio => cs.error,
    };

    // Porcentaje de stock restante (0.0 a 1.0).
    final double stockPct = widget.equipamiento.totalUnits > 0
        ? (widget.equipamiento.units / widget.equipamiento.totalUnits).clamp(0.0, 1.0)
        : 0.0;

    final String? imagen = widget.equipamiento.imageAsset;

    return Container(
      height: 148,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withValues(alpha: 0.15),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          // CONTENIDO IZQUIERDO
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + badge en la misma fila
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.equipamiento.title,
                          style: tt.labelLarge?.copyWith(color: cs.onSurface),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TagWidget(
                    text: widget.equipamiento.status.localizedLabel(s),
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    textColor: statusColor,
                  ),

                  // Descripción
                  if (widget.equipamiento.description != null) ...[
                    const SizedBox(height: 5),
                    Expanded(
                      child: Text(
                        widget.equipamiento.description!,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Spacer(),

                  const SizedBox(height: 6),

                  // Precio
                  Row(
                    children: [
                      Icon(Icons.sell_outlined, size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        s.pricePerDayShort(widget.equipamiento.pricePerDay.toStringAsFixed(2)),
                        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Barra de stock + texto + acciones
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: stockPct,
                                minHeight: 5,
                                backgroundColor: cs.onSurfaceVariant.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  stockPct < 0.25 ? cs.error : cs.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              s.stockInfo(widget.equipamiento.units, widget.equipamiento.totalUnits),
                              style: tt.labelSmall?.copyWith(fontSize: 10, color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Acciones
                      Row(
                        children: [
                          // Si onEditar no es null, mostrar el icono de editar.
                          if (widget.onEditar != null)
                            ActionIcon(icon: Icons.edit_outlined, color: cs.tertiary, onTap: widget.onEditar!),
                          
                          // Si onEditar y onEliminar y/o onAlquilar no son null, mostrar un SizedBox de separación.
                          if (widget.onEditar != null && (widget.onEliminar != null || widget.onAlquilar != null))
                            const SizedBox(width: 5),

                          // Si onEliminar no es null, mostrar el icono de eliminar.
                          if (widget.onEliminar != null)
                            ActionIcon(icon: Icons.delete_outline, color: cs.error, onTap: widget.onEliminar!),

                          // Si onAlquilar no es null, mostrar el icono de alquilar.
                          if (widget.onAlquilar != null) ...[
                            if (widget.onEliminar != null) const SizedBox(width: 5),
                            ActionIcon(icon: Icons.add_rounded, color: cs.primary, onTap: widget.onAlquilar!),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // IMAGEN DERECHA con clip diagonal
          ClipPath(
            clipper: _DiagonalLeftClipper(),
            child: SizedBox(
              width: 110,
              height: double.infinity,
              child: imagen != null
                  ? Image.asset(imagen, fit: BoxFit.cover)
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.5),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 32,
                          color: cs.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Recorta el lado izquierdo de forma diagonal.
class _DiagonalLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(22, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_DiagonalLeftClipper oldClipper) => false;
}