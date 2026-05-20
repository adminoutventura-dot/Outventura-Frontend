import 'package:flutter/material.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class RequestCard extends StatelessWidget {
  final Request solicitud;
  final Activity actividad;
  final String? nombreUsuario;
  final VoidCallback? onGestionar;
  final VoidCallback? onCancelar;
  final VoidCallback? onEditar;
  final VoidCallback? onVerDetalle;

  const RequestCard({
    super.key,
    required this.solicitud,
    required this.actividad,
    this.nombreUsuario,
    this.onGestionar,
    this.onCancelar,
    this.onEditar,
    this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    // Color del badge y los acentos visuales según el estado de la solicitud.
    final Color statusColor = switch (solicitud.status) {
      RequestStatus.pendiente => cs.tertiary,
      RequestStatus.confirmada => cs.primary,
      RequestStatus.enCurso => cs.secondary,
      RequestStatus.finalizada => cs.onSurfaceVariant,
      RequestStatus.cancelada => cs.error,
    };

    // Imagen de la actividad asociada (null si no tiene, se muestra un icono genérico).
    final String? imagen = actividad.imageAsset;

    return Container(
      decoration: BoxDecoration(
        // Fondo con tinte del color de estado
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
            // -- SIDEBAR CON IMAGEN --
            Container(
              width: 120,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                // Imagen de la actividad o icono genérico
                child: imagen != null
                    ? Image.asset(imagen, fit: BoxFit.cover)
                    : Container(
                        color: statusColor.withValues(alpha: 0.20),
                        child: Center(
                          child: Icon(
                            Icons.hiking_outlined,
                            size: 28,
                            color: statusColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
              ),
            ),

            // -- CONTENIDO --
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila 1: ID + usuario · badge
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          'SOLICITUD #${solicitud.id}',
                          style: tt.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (nombreUsuario != null) ...[
                          Text('  ·  ', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                          Text(
                            nombreUsuario!,
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Badge de estado
                    TagWidget(
                      text: solicitud.status.localizedLabel(s),
                      backgroundColor: statusColor.withValues(alpha: 0.13),
                      textColor: statusColor,
                    ),

                    // Fila 2: ruta
                    Wrap(
                      spacing: 6,
                      children: [
                        Text(
                          actividad.startPoint,
                          style: tt.labelLarge?.copyWith(color: cs.onSurface),
                        ),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: cs.onSurfaceVariant),
                        Text(
                          actividad.endPoint,
                          style: tt.labelLarge?.copyWith(color: cs.onSurface),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Experto
                    Text(
                      solicitud.expertId != null ? s.assignedExpert : s.noExpert,
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),

                    const SizedBox(height: 10),

                    // Separador
                    Divider(height: 1, thickness: 0.5, color: statusColor.withValues(alpha: 0.20)),

                    const SizedBox(height: 10),

                    // Fila metadatos
                    Wrap(
                      spacing: 10,
                      runSpacing: 5,
                      children: [
                        // Fecha de la actividad
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 13, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(FormateadorFecha.short(actividad.initDate), style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),

                        // Horario de la actividad
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_outlined, size: 13, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text('${FormateadorFecha.timeOnly(actividad.initDate)} – ${FormateadorFecha.timeOnly(actividad.endDate)}', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),

                        // Cantidad de participantes
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.group_outlined, size: 13, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(s.participantsCount(solicitud.participantCount), style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Tags + acciones
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tags
                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: actividad.categories
                              .map((Category c) => TagWidget(
                                    text: c.localizedLabel(s),
                                    backgroundColor: cs.secondary.withValues(alpha: 0.15),
                                    textColor: cs.onPrimaryContainer,
                                  ))
                              .toList(),
                        ),
                        if (actividad.categories.isNotEmpty) const SizedBox(height: 8),
                        // Botones de acción, solo visibles si el callback no es null.
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            spacing: 5,
                            children: [
                              // Cancelar solicitud
                              if (onCancelar != null)
                                ActionIcon(icon: Icons.close_rounded, color: cs.error, onTap: onCancelar!),
                              // Gestionar (aceptar) solicitud pendiente
                              if (onGestionar != null)
                                ActionIcon(icon: Icons.check_circle_outline, color: cs.primary, onTap: onGestionar!),
                              // Editar solicitud
                              if (onEditar != null)
                                ActionIcon(icon: Icons.edit_outlined, color: cs.tertiary, onTap: onEditar!),
                              // Ver detalle completo
                              if (onVerDetalle != null)
                                ActionIcon(icon: Icons.chevron_right_rounded, color: cs.onSurfaceVariant, onTap: onVerDetalle!),
                            ],
                          ),
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
