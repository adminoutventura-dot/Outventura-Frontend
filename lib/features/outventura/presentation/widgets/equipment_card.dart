import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/l10n/app_localizations.dart';
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

    // Evalúa las propiedades en tiempo real mapeando contra los códigos String del Backend
    final String statusCode = widget.equipamiento.status?.code ?? 'AVAILABLE';
    // 🌟 ARREGLO: Se cambia .units por .availableUnits
    final bool esAgotado =
        statusCode == 'AVAILABLE' && widget.equipamiento.availableUnits <= 0;
    final bool esMantenimiento = statusCode == 'MAINTENANCE';
    final bool esFueraServicio = statusCode == 'OUT_OF_SERVICE';

    // TODO: HARDCODEADO
    Color statusColor = cs.primary;
    String labelTexto = "s.available";

    if (esAgotado) {
      statusColor = cs.tertiary;
      labelTexto = "s.outOfStock";
    } else if (esMantenimiento) {
      statusColor = cs.onSurfaceVariant;
      labelTexto = "s.maintenance";
    } else if (esFueraServicio) {
      statusColor = cs.error;
      labelTexto = "s.outOfService";
    }

    // 🌟 ARREGLO: Se cambia .units por .availableUnits para la barra de progreso
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
                      text: labelTexto,
                      backgroundColor: statusColor.withValues(alpha: 0.12),
                      textColor: statusColor,
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
                                // 🌟 ARREGLO: Se cambia .units por .availableUnits
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
                          children: [
                            if (widget.onEditar != null)
                              ActionIcon(
                                icon: Icons.edit_outlined,
                                color: cs.tertiary,
                                onTap: widget.onEditar!,
                              ),
                            if (widget.onEditar != null &&
                                (widget.onEliminar != null ||
                                    widget.onAlquilar != null))
                              const SizedBox(width: 5),
                            if (widget.onEliminar != null)
                              ActionIcon(
                                icon: Icons.delete_outline,
                                color: cs.error,
                                onTap: widget.onEliminar!,
                              ),
                            // 🌟 ARREGLO: Se cambia .units por .availableUnits
                            if (widget.onAlquilar != null &&
                                statusCode == 'AVAILABLE' &&
                                widget.equipamiento.availableUnits > 0) ...[
                              if (widget.onEliminar != null)
                                const SizedBox(width: 5),
                              ActionIcon(
                                icon: Icons.add_rounded,
                                color: cs.primary,
                                onTap: widget.onAlquilar!,
                              ),
                            ],
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
