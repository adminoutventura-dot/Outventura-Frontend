import 'package:flutter/material.dart';

// Catálogo de degradados de la app.
class AppGradients {
  AppGradients._();

  // Degradados ya en uso en la app 

  /// AppBar principal: primary → primary semitransparente (diagonal).
  /// Usado en [OutventuraAppBar].
  static LinearGradient appBar(ColorScheme cs) => LinearGradient(
        colors: [cs.primary, cs.primary.withValues(alpha: 0.72)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Header del drawer: tertiary → primary (diagonal).
  /// Usado en [AppDrawer].
  static LinearGradient drawer(ColorScheme cs) => LinearGradient(
        colors: [cs.tertiary, cs.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Header de perfil: surfaceContainer → primary (diagonal).
  /// Usado en [ProfileFormPage].
  static LinearGradient profileHeader(ColorScheme cs) => LinearGradient(
        colors: [cs.surfaceContainer, cs.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Overlay oscuro sobre imagen de tarjeta de actividad: transparente → onSurface.
  /// Usado en [ActivityCard].
  static LinearGradient cardImageOverlay(ColorScheme cs) => LinearGradient(
        colors: [Colors.transparent, cs.onSurface.withAlpha(250)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.4, 1.0],
      );

  /// Overlay de fondo de login: onSurface semitransparente → más opaco.
  /// Usado en [LoginPage].
  static LinearGradient loginOverlay(ColorScheme cs) => LinearGradient(
        colors: [cs.onSurface.withAlpha(128), cs.onSurface.withAlpha(179)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// Header de detalle con color personalizado (actividad, equipamiento…).
  /// Usado en [DetailSliverHeader].
  static LinearGradient detailHeader(Color color) => LinearGradient(
        colors: [color, color.withValues(alpha: 0.6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Degradados adicionales 

  /// Primary → secondary (diagonal). Para banners o hero cards.
  static LinearGradient primaryToSecondary(ColorScheme cs) => LinearGradient(
        colors: [cs.primary, cs.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Tertiary → secondary (diagonal). Tonos fríos-cálidos.
  static LinearGradient tertiaryToSecondary(ColorScheme cs) => LinearGradient(
        colors: [cs.tertiary, cs.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Primary → tertiary (diagonal inversa). Alternativa al drawer.
  static LinearGradient primaryToTertiary(ColorScheme cs) => LinearGradient(
        colors: [cs.primary, cs.tertiary],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );

  /// Overlay suave: completamente transparente → onSurface muy tenue.
  /// Para tarjetas con imagen que necesitan menos oscurecimiento que [cardImageOverlay].
  static LinearGradient subtleImageOverlay(ColorScheme cs) => LinearGradient(
        colors: [Colors.transparent, cs.onSurface.withAlpha(140)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.5, 1.0],
      );

  /// Degradado vertical: surface → primaryContainer. Para fondos de sección.
  static LinearGradient surfaceToPrimaryContainer(ColorScheme cs) =>
      LinearGradient(
        colors: [cs.surface, cs.primaryContainer],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// Degradado de error/alerta: error → secondary (diagonal).
  static LinearGradient errorToSecondary(ColorScheme cs) => LinearGradient(
        colors: [cs.error, cs.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
