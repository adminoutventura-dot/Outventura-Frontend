import 'package:flutter/material.dart';

// Catálogo de degradados de la app.
class AppGradients {
  AppGradients._();

  // AppBar principal: primary → surfaceContainer (verde oscuro).
  // Usado en [CustomAppBar].
  static LinearGradient appBar(ColorScheme cs) => LinearGradient(
    colors: [cs.surfaceContainer, cs.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Header del drawer: tertiary → primary.
  // Usado en [AppDrawer].
  static LinearGradient drawer(ColorScheme cs) => LinearGradient(
    colors: [cs.tertiary, cs.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Overlay oscuro sobre imagen de tarjeta de actividad: transparente → onSurface.
  // Usado en [ActivityCard].
  static LinearGradient cardImageOverlay(ColorScheme cs) => LinearGradient(
    colors: [Colors.transparent, cs.onSurface.withAlpha(250)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: const [0.4, 1.0],
  );

  // Overlay de fondo de login: onSurface semitransparente → más opaco.
  // Usado en [LoginPage].
  static LinearGradient loginOverlay(ColorScheme cs) => LinearGradient(
    colors: [cs.onSurface.withAlpha(128), cs.onSurface.withAlpha(179)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Header de detalle con color personalizado (actividad, equipamiento…).
  // Usado en [DetailSliverHeader].
  static LinearGradient detailHeader(Color color) => LinearGradient(
    colors: [color, color.withValues(alpha: 0.6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  
  //----------------------------

  // Primary → primaryContainer. 
  static LinearGradient primaryToPrimaryContainer(ColorScheme cs) => LinearGradient(
    colors: [cs.primary, cs.primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Primary → primaryContainer. 
  static LinearGradient primaryContainerToPrimary(ColorScheme cs) => LinearGradient(
    colors: [cs.primaryContainer, cs.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Tertiary → onTertiary.
  static LinearGradient tertiaryToOnTertiary(ColorScheme cs) => LinearGradient(
    colors: [cs.tertiary, cs.onTertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // onPrimaryContainer → secondary.
  static LinearGradient onPrimaryContainerToSecondary(ColorScheme cs) => LinearGradient(
    colors: [cs.onPrimaryContainer, cs.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );


  // Pasa de un color sólido a su versión ligeramente más clara/transparente.
  static LinearGradient cardAccent(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    // Aumenta la luminosidad un 25% (sin pasar de 1.0) para crear la variante brillante
    final Color colorBrillante = hsl.withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0)).toColor();

    return LinearGradient(
      colors: [baseColor, colorBrillante],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Pasa de un color sólido a su versión ligeramente más clara/transparente.
  static LinearGradient cardAccentReverse(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    // Aumenta la luminosidad un 25% (sin pasar de 1.0) para crear la variante brillante
    final Color colorBrillante = hsl.withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0)).toColor();

    return LinearGradient(
      colors: [colorBrillante, baseColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Degradado diagonal para el fondo de los badges (Tags) de estado.
  // Aplica una opacidad uniforme del 15%.
  static LinearGradient badgeBackground(Color baseColor) => LinearGradient(
    colors: [
      baseColor.withValues(alpha: 0.15),
      baseColor.withValues(alpha: 0.10),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
