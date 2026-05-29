import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';

// Tarjeta de actividad adaptada para mostrar el título unificado en el carrusel horizontal.
class ActivityCarouselCard extends StatelessWidget {
  final Activity actividad;

  const ActivityCarouselCard({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de cabecera visual de la tarjeta
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primaryContainer,
                  cs.primaryContainer.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: actividad.imageAsset != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(actividad.imageAsset!, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0x66000000)],
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Icon(
                      Icons.landscape,
                      size: 48,
                      color: cs.onPrimaryContainer.withValues(alpha: 0.5),
                    ),
                  ),
          ),

          // Bloque descriptivo inferior de la actividad
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actividad.startEndPoint ?? 'Ruta no especificada',
                    style: tt.labelMedium,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${actividad.maxParticipants} plazas',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Excursió',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Botón estructural reutilizable para los accesos rápidos del panel general.
class HomeQuickActionButton extends StatelessWidget {
  final String label;
  final Color? textColor;
  final VoidCallback onTap;

  const HomeQuickActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface.withValues(alpha: 0.8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(top: 30, bottom: 25),
          alignment: Alignment.center,
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor ?? cs.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
