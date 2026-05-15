import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';

// AppBar reutilizable con efecto cortado
class OutventuraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  
  const OutventuraAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize {
    final double bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight + 20); // +20 para el efecto cortado
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


// // Clipper: lados bajan, centro sube en arco
// class AppBarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     //  Ajustes 
//     const double archHeight = 20;   // altura de las orejas laterales
//     const double centerWidth = 1.001; // fracción del ancho que ocupa la parte alta (0.0–1.0)
//     const double cornerRadius = 25;  // radio de las esquinas interiores
    

//     final double sideEnd = (1 - centerWidth) / 2;   // ej. 0.15
//     final double sideStart = 1 - sideEnd;            // ej. 0.85
//     const double r = cornerRadius;
//     final path = Path();

//     path.moveTo(0, 0);
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height);

//     // Oreja derecha — esquina inferior interior redondeada
//     path.lineTo(size.width * sideStart + r, size.height);
//     path.quadraticBezierTo(size.width * sideStart, size.height, size.width * sideStart, size.height - r);
//     // Pared interior derecha sube
//     path.lineTo(size.width * sideStart, size.height - archHeight + r);
//     // Esquina superior interior redondeada
//     path.quadraticBezierTo(size.width * sideStart, size.height - archHeight, size.width * sideStart - r, size.height - archHeight);

//     // Centro plano
//     path.lineTo(size.width * sideEnd + r, size.height - archHeight);

//     // Oreja izquierda — esquina superior interior redondeada
//     path.quadraticBezierTo(size.width * sideEnd, size.height - archHeight, size.width * sideEnd, size.height - archHeight + r);
//     // Pared interior izquierda baja
//     path.lineTo(size.width * sideEnd, size.height - r);
//     // Esquina inferior interior redondeada
//     path.quadraticBezierTo(size.width * sideEnd, size.height, size.width * sideEnd - r, size.height);

//     path.lineTo(0, size.height);

//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }


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
      size.height - 20,        // Punto de control Y
      0,                       // Punto final X (izquierda)
      size.height - 20,        // Punto final Y
    );
    
    // Cerrar el path
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


// // Versión más pronunciada (como en tu imagen de referencia)
// class AppBarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
    
//     path.lineTo(0, 0);
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height - 30);
    
//     // Curva más pronunciada
//     path.quadraticBezierTo(
//       size.width * 0.85,       // Inicio de curva más a la derecha
//       size.height + 20,        // Curva más profunda
//       size.width * 0.5,        // Centro
//       size.height - 10,        // Altura del centro
//     );
    
//     path.quadraticBezierTo(
//       size.width * 0.15,       // Fin de curva más a la izquierda
//       size.height - 40,        // Más pronunciado
//       0,                       
//       size.height - 30,        
//     );
    
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

// // Versión sutil (ondulación suave)
// class AppBarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
    
//     path.lineTo(0, 0);
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height - 20);
    
//     // Curva muy suave
//     path.cubicTo(
//       size.width * 0.75, size.height,      // Control 1
//       size.width * 0.25, size.height,      // Control 2
//       0, size.height - 20,                 // Final
//     );
    
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }