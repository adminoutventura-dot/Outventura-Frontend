import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // Título principal
  static const TextStyle appTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: 4,
  );

  // Encabezado grande
  static const TextStyle headline = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  // Subtítulo
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Texto estándar
  static const TextStyle body = TextStyle(
    fontSize: 14,
  );

  // Texto en negrita
  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  // Texto para botones
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.1,
  );

  // Texto para enlaces
  static const TextStyle link = TextStyle(
    fontSize: 14,
    decoration: TextDecoration.underline,
    fontWeight: FontWeight.w500,
  );

  // Etiquetas
  static const TextStyle tagline = TextStyle(
    fontSize: 13,
  );

  // Texto pequeño para fechas, plazas, etc.
  static const TextStyle caption = TextStyle(
    fontSize: 11,
  );

  // Texto para chips de categorías
  static const TextStyle tag = TextStyle(
    fontSize: 10,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 9,
    letterSpacing: 1.5,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
  );
}
