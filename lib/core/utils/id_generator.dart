import 'package:uuid/uuid.dart';

class GeneradorId {
  GeneradorId._();

  static const Uuid _uuid = Uuid();

  // Genera un ID entero único basado en UUID v4.
  static int idEntero() => _uuid.v4().hashCode.abs();

  // Genera un UUID v4 como String (listo para backend).
  static String idTexto() => _uuid.v4();
}
