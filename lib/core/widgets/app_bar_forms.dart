import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';

// AppBar reutilizable con efecto cortado
class CustomAppBarForm extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  
  const CustomAppBarForm({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize {
    final double bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight + 50); // +20 para el efecto cortado
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return ClipPath(
      clipper: AppBarClipper(),
      child: AppBar(
        title: Text(title),
        automaticallyImplyLeading: true,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        actions: actions,
        bottom: bottom,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.appBar(cs),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.onPrimary.withAlpha(18),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 90,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.onPrimary.withAlpha(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Clipper: lados bajan, centro sube en arco
class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    //  Ajustes 
    const double archHeight = 40;   // altura de las orejas laterales
    const double centerWidth = 1; // fracción del ancho que ocupa la parte alta (0.0–1.0)
    const double cornerRadius = 40;  // radio de las esquinas interiores
    

    final double sideEnd = (1 - centerWidth) / 2;   // ej. 0.15
    final double sideStart = 1 - sideEnd;            // ej. 0.85
    const double r = cornerRadius;
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);

    // Oreja derecha — esquina inferior interior redondeada
    path.lineTo(size.width * sideStart + r, size.height);
    path.quadraticBezierTo(size.width * sideStart, size.height, size.width * sideStart, size.height - r);
    // Pared interior derecha sube
    path.lineTo(size.width * sideStart, size.height - archHeight + r);
    // Esquina superior interior redondeada
    path.quadraticBezierTo(size.width * sideStart, size.height - archHeight, size.width * sideStart - r, size.height - archHeight);

    // Centro plano
    path.lineTo(size.width * sideEnd + r, size.height - archHeight);

    // Oreja izquierda — esquina superior interior redondeada
    path.quadraticBezierTo(size.width * sideEnd, size.height - archHeight, size.width * sideEnd, size.height - archHeight + r);
    // Pared interior izquierda baja
    path.lineTo(size.width * sideEnd, size.height - r);
    // Esquina inferior interior redondeada
    path.quadraticBezierTo(size.width * sideEnd, size.height, size.width * sideEnd - r, size.height);

    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
