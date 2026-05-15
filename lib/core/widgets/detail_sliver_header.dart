import 'package:flutter/material.dart';

// SliverAppBar reutilizable para páginas de detalle.
class DetailSliverHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;
  final double expandedHeight;

  const DetailSliverHeader({
    super.key,
    required this.title,
    required this.color,
    this.subtitle,
    this.expandedHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      automaticallyImplyLeading: true,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Patrón decorativo de círculos grandes en la esquina superior derecha.
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surface.withAlpha(18),
                  ),
                ),
              ),
              // Título y subtítulo en la parte inferior
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: tt.headlineSmall?.copyWith(
                        color: cs.surface,
                        shadows: [Shadow(color: cs.onSurface.withAlpha(100), blurRadius: 8)],
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: tt.bodySmall?.copyWith(
                          color: cs.surface.withAlpha(180),
                          shadows: [Shadow(color: cs.onSurface.withAlpha(100), blurRadius: 4)],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stat de texto: valor en negrita arriba y etiqueta pequeña abajo.
// Ocupa todo el espacio horizontal disponible (usar dentro de un Row).
class DetailStatItem extends StatelessWidget {
  final String label;
  final String value;

  const DetailStatItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
