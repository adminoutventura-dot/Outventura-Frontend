import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class EquipmentCard extends StatefulWidget {
  final Equipamiento equipamiento;
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

    Color badgeBg;
    Color badgeFg;
    switch (widget.equipamiento.status) {
      case EstadoEquipamiento.disponible:
        badgeBg = cs.primary;
        badgeFg = cs.onPrimary;
        break;
      case EstadoEquipamiento.agotado:
        badgeBg = cs.tertiary;
        badgeFg = cs.onPrimary;
        break;
      case EstadoEquipamiento.mantenimiento:
        badgeBg = cs.onSurfaceVariant;
        badgeFg = cs.onPrimary;
        break;
      case EstadoEquipamiento.fueraDeServicio:
        badgeBg = cs.error;
        badgeFg = cs.onError;
        break;
    }

    final double stockPorcentaje = widget.equipamiento.totalUnits > 0
        ? (widget.equipamiento.units / widget.equipamiento.totalUnits).clamp(0.0, 1.0)
        : 0.0;
    final String? imagen = widget.equipamiento.imageAsset;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del equipamiento
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 100,
                child: imagen != null
                    ? Image.asset(imagen, fit: BoxFit.cover)
                    : ColoredBox(
                        color: cs.primaryContainer,
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: cs.onPrimaryContainer.withValues(alpha: 0.5),
                          size: 28,
                        ),
                      ),
              ),
            ),

            // Contenido derecha
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del equipamiento + estado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.equipamiento.title,
                            style: tt.labelLarge?.copyWith(color: cs.onSurface),
                          ),
                        ),
                        const SizedBox(width: 3),
                        TagWidget(
                          text: widget.equipamiento.status.localizedLabel(s),
                          backgroundColor: badgeBg,
                          textColor: badgeFg,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Descripción del equipamiento 
                    if (widget.equipamiento.description != null)
                      Text(
                        widget.equipamiento.description!,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 10),
                    
                    // Precio y stock
                    Row(
                      children: [
                        Icon(Icons.sell_outlined, size: 11, color: cs.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(
                          s.pricePerDayShort(widget.equipamiento.pricePerDay.toStringAsFixed(2)),
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 32,
                          height: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: stockPorcentaje,
                              backgroundColor: cs.onSurfaceVariant.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          s.stockInfo(widget.equipamiento.units, widget.equipamiento.totalUnits),
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Editar
                        if (widget.onEditar != null)
                          ActionIcon(
                            icon: Icons.edit_outlined,
                            color: cs.tertiary,
                            onTap: widget.onEditar!
                          ),

                        if (widget.onEditar != null && (widget.onEliminar != null || widget.onAlquilar != null))
                          const SizedBox(width: 10),
                        
                        // Eliminar
                        if (widget.onEliminar != null)
                          ActionIcon(
                            icon: Icons.delete_outline,
                            color: cs.error,
                            onTap: widget.onEliminar!,
                          ),

                        // Alquilar
                        if (widget.onAlquilar != null) ...[
                          if (widget.onEliminar != null)
                          const SizedBox(width: 10),

                          ActionIcon(
                            icon: Icons.add,
                            color: cs.primary,
                            onTap: widget.onAlquilar!,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}