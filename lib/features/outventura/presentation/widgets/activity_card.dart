import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final Activity actividad;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final VoidCallback? onSolicitar;

  const ActivityCard({
    super.key,
    required this.actividad,
    this.onEditar,
    this.onEliminar,
    this.onSolicitar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    // Calcula la disponibilidad real comprobando la fecha
    final bool isAvailable = actividad.initDate.isAfter(DateTime.now());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onSolicitar,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen Header
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: actividad.imageAsset != null
                    ? DecorationImage(
                        image: AssetImage(actividad.imageAsset!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: actividad.imageAsset == null
                    ? cs.surfaceContainerHighest
                    : null,
              ),
              child: actividad.imageAsset == null
                  ? Center(
                      child: Icon(
                        Icons.terrain,
                        size: 50,
                        color: cs.onSurfaceVariant,
                      ),
                    )
                  : null,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pinta el nuevo Title en lugar del startPoint
                  Text(
                    actividad.title,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Fecha y Hora
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('dd/MM/yyyy HH:mm').format(actividad.initDate)} - ${DateFormat('HH:mm').format(actividad.endDate)}',
                        style: tt.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Pinta el punto unificado
                  if (actividad.startEndPoint != null)
                    Row(
                      children: [
                        Icon(Icons.place, size: 16, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            actividad.startEndPoint!,
                            style: tt.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Etiquetas inferiores y Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TagWidget(
                        text: isAvailable
                            ? s.statusAvailable
                            : s.statusNotAvailable,
                        backgroundColor: isAvailable
                            ? cs.primaryContainer
                            : cs.errorContainer,
                        textColor: isAvailable
                            ? cs.onPrimaryContainer
                            : cs.onErrorContainer,
                      ),

                      Row(
                        children: [
                          if (onEditar != null)
                            IconButton(
                              icon: Icon(Icons.edit, color: cs.tertiary),
                              onPressed: onEditar,
                            ),
                          if (onEliminar != null)
                            IconButton(
                              icon: Icon(Icons.delete, color: cs.error),
                              onPressed: onEliminar,
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
      ),
    );
  }
}
