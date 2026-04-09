import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';

class SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;
  final VoidCallback? onGestionar;
  final VoidCallback? onVerDetalle;

  const SolicitudCard({
    super.key,
    required this.solicitud,
    this.onGestionar,
    this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (badgeBg, badgeFg, accentColor) = switch (solicitud.estado) {
      EstadoSolicitud.confirmada => (
          cs.secondaryContainer,
          cs.onSecondaryContainer,
          cs.secondaryContainer,
        ),
      EstadoSolicitud.pendiente  => (
          cs.tertiaryContainer,
          cs.onTertiary,
          cs.tertiary,
        ),
      EstadoSolicitud.finalizada => (
          cs.onSurfaceVariant.withValues(alpha: 0.15),
          cs.onSurfaceVariant,
          cs.onSurfaceVariant.withValues(alpha: 0.3),
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
                          Row(
                            children: [
                              // Inicio
                              Text(
                                solicitud.puntoInicio,
                                style: tt.labelLarge
                                    ?.copyWith(color: cs.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Flecha
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 13,
                                color: cs.onSurfaceVariant,
                              ),
                              // Fin
                              const SizedBox(width: 4),
                              Text(
                                solicitud.puntoFin,
                                style: tt.labelLarge
                                    ?.copyWith(color: cs.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          // ID + experto
                          Text(
                            '#${solicitud.id}  ·  ${solicitud.idExperto != null ? 'Experto asignado' : 'Sin experto'}',
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Badge estado
                    TagWidget(
                      text: solicitud.estado.nombre,
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
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(solicitud.fechaInicio),
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: 12),

                    // Icono + participantes
                    Icon(Icons.group_outlined,
                        size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${solicitud.numeroParticipantes} personas',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),

                const SizedBox(height: 9),
                Divider(
                    height: 1,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
                const SizedBox(height: 9),

                // Tags + acciones
                Row(
                  children: [
                    Row(
                      spacing: 5,
                      children: solicitud.categorias
                          .map((c) => TagWidget(
                                text: c.nombre,
                                backgroundColor: cs.primaryContainer,
                                textColor: cs.onPrimaryContainer,
                              ))
                          .toList(),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (onGestionar != null)
                          IconButton(
                            onPressed: onGestionar,
                            icon: Icon(Icons.edit_outlined, color: cs.onPrimaryContainer),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (onVerDetalle != null)
                          IconButton(
                            onPressed: onVerDetalle,
                            icon: Icon(Icons.chevron_right, color: cs.onPrimaryContainer),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
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

  String _formatDate(DateTime dt) {
    const m = [
      'ene','feb','mar','abr','may','jun',
      'jul','ago','sep','oct','nov','dic'
    ];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }
}

