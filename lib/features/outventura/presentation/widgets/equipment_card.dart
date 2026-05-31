import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart'; 
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/outventura/presentation/pages/equipment_detail_page.dart'; 
import 'dart:convert';

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

    final String statusCode = widget.equipamiento.status?.code ?? 'AVAILABLE';
    final bool esAgotado =
        statusCode == 'AVAILABLE' && widget.equipamiento.availableUnits <= 0;
    final bool esMantenimiento = statusCode == 'MAINTENANCE';
    final bool esFueraServicio = statusCode == 'OUT_OF_SERVICE';
    final bool esNoDisponible = statusCode == 'UNAVAILABLE';
    final bool esDescatalogado = statusCode == 'DISCONTINUED';

    Color statusColor = cs.primary;
    String labelTexto = s.statusAvailable;

    if (esAgotado) {
      statusColor = cs.tertiary;
      labelTexto = s.statusOutOfStock;
    } else if (esMantenimiento) {
      statusColor = cs.onSurfaceVariant;
      labelTexto = s.statusMaintenance;
    } else if (esFueraServicio) {
      statusColor = cs.error;
      labelTexto = s.statusOutOfService;
    } else if (esNoDisponible) {
      statusColor = cs.outline; 
      labelTexto = 'No disponible temporalmente'; 
    } else if (esDescatalogado) {
      statusColor = cs.error.withValues(alpha: 0.6); 
      labelTexto = 'Descatalogado'; 
    }

    final double stockPct = widget.equipamiento.totalUnits > 0
        ? (widget.equipamiento.availableUnits / widget.equipamiento.totalUnits)
              .clamp(0.0, 1.0)
        : 0.0;

    final String? imagen = widget.equipamiento.imageAsset;

    return Container(
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 13, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.equipamiento.title,
                            style: tt.labelLarge?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TagWidget(
                          text: labelTexto,
                          backgroundColor: statusColor.withValues(alpha: 0.12),
                          textColor: statusColor,
                        ),
                        
                        ...widget.equipamiento.categories.map(
                          (Category c) => TagWidget(
                            text: c.localizedLabel(s),
                            backgroundColor: cs.onSurfaceVariant.withValues(alpha: 0.12),
                            textColor: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    if (widget.equipamiento.description != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        widget.equipamiento.description!,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.sell_outlined,
                          size: 12,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          s.pricePerDayShort(
                            widget.equipamiento.pricePerDay.toStringAsFixed(2),
                          ),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

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
                                  backgroundColor: cs.onSurfaceVariant
                                      .withValues(alpha: 0.15),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    stockPct < 0.25 ? cs.error : cs.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                s.stockInfo(
                                  widget.equipamiento.availableUnits,
                                  widget.equipamiento.totalUnits,
                                ),
                                style: tt.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Editar
                            if (widget.onEditar != null)
                              ActionIcon(
                                icon: Icons.edit_outlined,
                                color: cs.tertiary,
                                onTap: widget.onEditar!,
                              ),
                              
                            if (widget.onEditar != null && widget.onEliminar != null)
                              const SizedBox(width: 6),
                              
                            // Eliminar
                            if (widget.onEliminar != null)
                              ActionIcon(
                                icon: Icons.delete_outline,
                                color: cs.error,
                                onTap: widget.onEliminar!,
                              ),
                              
                            if ((widget.onEditar != null || widget.onEliminar != null) && widget.onAlquilar != null && statusCode == 'AVAILABLE' && widget.equipamiento.availableUnits > 0)
                              const SizedBox(width: 6),
                              
                            if (widget.onAlquilar != null && statusCode == 'AVAILABLE' && widget.equipamiento.availableUnits > 0)
                              ActionIcon(
                                icon: Icons.add_rounded,
                                color: cs.primary,
                                onTap: widget.onAlquilar!,
                              ),
                              
                            // Espaciador final antes del detalle
                            const SizedBox(width: 6),
                            
                            ActionIcon(
                              icon: Icons.chevron_right_rounded,
                              color: cs.onSurfaceVariant, // Color suave idéntico
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EquipmentDetailPage(equipamiento: widget.equipamiento),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            ClipPath(
              clipper: _DiagonalLeftClipper(),
              child: SizedBox(
                width: 110,
                height: double.infinity,
                child: imagen != null && imagen.isNotEmpty
                    ? (imagen.startsWith('assets/')
                        ? Image.asset(imagen, fit: BoxFit.cover)
                        : Image.memory(
                            base64Decode(imagen),
                            fit: BoxFit.cover,
                          ))
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
      ),
    );
  }
}

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