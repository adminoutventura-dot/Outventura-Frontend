import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

typedef LineaDisplayInfo = ({String nombre, String? imagen, int cantidad});

class ActivityReservationCard extends StatelessWidget {
  final Booking reserva;
  final List<LineaDisplayInfo> lineas;
  final String nombreUsuario;
  final String? nombreActividad;

  final VoidCallback? onEditar;
  final VoidCallback? onVerDetalle;

  const ActivityReservationCard({
    super.key,
    required this.reserva,
    required this.lineas,
    required this.nombreUsuario,
    this.nombreActividad,
    this.onEditar,
    this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    final Color statusColor = switch (reserva.status) {
      WorkflowStatus.pendiente => cs.tertiary,
      WorkflowStatus.confirmada => cs.primary,
      WorkflowStatus.enCurso => cs.secondary,
      WorkflowStatus.finalizada => cs.onSurfaceVariant,
      WorkflowStatus.cancelada => cs.error,
    };

    final List<String> imagenesGrid = lineas
        .map((l) => l.imagen)
        .whereType<String>()
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Color.lerp(cs.surface, statusColor, 0.04),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.3),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 62,
                            height: 62,
                            child: _ImageGrid(
                              imagenes: imagenesGrid,
                              cs: cs,
                              tt: tt,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'EXCURSIÓ #${reserva.id ?? ""}',
                                    style: tt.labelSmall?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '  ·  ',
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      nombreUsuario,
                                      style: tt.labelSmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TagWidget(
                                    text: reserva.status.localizedLabel(s),
                                    backgroundColor: statusColor.withValues(
                                      alpha: 0.13,
                                    ),
                                    textColor: statusColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${FormateadorFecha.short(reserva.startDate)} – ${FormateadorFecha.short(reserva.endDate)}',
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              if (nombreActividad != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.hiking_outlined,
                                      size: 13,
                                      color: cs.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        nombreActividad!,
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.primary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: statusColor.withValues(alpha: 0.20),
                    ),
                    const SizedBox(height: 10),

                    // Desglose de materiales opcionales vinculados a la excursión
                    ...lineas
                        .where((l) => l.imagen != null)
                        .map(
                          (LineaDisplayInfo l) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 13,
                                  color: cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    l.nombre,
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                TagWidget(
                                  text: '×${l.cantidad}',
                                  backgroundColor: cs.secondary.withValues(
                                    alpha: 0.15,
                                  ),
                                  textColor: cs.onPrimaryContainer,
                                ),
                              ],
                            ),
                          ),
                        ),
                    const SizedBox(height: 4),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: statusColor.withValues(alpha: 0.20),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Spacer(),
                        if (onEditar != null) ...[
                          ActionIcon(
                            icon: Icons.assignment_outlined,
                            color: cs.secondary,
                            onTap: onEditar!,
                          ),
                          const SizedBox(width: 5),
                        ],
                        if (onVerDetalle != null)
                          ActionIcon(
                            icon: Icons.chevron_right_rounded,
                            color: cs.onSurfaceVariant,
                            onTap: onVerDetalle!,
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

class _ImageGrid extends StatelessWidget {
  final List<String> imagenes;
  final ColorScheme cs;
  final TextTheme tt;
  const _ImageGrid({
    required this.imagenes,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    if (imagenes.isEmpty) {
      return Container(
        color: cs.onPrimary.withValues(alpha: 0.20),
        child: Center(
          child: Icon(
            Icons.inventory_2_outlined,
            size: 26,
            color: cs.onPrimary.withValues(alpha: 0.6),
          ),
        ),
      );
    }
    if (imagenes.length == 1) {
      return imagenes[0].startsWith('assets/')
          ? Image.asset(imagenes[0], fit: BoxFit.cover)
          : Image.memory(base64Decode(imagenes[0]), fit: BoxFit.cover);
    }

    return GridView.count(
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      children: [
        for (int i = 0; i < imagenes.length && i < 3; i++)
          imagenes[i].startsWith('assets/')
              ? Image.asset(imagenes[i], fit: BoxFit.cover)
              : Image.memory(base64Decode(imagenes[i]), fit: BoxFit.cover),
        if (imagenes.length >= 4)
          imagenes[3].startsWith('assets/')
              ? Image.asset(imagenes[3], fit: BoxFit.cover)
              : Image.memory(base64Decode(imagenes[3]), fit: BoxFit.cover)
        else if (imagenes.length == 3)
          ColoredBox(
            color: cs.onPrimary.withValues(alpha: 0.25),
            child: Center(
              child: Text(
                '3',
                style: tt.labelSmall?.copyWith(color: cs.onPrimary),
              ),
            ),
          ),
      ],
    );
  }
}
