import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';

// Información de una línea de reserva lista para mostrar en la tarjeta.
typedef LineaDisplayInfo = ({String nombre, String? imagen, int cantidad});

class ReservaCard extends StatelessWidget {
  final Reserva reserva;

  // Líneas de la reserva con datos resueltos por el padre (nombre, imagen, cantidad).
  final List<LineaDisplayInfo> lineas;
  final String nombreUsuario;
  final String? nombreExcursion;

  final VoidCallback? onEditar;
  final VoidCallback? onAprobar;
  final VoidCallback? onRechazar;
  final VoidCallback? onRegistrarDevolucion;
  final VoidCallback? onCancelar;

  const ReservaCard({
    super.key,
    required this.reserva,
    required this.lineas,
    required this.nombreUsuario,
    this.nombreExcursion,
    this.onEditar,
    this.onAprobar,
    this.onRechazar,
    this.onRegistrarDevolucion,
    this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final (Color badgeBg, Color badgeFg, Color accentColor) = switch (reserva.estado) {
      EstadoReserva.pendiente => (cs.tertiaryContainer, cs.onTertiary, cs.tertiary),
      EstadoReserva.confirmada => (cs.secondaryContainer, cs.onSecondaryContainer, cs.secondaryContainer),
      EstadoReserva.devuelta => (cs.primaryContainer, cs.onPrimaryContainer, cs.primaryContainer),
      EstadoReserva.cancelada => (cs.error, cs.onError, cs.error),
    };
    // TODO: Revisar si poner o no imagenes
    final String? firstImagen = lineas.isNotEmpty ? lineas.first.imagen : null;

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
          // Accent line
          Container(height: 3, color: accentColor),

          Padding(
            padding: const EdgeInsets.fromLTRB(13, 11, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: miniatura + info + badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // primera imagen o icono genérico
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: firstImagen != null
                            ? Image.asset(firstImagen, fit: BoxFit.cover)
                            : ColoredBox(
                                color: cs.primaryContainer,
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: cs.onPrimaryContainer.withValues(alpha: 0.5),
                                  size: 22,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${reserva.id}  ·  $nombreUsuario',
                            style: tt.labelMedium?.copyWith(color: cs.onSurface),
                          ),
                          const SizedBox(height: 6),
                          // Fechas
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 12, color: cs.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                '${_fmt(reserva.fechaInicio)} → ${_fmt(reserva.fechaFin)}',
                                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                          // Excursión vinculada (opcional)
                          if (nombreExcursion != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.hiking_outlined, size: 12, color: cs.primary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    nombreExcursion!,
                                    style: tt.labelSmall?.copyWith(color: cs.primary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TagWidget(
                      text: reserva.estado.label,
                      backgroundColor: badgeBg,
                      textColor: badgeFg,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                //  Líneas de la reserva
                // TODO: Revisar diseño para muchas líneas
                ...lineas.map((LineaDisplayInfo l) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l.nombre,
                          style: tt.bodySmall?.copyWith(color: cs.onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'x${l.cantidad}',
                          style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                )),

                const SizedBox(height: 5),
                Divider(height: 1, color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
                const SizedBox(height: 9),

                // Acciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEditar != null)
                      _ActionIcon(
                        icon: Icons.edit_outlined,
                        color: cs.onSurfaceVariant,
                        onTap: onEditar!,
                      ),
                    const Spacer(),
                    if (reserva.cargoDanios > 0) ...[
                      Row(
                        children: [
                          Icon(Icons.warning_amber_outlined, size: 12, color: cs.error),
                          const SizedBox(width: 4),
                          Text(
                            'Cargo daños: ${reserva.cargoDanios.toStringAsFixed(2)} €',
                            style: tt.labelSmall?.copyWith(color: cs.error),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ],
                    if (onCancelar != null)
                      _ActionIcon(icon: Icons.cancel_outlined, color: cs.error, onTap: onCancelar!),
                    if (onRechazar != null) ...[
                      const SizedBox(width: 8),
                      _ActionIcon(icon: Icons.close, color: cs.error, onTap: onRechazar!),
                    ],
                    if (onAprobar != null) ...[
                      const SizedBox(width: 8),
                      _ActionIcon(icon: Icons.check_circle_outline, color: cs.primary, onTap: onAprobar!),
                    ],
                    if (onRegistrarDevolucion != null) ...[
                      const SizedBox(width: 8),
                      _ActionIcon(icon: Icons.assignment_return_outlined, color: cs.secondary, onTap: onRegistrarDevolucion!),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    const List<String> m = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
