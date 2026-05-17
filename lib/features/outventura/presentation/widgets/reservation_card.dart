import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';


typedef LineaDisplayInfo = ({String nombre, String? imagen, int cantidad});

class ReservationCard extends StatelessWidget {
  final Reservation reserva;
  // Líneas de la reserva con datos resueltos por el padre (nombre, imagen, cantidad).
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

    // Colores base para el texto del badge según el estado
    final Color statusColor = switch (reserva.status) {
      ReservationStatus.pendiente => cs.tertiary,
      ReservationStatus.confirmada => cs.primary,
      ReservationStatus.enCurso => cs.secondary,
      ReservationStatus.finalizada => cs.onSurfaceVariant,
      ReservationStatus.cancelada => cs.error,
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
                                  '${FormateadorFecha.short(reserva.startDate)} - ${FormateadorFecha.short(reserva.endDate)}',
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
                                '${FormateadorFecha.timeOnly(reserva.startDate)} - ${FormateadorFecha.timeOnly(reserva.endDate)}',
                                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                          // Excursión vinculada (opcional)
                          if (nombreActividad != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.hiking_outlined, size: 12, color: cs.primary),
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
                    const SizedBox(width: 8),
                    // Badge con el color armonizado del estado correspondiente
                    TagWidget(
                      text: reserva.status.localizedLabel(s),
                      backgroundColor: statusColor.withValues(alpha: 0.15),
                      textColor: statusColor,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Líneas de la reserva
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
                    if (reserva.damageFee > 0) ...[
                      Row(
                        children: [
                          Icon(Icons.warning_amber_outlined, size: 12, color: cs.error),
                          const SizedBox(width: 4),
                          Text(
                            s.damageChargeAmount(reserva.damageFee.toStringAsFixed(2)),
                            style: tt.labelSmall?.copyWith(color: cs.error),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ],
                    const Spacer(),
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
                      ActionIcon(icon: Icons.assignment_return_outlined, color: cs.secondary, onTap: onRegistrarDevolucion!),
                    ],
                    if (onEditar != null) ...[
                      const SizedBox(width: 8),
                      ActionIcon(icon: Icons.edit_outlined, color: cs.tertiary, onTap: onEditar!),
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