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
        padding: EdgeInsets.fromLTRB(20, 36, 20, bottomPadding + 16),
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

/// Clipper que crea el corte curvo superior: sube en el centro, baja en los lados.
class _BottomBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {

    const double wave = 28; // cuánto bajan los lados respecto al centro

    final path = Path();

    // Lado izquierdo: comienza abajo (y = wave)
    path.moveTo(0, wave);

    // Arco hacia el centro (sube hasta y = 0)
    path.quadraticBezierTo(
      size.width * 0.25, 0,
      size.width * 0.50, 0,
    );

    // Arco desde el centro de vuelta abajo (y = wave)
    path.quadraticBezierTo(
      size.width * 0.75, 0,
      size.width, wave,
    );

    // Resto del rectángulo (lados y fondo)
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
