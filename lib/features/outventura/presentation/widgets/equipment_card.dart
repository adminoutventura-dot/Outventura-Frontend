import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart' as entity;

class EquipmentCard extends StatefulWidget {
  final entity.Equipamiento equipamiento;
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

    Color badgeBg;
    final Color badgeFg = cs.onSurface;
    switch (widget.equipamiento.estado) {
      case entity.EstadoEquipamiento.disponible:
        badgeBg = cs.primary;
        break;
      case entity.EstadoEquipamiento.reservado:
        badgeBg = cs.secondaryContainer;
        break;
      case entity.EstadoEquipamiento.mantenimiento:
        badgeBg = cs.secondaryContainer;
        break;
      case entity.EstadoEquipamiento.fueraDeServicio:
        badgeBg = cs.errorContainer;
        break;
    }

    final double stockPorcentaje = (widget.equipamiento.stock / 10).clamp(0.0, 1.0);
    final String? imagen = widget.equipamiento.imagenAsset;

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
                            widget.equipamiento.nombre,
                            style: tt.labelLarge?.copyWith(color: cs.onSurface),
                          ),
                        ),
                        const SizedBox(width: 3),
                        TagWidget(
                          text: widget.equipamiento.estado.label,
                          backgroundColor: badgeBg.withValues(alpha: 0.35),
                          textColor: badgeFg,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Descripción del equipamiento 
                    if (widget.equipamiento.descripcion != null)
                      Text(
                        widget.equipamiento.descripcion!,
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
                          '${widget.equipamiento.precioAlquilerDiario.toStringAsFixed(2)}€/día',
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
                          '${widget.equipamiento.stock} uds',
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