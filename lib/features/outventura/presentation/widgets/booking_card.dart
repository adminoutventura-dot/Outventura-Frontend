import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:collection/collection.dart';

class BookingCard extends ConsumerWidget {
  final Booking reserva;
  final String nombreUsuario;
  final bool esActividad; 

  // Botones
  final VoidCallback? onEditar;
  final VoidCallback? onAprobar;
  final VoidCallback? onRechazar;
  final VoidCallback? onRegistrarDevolucion;
  final VoidCallback? onCancelar;
  final VoidCallback? onVerDetalle;

  const BookingCard({
    super.key,
    required this.reserva,
    required this.nombreUsuario,
    required this.esActividad,
    this.onEditar,
    this.onAprobar,
    this.onRechazar,
    this.onRegistrarDevolucion,
    this.onCancelar,
    this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    // LECTURA REACTIVA: Si los datos tardan, la tarjeta se repintará sola al llegar
    final List<Activity> todasLasActividades = ref.watch(allActivitiesProvider);
    final List<Equipment> todosLosEquipos = ref.watch(allEquipmentProvider);

    // Buscar la excursión
    final actLine = reserva.lines.firstWhereOrNull((l) => l.activityId != null);
    final Activity? actividadSeleccionada = actLine != null 
        ? todasLasActividades.firstWhereOrNull((a) => a.id == actLine.activityId) 
        : null;

    final String? nombreActividadReal = actividadSeleccionada?.title;

    // Construir la lista de materiales reactivos
    final lineasMaterial = reserva.lines.where((l) => l.equipmentId != null).toList();
    
    final List<String> imagenesGrid = lineasMaterial.map((l) {
      final eq = todosLosEquipos.firstWhereOrNull((e) => e.id == l.equipmentId);
      return eq?.imageAsset; 
    }).whereType<String>().toList();

    final Color statusColor = switch (reserva.status) {
      WorkflowStatus.pendiente => cs.tertiary,
      WorkflowStatus.confirmada => cs.primary,
      WorkflowStatus.enCurso => cs.secondary,
      WorkflowStatus.finalizada => cs.onSurfaceVariant,
      WorkflowStatus.cancelada => cs.error,
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Color.lerp(cs.surface, statusColor, 0.04),
        borderRadius: BorderRadius.zero, // Cuadrada
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
            Container(width: 5, decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.3))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.zero,
                          child: SizedBox(
                            width: 62, height: 62,
                            child: _ImageGrid(imagenes: imagenesGrid, cs: cs, tt: tt),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    esActividad ? 'EXCURSIÓN #${reserva.id ?? ""}' : 'RESERVA #${reserva.id ?? ""}',
                                    style: tt.labelMedium?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                                  ),
                                  Text('  ·  ', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                                  Expanded(
                                    child: Text(nombreUsuario, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: 8),
                                  TagWidget(text: reserva.status.localizedLabel(s), backgroundColor: statusColor.withValues(alpha: 0.13), textColor: statusColor),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 13, color: cs.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text('${FormateadorFecha.short(reserva.startDate)} – ${FormateadorFecha.short(reserva.endDate)}', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                                ],
                              ),
                              // LECTURA REACTIVA DE ACTIVIDAD
                              if (esActividad) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.hiking_outlined, size: 13, color: cs.primary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        nombreActividadReal ?? 'Cargando excursión...',
                                        style: tt.labelSmall?.copyWith(
                                          color: nombreActividadReal != null ? cs.primary : cs.onSurfaceVariant,
                                          fontStyle: nombreActividadReal != null ? FontStyle.normal : FontStyle.italic,
                                        ),
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
                    
                    // LECTURA REACTIVA DE MATERIALES
                    if (lineasMaterial.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Divider(height: 1, thickness: 0.5, color: statusColor.withValues(alpha: 0.20)),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: lineasMaterial.map((l) {
                          final equipo = todosLosEquipos.firstWhereOrNull((e) => e.id == l.equipmentId);
                          final nombreEq = equipo?.title ?? 'Cargando material...';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 13, color: cs.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    nombreEq,
                                    style: tt.bodySmall?.copyWith(
                                      color: equipo != null ? cs.onSurface : cs.onSurfaceVariant,
                                      fontStyle: equipo != null ? FontStyle.normal : FontStyle.italic,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                TagWidget(text: '×${l.quantity}', backgroundColor: cs.secondary.withValues(alpha: 0.15), textColor: cs.onPrimaryContainer),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 4),
                    Divider(height: 1, thickness: 0.5, color: statusColor.withValues(alpha: 0.20)),
                    const SizedBox(height: 9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onCancelar != null) ...[ ActionIcon(icon: Icons.cancel_outlined, color: cs.error, onTap: onCancelar!), const SizedBox(width: 5) ],
                        if (onRechazar != null) ...[ ActionIcon(icon: Icons.close_rounded, color: cs.error, onTap: onRechazar!), const SizedBox(width: 5) ],
                        if (onAprobar != null) ...[ ActionIcon(icon: Icons.check_circle_outline, color: cs.primary, onTap: onAprobar!), const SizedBox(width: 5) ],
                        if (onRegistrarDevolucion != null) ...[ ActionIcon(icon: Icons.assignment_return_outlined, color: cs.secondary, onTap: onRegistrarDevolucion!), const SizedBox(width: 5) ],
                        if (onEditar != null) ...[ ActionIcon(icon: Icons.edit_outlined, color: cs.tertiary, onTap: onEditar!), const SizedBox(width: 5) ],
                        if (onVerDetalle != null) ActionIcon(icon: Icons.chevron_right_rounded, color: cs.onSurfaceVariant, onTap: onVerDetalle!),
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

class _ImageGrid extends StatelessWidget {
  final List<String> imagenes;
  final ColorScheme cs;
  final TextTheme tt;

  const _ImageGrid({required this.imagenes, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    if (imagenes.isEmpty) return Container(color: cs.onPrimary.withValues(alpha: 0.20), child: Center(child: Icon(Icons.inventory_2_outlined, size: 26, color: cs.onPrimary.withValues(alpha: 0.6))));
    Widget buildImg(String src) {
      try {
        final cleanSrc = src.contains(',') ? src.split(',').last : src;
        return cleanSrc.startsWith('assets/') ? Image.asset(cleanSrc, fit: BoxFit.cover) : Image.memory(base64Decode(cleanSrc), fit: BoxFit.cover);
      } catch (e) {
        return Container(color: cs.surfaceContainerHighest, child: Icon(Icons.broken_image, size: 20, color: cs.outline));
      }
    }
    if (imagenes.length == 1) return buildImg(imagenes[0]);
    return Wrap(
      spacing: 1.5, runSpacing: 1.5,
      children: [
        for (int i = 0; i < imagenes.length && i < 4; i++)
          SizedBox(
            width: 30.25, height: 30.25,
            child: (i == 3 && imagenes.length > 4)
                ? ColoredBox(color: cs.onPrimary.withValues(alpha: 0.25), child: Center(child: Text('+${imagenes.length - 3}', style: tt.labelSmall?.copyWith(color: cs.onPrimary))))
                : buildImg(imagenes[i]),
          ),
      ],
    );
  }
}