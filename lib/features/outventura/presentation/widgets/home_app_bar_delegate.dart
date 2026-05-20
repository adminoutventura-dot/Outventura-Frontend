import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/features/outventura/presentation/widgets/stat_card.dart';

// Ranura de estadística para el header colapsable del home.
class HomeStatSlot {
  final String value;
  final String label;

  const HomeStatSlot({
    required this.value,
    required this.label,
  });
}

// Especifica de como se tiene que comportar el header del home al hacer scroll.
// Muestra gradiente con círculos decorativos, saludo, fecha y una fila de stat cards colapsables.
class HomeAppBarDelegate extends SliverPersistentHeaderDelegate {
  static const double kBottomHeight = 145.0;

  final double topPadding;
  final String title;
  final String greeting;
  final String dateStr;
  final List<HomeStatSlot> statSlots;
  final double collapsedHeight;

  const HomeAppBarDelegate({
    required this.topPadding,
    required this.title,
    required this.greeting,
    required this.dateStr,
    required this.statSlots,
    this.collapsedHeight = 0.0,
  });

  // El tamaño máximo del header.
  @override
  double get maxExtent => topPadding + kToolbarHeight + kBottomHeight;

  // El tamaño mínimo del header
  @override
  double get minExtent => topPadding + kToolbarHeight + collapsedHeight;

  @override
  bool shouldRebuild(covariant HomeAppBarDelegate old) =>
      old.topPadding != topPadding ||
      old.greeting != greeting ||
      old.dateStr != dateStr ||
      old.statSlots.length != statSlots.length;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = (shrinkOffset / kBottomHeight).clamp(0.0, 1.0);

    return ClipPath(
      clipper: AppBarClipper(),
      child: Material(
        // El header tiene una elevación solo cuando está colapsado para proyectar sombra sobre el contenido.
        elevation: overlapsContent ? 4 : 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(gradient: AppGradients.appBar(cs)),
          child: Stack(
            children: [
              // Círculos decorativos de fondo
              Positioned(top: -40, right: -40, child: _circle(180, cs.onPrimary.withAlpha(18))),
              Positioned(top: 20, right: 90, child: _circle(80, cs.onPrimary.withAlpha(12))),
              Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toolbar (siempre visible al colapsar)
                    SizedBox(
                      height: kToolbarHeight,
                      child: Row(
                        children: [
                          // Botón de menú para abrir el drawer.
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(Icons.menu),
                              color: cs.onPrimary,
                              onPressed: () => Scaffold.of(ctx).openDrawer(),
                            ),
                          ),
                          // Título del header
                          Expanded(
                            child: Text(
                              title,
                              style: tt.titleMedium?.copyWith(color: cs.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Contenido colapsable: saludo + fecha + stat cards
                    SizedBox(
                      // .clamp() para que el valor sea entre 0 y kBottomHeight.
                      height: (maxExtent - shrinkOffset - topPadding - kToolbarHeight).clamp(0.0, kBottomHeight),
                      child: OverflowBox(
                        minHeight: 0,
                        maxHeight: kBottomHeight,
                        alignment: Alignment.topLeft,
                        child: Opacity(
                          opacity: (1 - progress * 2).clamp(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Saludo personalizado
                                Text(
                                  greeting,
                                  style: tt.titleLarge?.copyWith(color: cs.onPrimary),
                                ),
                                const SizedBox(height: 2),
                                // Fecha actual
                                Text(
                                  dateStr,
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onPrimary.withValues(alpha: 0.78),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Fila de stat cards
                                Row(
                                  children: [
                                    for (int i = 0; i < statSlots.length; i++) ...[
                                      if (i > 0) _divider(cs),
                                      Expanded(
                                        child: StatCard(
                                          value: statSlots[i].value,
                                          label: statSlots[i].label,
                                          foregroundColor: cs.onPrimary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Separador vertical entre stat cards
  Widget _divider(ColorScheme cs) => Container(
    width: 1,
    height: 36,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: cs.onPrimary.withValues(alpha: 0.30),
  );

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
