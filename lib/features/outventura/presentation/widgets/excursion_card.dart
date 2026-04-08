import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

class ExcursionCard extends StatelessWidget {
  final Excursion excursion;
  final String? imageAsset;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final VoidCallback? onSolicitar;

  const ExcursionCard({
    super.key,
    required this.excursion,
    this.imageAsset,
    this.onEditar,
    this.onEliminar,
    this.onSolicitar,
  });

  @override
  Widget build(BuildContext context) {
    // Obtiene el esquema de colores del tema actual.
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final resolvedImageAsset = imageAsset ?? excursion.imageAsset;

    return Container(
      decoration: BoxDecoration(
        // Fondo de la tarjeta.
        color: cs.surface,
        // Bordes redondeados.
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            // Sombra ligera.
            color: cs.onPrimaryContainer.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // Asegura que los hijos no se salgan de los bordes redondeados.
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (resolvedImageAsset != null)
          // Contenedor para la imagen.
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Muestra la imagen.
                  Image.asset(resolvedImageAsset, fit: BoxFit.cover),
                  // Degradado
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        // Degradado oscuro.
                        colors: [Colors.transparent, cs.onSurface.withAlpha(250)],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Texto sobre la imagen.
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 60,
                    child: Text(
                      // Muestra el punto de inicio y fin.
                      '${excursion.puntoInicio} → ${excursion.puntoFin}',
                      style: tt.labelLarge?.copyWith(
                        color: cs.surfaceContainer,
                        shadows: [Shadow(color: cs.onSurface.withAlpha(180), blurRadius: 4)],
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
                      // Muestra el punto de inicio y fin.
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
                      // Muestra la fecha de inicio.
                      _formatDate(excursion.fechaInicio),
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: 10),
                    // Icono de grupo.
                    Icon(Icons.group_outlined, size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      // Muestra el número de plazas.
                      '${excursion.numeroParticipantes} plazas',
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Muestra las categorías de la excursión.
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        // Categorías
                        children: excursion.categorias
                            .map((c) => TagWidget(
                                  text: c.nombre,
                                  backgroundColor: cs.primaryContainer,
                                  textColor: cs.onPrimaryContainer,
                                ))
                            .toList(),
                      ),
                    ),
                    // Icono Editar
                    if (onEditar != null)
                      InkWell(
                        // Acción de editar.
                        onTap: onEditar,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          // Icono de edición.
                          child: Icon(Icons.edit_outlined, size: 18, color: cs.inverseSurface),
                        ),
                      ),

                    // Icono Eliminar
                    if (onEliminar != null)
                      InkWell(
                        // Acción de eliminar.
                        onTap: onEliminar,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          // Icono de eliminación.
                          child: Icon(Icons.delete_outline, size: 18, color: cs.error),
                        ),
                      ),

                    // Botón Solicitar
                    if (onSolicitar != null)
                      PrimaryButton(
                        label: 'Solicitar',
                        onPressed: () {},
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

String _formatDate(DateTime dt) {
  const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}


