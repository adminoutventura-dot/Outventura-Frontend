import 'package:flutter/material.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

typedef LineaDisplayInfo = ({String nombre, String? imagen, int cantidad});

class ReservationCard extends StatelessWidget {
  final Booking reserva;
  final List<LineaDisplayInfo> lineas;
  final String nombreUsuario;
  final String? nombreActividad;

  final VoidCallback? onEditar;
  final VoidCallback? onAprobar;
  final VoidCallback? onRechazar;
  final VoidCallback? onRegistrarDevolucion;
  final VoidCallback? onCancelar;
  final VoidCallback? onVerDetalle;

  const ReservationCard({
    super.key,
    required this.reserva,
    required this.lineas,
    required this.nombreUsuario,
    this.nombreActividad,
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
      BookingStatus.pendiente  => cs.tertiary,
      BookingStatus.confirmada => cs.primary,
      BookingStatus.enCurso    => cs.secondary,
      BookingStatus.finalizada => cs.onSurfaceVariant,
      BookingStatus.cancelada  => cs.error,
    };

    final List<String> imagenes = lineas.map((l) => l.imagen).whereType<String>().toList();

    return Container(
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
            // BARRA LATERAL
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.3),
              ),
            ),

            // CONTENIDO
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con grid e info
                    Row(
                      children: [
                        // Grid de miniaturas
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 62,
                            height: 62,
                            child: _ImageGrid(imagenes: imagenes, cs: cs, tt: tt),
                          ),
                        ),

                        const SizedBox(width: 12),
                        
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Fila 1: ID + usuario + badge
                              Row(
                                children: [
                                  Text(
                                    'RESERVA #${reserva.id}',
                                    style: tt.labelSmall?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text('  ·  ', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                                  Expanded(
                                    child: Text(
                                      nombreUsuario,
                                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TagWidget(
                                    text: reserva.status.localizedLabel(s),
                                    backgroundColor: statusColor.withValues(alpha: 0.13),
                                    textColor: statusColor,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Fechas y horas
                              Wrap(
                                spacing: 10,
                                runSpacing: 4,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.calendar_today_outlined, size: 13, color: cs.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${FormateadorFecha.short(reserva.startDate)} – ${FormateadorFecha.short(reserva.endDate)}',
                                        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.schedule_outlined, size: 13, color: cs.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${FormateadorFecha.timeOnly(reserva.startDate)} – ${FormateadorFecha.timeOnly(reserva.endDate)}',
                                        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Excursión vinculada
                              if (nombreActividad != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.hiking_outlined, size: 13, color: cs.primary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        nombreActividad!,
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
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Separador
                    Divider(height: 1, thickness: 0.5, color: statusColor.withValues(alpha: 0.20)),

                    const SizedBox(height: 10),

                    // Líneas de equipamiento
                    ...lineas.map((LineaDisplayInfo l) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 13, color: cs.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  l.nombre,
                                  style: tt.bodySmall?.copyWith(color: cs.onSurface),
                                ),
                              ),
                              const SizedBox(width: 6),
                              TagWidget(
                                text: '×${l.cantidad}',
                                backgroundColor: cs.secondary.withValues(alpha: 0.15),
                                textColor: cs.onPrimaryContainer,
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 4),

                    // Separador antes de acciones
                    Divider(height: 1, thickness: 0.5, color: statusColor.withValues(alpha: 0.20)),
                    const SizedBox(height: 9),

                    // Daños + acciones
                    Row(
                      children: [
                        if (reserva.damageFee > 0) ...[
                          Icon(Icons.warning_amber_rounded, size: 13, color: cs.error),
                          const SizedBox(width: 4),
                          Text(
                            s.damageChargeAmount(reserva.damageFee.toStringAsFixed(2)),
                            style: tt.labelSmall?.copyWith(
                              color: cs.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(),

                        // Acciones
                        if (onCancelar != null) ...[
                          ActionIcon(icon: Icons.cancel_outlined, color: cs.error, onTap: onCancelar!),
                          const SizedBox(width: 5),
                        ],
                        if (onRechazar != null) ...[
                          ActionIcon(icon: Icons.close_rounded, color: cs.error, onTap: onRechazar!),
                          const SizedBox(width: 5),
                        ],
                        if (onAprobar != null) ...[
                          ActionIcon(icon: Icons.check_circle_outline, color: cs.primary, onTap: onAprobar!),
                          const SizedBox(width: 5),
                        ],
                        if (onRegistrarDevolucion != null) ...[
                          ActionIcon(icon: Icons.assignment_return_outlined, color: cs.secondary, onTap: onRegistrarDevolucion!),
                          const SizedBox(width: 5),
                        ],
                        if (onEditar != null) ...[
                          ActionIcon(icon: Icons.edit_outlined, color: cs.tertiary, onTap: onEditar!),
                          const SizedBox(width: 5),
                        ],
                        if (onVerDetalle != null)
                          ActionIcon(icon: Icons.chevron_right_rounded, color: cs.onSurfaceVariant, onTap: onVerDetalle!),
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

// -- Grid de miniaturas --
class _ImageGrid extends StatelessWidget {
  final List<String> imagenes;
  final ColorScheme cs;
  final TextTheme tt;
  const _ImageGrid({required this.imagenes, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    if (imagenes.isEmpty) {
      return ColoredBox(
        color: cs.onPrimary.withValues(alpha: 0.20),
        child: Center(child: Icon(Icons.inventory_2_outlined, size: 26, color: cs.onPrimary.withValues(alpha: 0.6))),
      );
    }
    if (imagenes.length == 1) return Image.asset(imagenes[0], fit: BoxFit.cover);

    return GridView.count(
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      children: [
        for (int i = 0; i < imagenes.length && i < 3; i++)
          Image.asset(imagenes[i], fit: BoxFit.cover),
        if (imagenes.length >= 4)
          Image.asset(imagenes[3], fit: BoxFit.cover)
        else if (imagenes.length == 3)
          ColoredBox(
            color: cs.onPrimary.withValues(alpha: 0.25),
            child: Center(child: Text('3', style: tt.labelSmall?.copyWith(color: cs.onPrimary))),
          ),
        if (imagenes.length > 4)
          ColoredBox(
            color: cs.onPrimary.withValues(alpha: 0.40),
            child: Center(child: Text('+${imagenes.length - 3}', style: tt.labelSmall?.copyWith(color: cs.onPrimary))),
          ),
      ],
    );
  }
}