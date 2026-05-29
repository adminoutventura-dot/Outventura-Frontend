import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'dart:convert';

class ActivityCard extends StatelessWidget {
  final Activity actividad;
  final String? imagenAsset;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final VoidCallback? onSolicitar;

  const ActivityCard({
    super.key,
    required this.actividad,
    this.imagenAsset,
    this.onEditar,
    this.onEliminar,
    this.onSolicitar,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final String? imagenResuelta = imagenAsset ?? actividad.imageAsset;
    final s = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withValues(alpha: 0.15),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- IMAGEN o HEADER SIN IMAGEN --
          if (imagenResuelta != null && imagenResuelta.isNotEmpty)
            SizedBox(
              height: 130,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imagenResuelta.startsWith('assets/')
                      ? Image.asset(imagenResuelta, fit: BoxFit.cover)
                      : Image.memory(
                          base64Decode(imagenResuelta),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: cs.primaryContainer,
                                child: Icon(
                                  Icons.broken_image,
                                  color: cs.primary,
                                ),
                              ),
                        ),
                  // Overlay degradado más fuerte en la zona de abajo
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppGradients.cardImageOverlay(cs),
                    ),
                  ),

                  // Título sobre la imagen (Sustituye a la antigua ruta)
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      children: [
                        Icon(
                          Icons.terrain_outlined,
                          size: 16,
                          color: cs.onPrimary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            actividad.title,
                            style: tt.titleMedium?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: cs.onSurface.withAlpha(160),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            // Header sin imagen: banda de color con icono + Título
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.35),
              ),
              child: Row(
                children: [
                  // Icono de actividad
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.terrain_outlined,
                      size: 20,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Título de la actividad
                  Expanded(
                    child: Text(
                      actividad.title,
                      style: tt.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // -- CUERPO --
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Punto de encuentro unificado (Si existe)
                if (actividad.startEndPoint != null &&
                    actividad.startEndPoint!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          actividad.startEndPoint!,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Datos en una fila (Fecha, Horario, Plazas)
                Wrap(
                  spacing: 14,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Fecha
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          FormateadorFecha.short(actividad.initDate),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    // Horario
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 13,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${FormateadorFecha.timeOnly(actividad.initDate)} – ${FormateadorFecha.timeOnly(actividad.endDate)}',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    // Plazas
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 13,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          s.placesCount(actividad.maxParticipants),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tags + acciones
                Row(
                  children: [
                    // Categorías
                    Expanded(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: actividad.categories
                            .map(
                              (Category c) => TagWidget(
                                text: c.localizedLabel(s),
                                backgroundColor: cs.onSurfaceVariant.withValues(
                                  alpha: 0.15,
                                ),
                                textColor: cs.onSurfaceVariant,
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    // Botones de acción
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Editar
                        if (onEditar != null)
                          ActionIcon(
                            icon: Icons.edit_outlined,
                            color: cs.tertiary,
                            onTap: onEditar!,
                          ),

                        // Separador
                        if (onEditar != null && onEliminar != null)
                          const SizedBox(width: 6),

                        // Eliminar
                        if (onEliminar != null)
                          ActionIcon(
                            icon: Icons.delete_outline,
                            color: cs.error,
                            onTap: onEliminar!,
                          ),

                        // Separador
                        if ((onEditar != null || onEliminar != null) &&
                            onSolicitar != null)
                          const SizedBox(width: 6),

                        // Solicitar
                        if (onSolicitar != null)
                          MiniButton(
                            label: s.requestBtn,
                            onPressed: onSolicitar,
                            textColor: cs.onPrimary,
                            backgroundColor: cs.primary,
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
}
