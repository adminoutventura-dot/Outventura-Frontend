import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class ExcursionCard extends StatelessWidget {
  final Excursion excursion;
  final String? imagenAsset;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final VoidCallback? onSolicitar;

  const ExcursionCard({
    super.key,
    required this.excursion,
    this.imagenAsset,
    this.onEditar,
    this.onEliminar,
    this.onSolicitar,
  });


  @override
  Widget build(BuildContext context) {
    // Obtiene el esquema de colores del tema actual.
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final String? imagenResuelta = imagenAsset ?? excursion.imagenAsset;
    final s = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
      ),
      // Asegura que los hijos no se salgan de los bordes redondeados.
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Si hay imagen muestra el contenedor con la imagen y el texto 
          if (imagenResuelta != null)
          // Contenedor para la imagen.
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen.
                  Image.asset(imagenResuelta, fit: BoxFit.cover),
                  // Degradado
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        // Degradado oscuro.
                        colors: [Colors.transparent, cs.onSurface.withAlpha(250)],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),

                  // Texto sobre la imagen.
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 60,
                    child: Text(
                      // Punto de inicio y fin.
                      '${excursion.puntoInicio} → ${excursion.puntoFin}',
                      style: tt.labelLarge?.copyWith(
                        color: cs.surface,
                        shadows: [Shadow(color: cs.onSurface.withAlpha(180), blurRadius: 4)],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
          // Si no hay imagen muestra un contenedor con un icono y el texto.
          // Contenedor sin imagen.
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              // Fondo alternativo si no hay imagen.
              color: cs.primaryContainer,
              child: Row(
                children: [
                  // Icono
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      // Fondo del icono.
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.landscape, size: 20, color: cs.surfaceContainer),
                  ),
                  const SizedBox(width: 10),

                  // Texto
                  Expanded(
                    child: Text(
                      // Punto de inicio y fin.
                      '${excursion.puntoInicio} → ${excursion.puntoFin}',
                      style: tt.labelLarge?.copyWith(color: cs.onSurface),
                      // Trunca el texto si es muy largo.
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
          // Card - Parte Inferior
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icono de calendario.
                    Icon(Icons.calendar_today_outlined, size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      // Fecha de inicio.
                      FormateadorFecha.short(excursion.fechaInicio),
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: 10),
                    // Icono de reloj.
                    Icon(Icons.schedule, size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${FormateadorFecha.timeOnly(excursion.fechaInicio)} - ${FormateadorFecha.timeOnly(excursion.fechaFin)}',
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: 10),
                    // Icono de grupo.
                    Icon(Icons.group_outlined, size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      // Número de plazas.
                      s.placesCount(excursion.numeroParticipantes),
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    if (excursion.precio > 0) ...[
                      const SizedBox(width: 10),
                      Text(
                        s.pricePerPersonShort(excursion.precio.toStringAsFixed(0)),
                        style: tt.labelMedium?.copyWith(color: cs.primary),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Categorías de la excursión.
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      // Categorías
                      children: excursion.categorias
                          .map((CategoriaActividad c) => TagWidget(
                                text: c.localizedLabel(s),
                                backgroundColor: cs.secondary.withValues(alpha: 0.15),
                                textColor: cs.onPrimaryContainer,
                              ))
                          .toList(),
                    ),

                    const Spacer(),
                 
                    // ACCIONES
                    // Icono Editar
                    if (onEditar != null)
                      ActionIcon(
                        icon: Icons.edit_outlined,
                        color: cs.tertiary,
                        onTap: onEditar!
                      ),

                    const SizedBox(width: 10),

                    // Icono Eliminar
                    if (onEliminar != null)
                      ActionIcon(
                        icon: Icons.delete_outline,
                        color: cs.error,
                        onTap: onEliminar!,
                      ),

                    // Botón Solicitar
                    if (onSolicitar != null)
                      MiniButton(
                        label: s.requestBtn,
                        onPressed: onSolicitar,
                        textColor: cs.onTertiary,
                        backgroundColor: cs.onPrimary,
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




