import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';

// Barra inferior con gradiente y corte curvo en la parte superior,

class BottomPriceBar extends StatelessWidget {
  final String totalLabel;
  final String price;
  final String actionLabel;
  final VoidCallback? onPressed;

  const BottomPriceBar({
    super.key,
    required this.totalLabel,
    required this.price,
    required this.actionLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipPath(
      clipper: _BottomBarClipper(),
      child: Container(
        height: 160,
        padding: EdgeInsets.fromLTRB(40, 80, 40, bottomPadding + 16),
        decoration: BoxDecoration(gradient: AppGradients.appBar(cs)),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalLabel,
                  style: tt.labelSmall?.copyWith(color: cs.onPrimary.withAlpha(180)),
                ),
                Text(
                  price,
                  style: tt.titleMedium?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: cs.onPrimary,
                foregroundColor: cs.primary,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Empieza un poco abajo izquierda
    path.moveTo(0, 100);

    // Curva redondeada izquierda
    path.quadraticBezierTo(
      0,
      60,
      60,
      60,
    );

    // Línea recta central
    path.lineTo(size.width * 0.85, 60);

    // Curva progresiva final
    path.quadraticBezierTo(
      size.width * 0.95,
      60,
      size.width,
      0,
    );

    // Lado derecho hacia abajo
    path.lineTo(size.width, size.height);

    // Parte inferior
    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}