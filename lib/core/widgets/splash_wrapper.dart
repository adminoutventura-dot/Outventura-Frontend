import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:outventura/main.dart';

// TODO: REVISAR
// Widget que muestra la pantalla de splash animada al arrancar la app.
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Opacidad: 0 → 1 (entrada) · 1 (espera) · 1 → 0 (salida)
  late final Animation<double> _opacity;

  // Escala: 0.80 → 1.0 (zoom de entrada) · 1.0 (se mantiene el resto)
  late final Animation<double> _scale;

  // Indica si la animación ha terminado y hay que mostrar [MainApp].
  bool _done = false;

  @override
  void initState() {
    super.initState();

    // Quita el splash nativo para que se vea el splash Flutter animado.
    FlutterNativeSplash.remove();

    // Duración total de la animación: 1800 ms.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Secuencia de opacidad dividida en tres fases (pesos = porcentaje de tiempo):
    //   33 % → fade-in  (0.0 → 1.0)
    //   45 % → estático (1.0)
    //   22 % → fade-out (1.0 → 0.0)
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 33,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 22,
      ),
    ]).animate(_ctrl);

    // Secuencia de escala:
    //   33 % → zoom-in (0.80 → 1.0)
    //   67 % → tamaño real (1.0)
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.50, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 33,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 67),
    ]).animate(_ctrl);

    // Lanza la animación y, al completarse, marca _done para pasar a MainApp.
    _ctrl.forward().whenComplete(() {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Animación terminada → entrega el control a la app real.
    if (_done) return const MainApp();

    // Mientras la animación está en curso, muestra el logo sobre fondo blanco.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                // Logo con texto de Outventura.
                child: Image.asset('assets/images/logo2.png', width: 260),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
