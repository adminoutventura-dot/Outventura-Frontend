import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

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
                        stops: const <double>[0.4, 1.0],
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
                        color: cs.surfaceContainer,
                        shadows: <Shadow>[Shadow(color: cs.onSurface.withAlpha(180), blurRadius: 4)],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
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
                    // Icono de paisaje.
                    child: Icon(Icons.landscape, size: 20, color: cs.inverseSurface),
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
                      _formatDate(excursion.fechaInicio),
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: 10),
                    // Icono de grupo.
                    Icon(Icons.group_outlined, size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      // Número de plazas.
                      '${excursion.numeroParticipantes} plazas',
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
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
                                text: c.label,
                                backgroundColor: cs.primaryContainer,
                                textColor: cs.onPrimaryContainer,
                              ))
                          .toList(),
                    ),

                    const Spacer(),
                 
                    // ACCIONES
                    // Icono Editar
                    if (onEditar != null)
                      IconButton(
                        onPressed: onEditar,
                        icon: Icon(Icons.edit_outlined, color: cs.onPrimaryContainer),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),

                    const SizedBox(width: 10),

                    // Icono Eliminar
                    if (onEliminar != null)
                      IconButton(
                        onPressed: onEliminar,
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),

                    // Botón Solicitar
                    if (onSolicitar != null)
                      MiniButton(
                        label: 'Solicitar',
                        onPressed: onSolicitar,
                        textColor: cs.onSecondaryContainer,
                        backgroundColor: cs.secondaryContainer,
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

// TODO: Ese puede cambiar por el formato de fecha
String _formatDate(DateTime dt) {
  const List<String> months = <String>['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}


