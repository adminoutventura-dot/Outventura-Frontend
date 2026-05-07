import 'package:flutter/material.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
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
  final VoidCallback? onVerDetalle;

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
    this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final (Color badgeBg, Color badgeFg, Color accentColor) = switch (reserva.estado) {
      EstadoReserva.pendiente => (cs.tertiary, cs.onPrimary, cs.onTertiary),
      EstadoReserva.confirmada => (cs.primary, cs.onPrimary, cs.primary),
      EstadoReserva.finalizada => (cs.secondary.withValues(alpha: 0.35), cs.onPrimaryContainer, cs.secondary.withValues(alpha: 0.35)),
      EstadoReserva.cancelada => (cs.error, cs.onError, cs.error),
      EstadoReserva.enCurso => (cs.secondary, cs.onSecondary, cs.secondary),
    };

    // Lista de imágenes de los equipamientos, filtrando los nulos
    final List<String> imagenes = lineas.map((l) => l.imagen).whereType<String>().toList();

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
                // Header: miniaturas apiladas + info + badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid de imágenes de los equipamientos (máx. 4)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: imagenes.isEmpty
                            ? ColoredBox(
                                color: cs.primaryContainer,
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: cs.onPrimaryContainer.withValues(alpha: 0.5),
                                  size: 22,
                                ),
                              )
                            : imagenes.length == 1
                                ? Image.asset(imagenes[0], fit: BoxFit.cover)
                                : GridView.count(
                                    crossAxisCount: 2,
                                    physics: const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 1,
                                    crossAxisSpacing: 1,
                                    children: [
                                      for (int i = 0; i < imagenes.length && i < 3; i++)
                                        Image.asset(imagenes[i], fit: BoxFit.cover),
                                      if (imagenes.length >= 4)
                                        Image.asset(imagenes[3], fit: BoxFit.cover)
                                      else if (imagenes.length == 3)
                                        ColoredBox(
                                          color: cs.primaryContainer,
                                          child: Center(
                                            child: Text(
                                              '3',
                                              style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer),
                                            ),
                                          ),
                                        ),
                                      if (imagenes.length > 4)
                                        ColoredBox(
                                          color: cs.primaryContainer,
                                          child: Center(
                                            child: Text(
                                              '+${imagenes.length - 3}',
                                              style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer),
                                            ),
                                          ),
                                        ),
                                    ],
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
                              Expanded(
                                child: Text(
                                  '${FormateadorFecha.short(reserva.fechaInicio)} - ${FormateadorFecha.short(reserva.fechaFin)}',
                                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          // Horas
                          Row(
                            children: [
                              Icon(Icons.schedule_outlined, size: 12, color: cs.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                '${FormateadorFecha.timeOnly(reserva.fechaInicio)} - ${FormateadorFecha.timeOnly(reserva.fechaFin)}',
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
                      TagWidget(
                        text: 'x${l.cantidad}',
                        backgroundColor: cs.secondary.withValues(alpha: 0.15),
                        textColor: cs.onPrimaryContainer,
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
                      ActionIcon(
                        icon: Icons.edit_outlined,
                        color: cs.tertiary,
                        onTap: onEditar!
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
                      ActionIcon(icon: Icons.cancel_outlined, color: cs.error, onTap: onCancelar!),
                    if (onRechazar != null) ...[
                      const SizedBox(width: 8),
                      ActionIcon(icon: Icons.close, color: cs.error, onTap: onRechazar!),
                    ],
                    if (onAprobar != null) ...[
                      const SizedBox(width: 8),
                      ActionIcon(icon: Icons.check_circle_outline, color: cs.primary, onTap: onAprobar!),
                    ],
                    if (onRegistrarDevolucion != null) ...[
                      const SizedBox(width: 8),
                      ActionIcon(icon: Icons.assignment_return_outlined, color: cs.secondary, onTap: onRegistrarDevolucion!),
                    ],
                    if (onVerDetalle != null) ...[
                      const SizedBox(width: 8),
                      ActionIcon(icon: Icons.chevron_right, color: cs.onPrimaryContainer, onTap: onVerDetalle!),
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
}



