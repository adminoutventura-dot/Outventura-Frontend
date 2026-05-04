import 'package:flutter/material.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';

class SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;
  final Excursion excursion;
  final String? nombreUsuario;
  final VoidCallback? onGestionar;
  final VoidCallback? onCancelar;
  final VoidCallback? onEditar;
  final VoidCallback? onVerDetalle;

  const SolicitudCard({
    super.key,
    required this.solicitud,
    required this.excursion,
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

    final (
      Color badgeBg,
      Color badgeFg,
      Color accentColor,
    ) = switch (solicitud.estado) {
      EstadoSolicitud.confirmada => (
        cs.primary, 
        cs.onPrimary, 
        cs.primary
      ),
      EstadoSolicitud.pendiente => (
        cs.tertiary,
        cs.onPrimary,
        cs.onTertiary,
      ),
      EstadoSolicitud.finalizada => (
        cs.secondary.withValues(alpha: 0.35),
        cs.onPrimaryContainer,
        cs.secondary.withValues(alpha: 0.35),
      ),
      EstadoSolicitud.cancelada => (
        cs.error, 
        cs.onError, 
        cs.error
      ),
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
          // Línea según estado
          Container(height: 3, color: accentColor),

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
                                excursion.puntoInicio,
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
                                excursion.puntoFin,
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
                              solicitud.idExperto != null
                                  ? 'Experto asignado'
                                  : 'Sin experto',
                              // Separa por guion
                            ].join('  -  '),
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Badge estado
                    TagWidget(
                      text: solicitud.estado.label,
                      backgroundColor: badgeBg,
                      textColor: badgeFg,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Fecha / Participantes
                Row(
                  children: [
                    // Icono + fecha
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      FormateadorFecha.short(excursion.fechaInicio),
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Icono + participantes
                    Icon(
                      Icons.group_outlined,
                      size: 12,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${solicitud.numeroParticipantes} personas',
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
                      children: excursion.categorias
                          .map(
                            (CategoriaActividad c) => TagWidget(
                              text: c.label,
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

