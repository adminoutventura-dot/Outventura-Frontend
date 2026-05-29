import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

typedef LineaDisplayInfo = ({String nombre, String? imagen, int cantidad});

class BookingCard extends StatelessWidget {
  final Booking reserva;
  final List<LineaDisplayInfo> lineas;
  final String nombreUsuario;
  
  // Clave para saber si es Excursión o Material
  final bool esActividad; 
  final String? nombreActividad;

  // Todos los botones posibles
  final VoidCallback? onEditar;
  final VoidCallback? onAprobar;
  final VoidCallback? onRechazar;
  final VoidCallback? onRegistrarDevolucion;
  final VoidCallback? onCancelar;
  final VoidCallback? onVerDetalle;

  const BookingCard({
    super.key,
    required this.reserva,
    required this.lineas,
    required this.nombreUsuario,
    required this.esActividad,
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
      WorkflowStatus.pendiente => cs.tertiary,
      WorkflowStatus.confirmada => cs.primary,
      WorkflowStatus.enCurso => cs.secondary,
      WorkflowStatus.finalizada => cs.onSurfaceVariant,
      WorkflowStatus.cancelada => cs.error,
      _ => cs.outline,
    };

    final List<String> imagenesGrid = lineas
        .map((l) => l.imagen)
        .whereType<String>()
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
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
            // Franja de color izquierda
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.3),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CABECERA ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 62,
                            height: 62,
                            child: _ImageGrid(
                              imagenes: imagenesGrid,
                              cs: cs,
                              tt: tt,
                            ),
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
                                    esActividad
                                        ? 'EXCURSIÓ #${reserva.id ?? ""}'
                                        : 'RESERVA #${reserva.id ?? ""}',
                                    style: tt.labelSmall?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '  ·  ',
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      nombreUsuario,
                                      style: tt.labelSmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
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
                              // Fechas
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${FormateadorFecha.short(reserva.startDate)} – ${FormateadorFecha.short(reserva.endDate)}',
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              // Nombre de la excursión (si existe)
                              if (esActividad && nombreActividad != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.hiking_outlined,
                                      size: 13,
                                      color: cs.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        nombreActividad!,
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.primary,
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
                    
                    // --- SECCIÓN MATERIALES ---
                    if (lineas.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: statusColor.withValues(alpha: 0.20),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: lineas
                            .map(
                              (LineaDisplayInfo l) => Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 13,
                                      color: cs.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        l.nombre,
                                        style: tt.bodySmall?.copyWith(
                                          color: cs.onSurface,
                                        ),
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
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    // --- BOTONERA ---
                    const SizedBox(height: 4),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: statusColor.withValues(alpha: 0.20),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onCancelar != null) ...[
                          ActionIcon(
                            icon: Icons.cancel_outlined,
                            color: cs.error,
                            onTap: onCancelar!,
                          ),
                          const SizedBox(width: 5),
                        ],
                        if (onRechazar != null) ...[
                          ActionIcon(
                            icon: Icons.close_rounded,
                            color: cs.error,
                            onTap: onRechazar!,
                          ),
                          const SizedBox(width: 5),
                        ],
                        if (onAprobar != null) ...[
                          ActionIcon(
                            icon: Icons.check_circle_outline,
                            color: cs.primary,
                            onTap: onAprobar!,
                          ),
                          const SizedBox(width: 5),
                        ],
                        if (onRegistrarDevolucion != null) ...[
                          ActionIcon(
                            icon: Icons.assignment_return_outlined,
                            color: cs.secondary,
                            onTap: onRegistrarDevolucion!,
                          ),
                          const SizedBox(width: 5),
                        ],
                        if (onEditar != null) ...[
                          ActionIcon(
                            icon: Icons.edit_outlined,
                            color: cs.tertiary,
                            onTap: onEditar!,
                          ),
                          const SizedBox(width: 5),
                        ],
                        if (onVerDetalle != null)
                          ActionIcon(
                            icon: Icons.chevron_right_rounded,
                            color: cs.onSurfaceVariant,
                            onTap: onVerDetalle!,
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

class _ImageGrid extends StatelessWidget {
  final List<String> imagenes;
  final ColorScheme cs;
  final TextTheme tt;

  const _ImageGrid({
    required this.imagenes,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    if (imagenes.isEmpty) {
      return Container(
        color: cs.onPrimary.withValues(alpha: 0.20),
        child: Center(
          child: Icon(
            Icons.inventory_2_outlined,
            size: 26,
            color: cs.onPrimary.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    Widget buildImg(String src) {
      try {
        final cleanSrc = src.contains(',') ? src.split(',').last : src;
        return cleanSrc.startsWith('assets/')
            ? Image.asset(cleanSrc, fit: BoxFit.cover)
            : Image.memory(base64Decode(cleanSrc), fit: BoxFit.cover);
      } catch (e) {
        return Container(
          color: cs.surfaceContainerHighest,
          child: Icon(Icons.broken_image, size: 20, color: cs.outline),
        );
      }
    }

    if (imagenes.length == 1) {
      return buildImg(imagenes[0]);
    }

    return Wrap(
      spacing: 1.5,
      runSpacing: 1.5,
      children: [
        for (int i = 0; i < imagenes.length && i < 4; i++)
          SizedBox(
            width: 30.25,
            height: 30.25,
            child: (i == 3 && imagenes.length > 4)
                ? ColoredBox(
                    color: cs.onPrimary.withValues(alpha: 0.25),
                    child: Center(
                      child: Text(
                        '+${imagenes.length - 3}',
                        style: tt.labelSmall?.copyWith(color: cs.onPrimary),
                      ),
                    ),
                  )
                : buildImg(imagenes[i]),
          ),
      ],
    );
  }
}