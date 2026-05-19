import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';

// AppBar reutilizable con efecto cortado
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize {
    final double bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight + 20);
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

// CustomClipper para crear el efecto cortado
class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Comenzar desde arriba a la izquierda
    path.lineTo(0, 0);
    
    // Línea superior
    path.lineTo(size.width, 0);
    
    // Línea derecha hasta casi abajo
    path.lineTo(size.width, size.height - 20);
    
    // Curva suave en la parte inferior (estilo "cortado")
    // Ajusta estos valores para controlar la curvatura
    path.quadraticBezierTo(
      size.width * 0.75,      // Punto de control X
      size.height + 10,        // Punto de control Y (más pronunciado)
      size.width * 0.5,        // Punto final X (centro)
      size.height - 5,         // Punto final Y
    );
    
    path.quadraticBezierTo(
      size.width * 0.25,       // Punto de control X
      size.height - 30,        // Punto de control Y
      0,                       // Punto final X (izquierda)
      size.height -10,             // Punto final Y (altura completa)
    );
    
    // Cerrar el path
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


