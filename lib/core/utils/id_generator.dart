import 'package:uuid/uuid.dart';

class GeneradorId {
  GeneradorId._();

  static const Uuid _uuid = Uuid();

  // Para datos fake
  // Genera un ID entero único basado en UUID v4.
  static int idEntero(){
    return _uuid.v4().hashCode.abs();
  }

  // Genera un UUID v4 como String (listo para backend).
  static String idTexto(){ 
    return _uuid.v4();
  }
}
