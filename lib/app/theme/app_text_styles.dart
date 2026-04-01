import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // Título 
  static const TextStyle appTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: 4,
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

  // Etiquetas
  static const TextStyle tagline = TextStyle(
    fontSize: 13,
  );
}
