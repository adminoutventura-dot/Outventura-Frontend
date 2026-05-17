import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';
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

    // Colores base para armonizar el texto y fondo del badge según el estado
    // Estructura idéntica: Extraemos el color base según el estado actual
    final Color statusColor = switch (solicitud.status) {
      RequestStatus.pendiente => cs.tertiary,
      RequestStatus.confirmada => cs.primary,
      RequestStatus.enCurso => cs.secondary,
      RequestStatus.finalizada => cs.onSurfaceVariant,
      RequestStatus.cancelada => cs.error,
    };


    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- LÍNEA DE ACENTO SUPERIOR CON DEGRADADO ---
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppGradients.cardAccent(statusColor),
            ),
            child: const SizedBox(height: 4, width: double.infinity),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(13, 11, 12, 10),
            child: Column(
              children: [
                // Ruta / badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Puntos inicio → fin
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 2,
                            children: [
                              Text(
                                actividad.startPoint,
                                style: tt.labelLarge?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                size: 13,
                                color: cs.onSurfaceVariant,
                              ),
                              Text(
                                actividad.endPoint,
                                style: tt.labelLarge?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          // Cliente + experto
                          Text(
                            [
                              '#${solicitud.id}',
                              if (nombreUsuario != null) nombreUsuario,
                              solicitud.expertId != null
                                  ? s.assignedExpert
                                  : s.noExpert,
                            ].join('  -  '),
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Badge estado con el fondo suave y texto a juego
                    TagWidget(
                      text: solicitud.status.localizedLabel(s),
                      backgroundColor: statusColor.withValues(alpha: 0.15),
                      textColor: statusColor,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Fecha / Horario / Participantes
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      FormateadorFecha.short(actividad.initDate),
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${FormateadorFecha.timeOnly(actividad.initDate)} - ${FormateadorFecha.timeOnly(actividad.endDate)}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.group_outlined,
                      size: 12,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.participantsCount(solicitud.participantCount),
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 9),
                Divider(
                  height: 1,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 9),

                // Tags + acciones
                Row(
                  children: [
                    // Categorías
                    Row(
                      spacing: 5,
                      children: actividad.categories
                          .map(
                            (ActivityCategory c) => TagWidget(
                              text: c.localizedLabel(s),
                              backgroundColor: cs.secondary.withValues(alpha: 0.15),
                              textColor: cs.onPrimaryContainer,
                            ),
                          )
                          .toList(),
                    ),
                    const Spacer(),

                    // Acciones
                    Row(
                      children: [
                        if (onCancelar != null) ...[
                          ActionIcon(
                            icon: Icons.close,
                            color: cs.error,
                            onTap: onCancelar!,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (onGestionar != null) ...[
                          ActionIcon(
                            icon: Icons.check_circle_outline,
                            color: cs.primary,
                            onTap: onGestionar!,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (onEditar != null) ...[
                          ActionIcon(
                            icon: Icons.edit_outlined,
                            color: cs.tertiary,
                            onTap: onEditar!,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (onVerDetalle != null) ...[
                          ActionIcon(
                            icon: Icons.chevron_right,
                            color: cs.onPrimaryContainer,
                            onTap: onVerDetalle!,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}