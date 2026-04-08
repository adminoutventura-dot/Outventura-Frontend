import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/core/widgets/app_tag.dart';

class SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;
  final VoidCallback? onGestionar;

  const SolicitudCard({
    super.key,
    required this.solicitud,
    this.onGestionar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final badge = _estadoBadge(solicitud.estado, cs);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: cs.onPrimaryContainer.withAlpha(50),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner header
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            color: cs.onSecondary,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${solicitud.puntoInicio} → ${solicitud.puntoFin}',
                    style: tt.labelLarge?.copyWith(color: cs.onSurface),
                      // Trunca el texto si es muy largo.
                      overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: TagWidget(
                    text: badge.label,
                    backgroundColor: badge.bg,
                    textColor: badge.fg,
                  )
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha y participantes
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(solicitud.fechaInicio),
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.group_outlined, size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${solicitud.numeroParticipantes} personas',
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Tags + icono gestionar
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: solicitud.categorias
                            .map((c) => TagWidget(
                              text: c.nombre,
                              backgroundColor: cs.primaryContainer,
                              textColor: cs.onPrimaryContainer,
                            ))
                            .toList(),
                      ),
                    ),
                    if (onGestionar != null)
                      InkWell(
                        onTap: onGestionar,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.open_in_new_outlined,
                            size: 18,
                            color: cs.inverseSurface,
                          ),
                        ),
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
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  ({Color bg, Color fg, String label}) _estadoBadge(EstadoSolicitud estado, ColorScheme cs) {
    switch (estado) {
      case EstadoSolicitud.confirmada:
        return (bg: cs.primary, fg: cs.onPrimary, label: 'Confirmada');
      case EstadoSolicitud.pendiente:
        return (bg: cs.tertiary, fg: cs.onTertiary, label: 'Pendiente');
      case EstadoSolicitud.finalizada:
        return (bg: cs.secondary, fg: cs.onSecondary, label: 'Finalizada');
    }
  }
}

