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

class MaterialReservationCard extends StatelessWidget {
  final Booking reserva;
  final List<LineaDisplayInfo> lineas;
  final String nombreUsuario;

  final VoidCallback? onEditar;
  final VoidCallback? onAprobar;
  final VoidCallback? onRechazar;
  final VoidCallback? onRegistrarDevolucion;
  final VoidCallback? onCancelar;
  final VoidCallback? onVerDetalle;

  const MaterialReservationCard({
    super.key,
    required this.reserva,
    required this.lineas,
    required this.nombreUsuario,
    this.onEditar,
    this.onAprobar,
    this.onRechazar,
    this.onRegistrarDevolucion,
    this.onCancelar,
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

    final String? imagenLateral = lineas.isNotEmpty
        ? lineas.first.imagen
        : null;

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
            // Contenedor de la imagen lateral izquierda
            Container(
              width: 120,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imagenLateral != null
                    ? (imagenLateral.startsWith('assets/')
                          ? Image.asset(imagenLateral, fit: BoxFit.cover)
                          : Image.memory(
                              base64Decode(
                                imagenLateral.contains(',')
                                    ? imagenLateral.split(',').last
                                    : imagenLateral,
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: cs.error,
                                ),
                              ),
                            ))
                    : Container(
                        color: statusColor.withValues(alpha: 0.20),
                        child: Center(
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 28,
                            color: statusColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
              ),
            ),

            // Bloque de contenido derecho
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'RESERVA #${reserva.id ?? ""}',
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
                      ],
                    ),
                    const SizedBox(height: 5),
                    TagWidget(
                      text: reserva.status.localizedLabel(s),
                      backgroundColor: statusColor.withValues(alpha: 0.13),
                      textColor: statusColor,
                    ),
                    const SizedBox(height: 8),

                    // Listado compacto de los materiales
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: lineas
                            .map(
                              (l) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '• ${l.nombre} (×${l.cantidad})',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: statusColor.withValues(alpha: 0.20),
                    ),
                    const SizedBox(height: 8),

                    // Fechas de la reserva de materiales
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onCancelar != null) ...[
                          ActionIcon(
                            icon: Icons.cancel_outlined,
                            color: cs.error,
                            onTap: onCancelar!,
                          ),
                          const SizedBox(width: 5),
                        ],
                        if (onRechazar != null) ...[
                          ActionIcon(
                            icon: Icons.close_rounded,
                            color: cs.error,
                            onTap: onRechazar!,
                          ),
                          const SizedBox(width: 5),
                        ],
                        if (onAprobar != null) ...[
                          ActionIcon(
                            icon: Icons.check_circle_outline,
                            color: cs.primary,
                            onTap: onAprobar!,
                          ),
                          const SizedBox(width: 5),
                        ],
                        if (onRegistrarDevolucion != null) ...[
                          ActionIcon(
                            icon: Icons.assignment_return_outlined,
                            color: cs.secondary,
                            onTap: onRegistrarDevolucion!,
                          ),
                          const SizedBox(width: 5),
                        ],
                        if (onEditar != null) ...[
                          ActionIcon(
                            icon: Icons.edit_outlined,
                            color: cs.tertiary,
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
