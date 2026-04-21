// Validadores reutilizables para formularios.
class ValidadoresFormulario {
  ValidadoresFormulario._();

  // Devuelve error si el campo está vacío.
  static String? campoObligatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }

  // Devuelve error si el valor no es un entero >= 0.
  static String? enteroPositivo(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Introduce un número válido';
    }
    final int? numero = int.tryParse(valor);
    if (numero == null || numero < 0) {
      return 'Introduce un número válido';
    }
    return null;
  }

  // Devuelve error si el valor no es un entero >= 1.
  static String? enteroMayorQueCero(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Debe ser un número mayor que 0';
    }
    final int? numero = int.tryParse(valor);
    if (numero == null || numero < 1) {
      return 'Debe ser un número mayor que 0';
    }
    return null;
  }

  // Devuelve error si el valor no es un decimal >= 0.
  static String? decimalPositivo(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Valor inválido';
    }
    final double? numero = double.tryParse(valor);
    if (numero == null || numero < 0) {
      return 'Valor inválido';
    }
    return null;
  }

  // Devuelve error si el email no tiene formato válido.
  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    final RegExp regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
    if (!regex.hasMatch(valor)) {
      return 'Email no válido';
    }
    return null;
  }

  // Devuelve error si el texto tiene menos de [minimo] caracteres.
  static String? longitudMinima(String? valor, int minimo) {
    if (valor == null || valor.length < minimo) {
      return 'Mínimo $minimo caracteres';
    }
    return null;
  }

  // Devuelve error si el valor del dropdown es null.
  static String? dropdownRequerido<T>(T? valor, String mensaje) {
    if (valor == null) {
      return mensaje;
    }
    return null;
  }
}
