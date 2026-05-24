import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

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
          if (imagenResuelta != null)
            SizedBox(
              height: 130, width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(imagenResuelta, fit: BoxFit.cover),
                  // Overlay degradado más fuerte en la zona de abajo
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppGradients.cardImageOverlay(cs),
                    ),
                  ),

                  // Ruta sobre la imagen
                  Positioned(
                    bottom: 12, left: 14, right: 14,
                    child: Row(
                      children: [
                        Icon(Icons.place_outlined, size: 13, color: cs.onPrimary.withValues(alpha: 0.85)),
                        const SizedBox(width: 4),
                        // Si la ruta es muy larga, se muestra con puntos suspensivos al final.
                        Expanded(
                          child: Text(
                            '${actividad.startPoint}  →  ${actividad.endPoint}',
                            style: tt.labelMedium?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w600,
                              shadows: [Shadow(color: cs.onSurface.withAlpha(160), blurRadius: 6)],
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
            // Header sin imagen: banda de color con icono + ruta
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.35),
              ),
              child: Row(
                children: [
                  // Icono de actividad (si no hay imagen, se muestra un icono genérico)
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.terrain_outlined, size: 20, color: cs.primary),
                  ),
                  const SizedBox(width: 12),

                  // Ruta
                  Expanded(
                    child: Text(
                      '${actividad.startPoint}  →  ${actividad.endPoint}',
                      style: tt.labelLarge?.copyWith(color: cs.onSurface),
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
                // Datos en una fila
                Wrap(
                  spacing: 14,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Fecha
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 13, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(FormateadorFecha.short(actividad.initDate), style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],

                    ),
                    
                    // Horario
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule_outlined, size: 13, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('${FormateadorFecha.timeOnly(actividad.initDate)} – ${FormateadorFecha.timeOnly(actividad.endDate)}', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),

                    // Plazas
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group_outlined, size: 13, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(s.placesCount(actividad.maxParticipants), style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),

                // Precio
                if (actividad.price > 0) ...[
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.pricePerPersonShort(actividad.price.toStringAsFixed(2)),
                      style: tt.labelMedium?.copyWith( color: cs.primary),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Tags + acciones
                Row(
                  children: [
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: actividad.categories
                          .map((Category c) => TagWidget(
                                text: c.localizedLabel(s),
                                backgroundColor: cs.onSurfaceVariant.withValues(alpha: 0.2),
                                textColor: cs.onPrimaryContainer,
                              ))
                          .toList(),
                    ),
                    const Spacer(),
                    
                    // Editar
                    if (onEditar != null)
                      ActionIcon(icon: Icons.edit_outlined, color: cs.tertiary, onTap: onEditar!),
                      
                    // Si hay acción de editar y eliminar, se muestra un espacio entre ambos iconos.
                    if (onEditar != null && onEliminar != null)
                      const SizedBox(width: 6),

                    // Eliminar
                    if (onEliminar != null)
                      ActionIcon(icon: Icons.delete_outline, color: cs.error, onTap: onEliminar!),

                    // Si hay acción de editar o eliminar, se muestra un espacio entre estos iconos y el botón de solicitar.
                    if (onSolicitar != null) ...[
                      const SizedBox(width: 6),
                      MiniButton(
                        label: s.requestBtn,
                        onPressed: onSolicitar,
                        textColor: cs.onPrimary,
                        backgroundColor: cs.primary,
                      ),
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
