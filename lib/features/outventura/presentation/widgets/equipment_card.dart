import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart' as entity;

class EquipmentCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    Color badgeBg;
    final Color badgeFg = cs.onSurface;
    switch (equipamiento.estado) {
      case entity.EstadoEquipamiento.disponible:
        badgeBg = cs.primary;
        // badgeFg = cs.onPrimary;
        break;
      case entity.EstadoEquipamiento.reservado:
        badgeBg = cs.secondaryContainer;
        // badgeFg = cs.onSecondaryContainer;
        break;
      case entity.EstadoEquipamiento.mantenimiento:
        badgeBg = cs.secondaryContainer;
        // badgeFg = cs.onSecondaryContainer;
        break;
      case entity.EstadoEquipamiento.fueraDeServicio:
        badgeBg = cs.errorContainer;
        // badgeFg = cs.onErrorContainer;
        break;
    }

    final double stockPorcentaje = (equipamiento.stock / 10).clamp(0.0, 1.0);

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
            
            // Imagen izquierda
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 90,
                child: equipamiento.imagenAsset != null ? Image.asset(equipamiento.imagenAsset!, fit: BoxFit.cover) : ColoredBox(
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
                    // Nombre + badge estado
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            equipamiento.nombre,
                            style: tt.labelLarge?.copyWith(color: cs.onSurface),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TagWidget(
                          text: equipamiento.estado.label,
                          backgroundColor: badgeBg.withValues(alpha: 0.35),
                          textColor: badgeFg,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Descripción
                    if (equipamiento.descripcion != null) 
                      Text(
                        equipamiento.descripcion!,
                        style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Precio / barra stock / acciones
                    Row(
                      children: [
                        Icon(Icons.sell_outlined, size: 11, color: cs.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(
                          '${equipamiento.precioAlquilerDiario.toStringAsFixed(2)}€/día',
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(width: 10),
                        
                        // Mini barra de stock
                        SizedBox(
                          width: 32,
                          height: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: stockPorcentaje,
                              backgroundColor:
                                  cs.onSurfaceVariant.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${equipamiento.stock} uds',
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),

                        const Spacer(),
                        
                        // Acciones
                        if (onEditar != null)
                          IconButton(
                            onPressed: onEditar,
                            icon: Icon(Icons.edit_outlined, color: cs.tertiary),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        const SizedBox(width: 10),
                        if (onEliminar != null)
                          IconButton(
                            onPressed: onEliminar,
                            icon: Icon(Icons.delete_outline, color: cs.error),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          
                        if (onAlquilar != null)
                          IconButton(
                            onPressed: onAlquilar,
                            icon: Icon(Icons.add, color: cs.primary),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
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

