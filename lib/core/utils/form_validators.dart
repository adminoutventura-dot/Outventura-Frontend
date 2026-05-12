import 'package:outventura/l10n/app_localizations.dart';

// Validadores reutilizables para formularios.
class ValidadoresFormulario {
  ValidadoresFormulario._();

  // Devuelve error si el campo está vacío.
  static String? Function(String?) campoObligatorio(AppLocalizations s) {
    return (String? valor) {
      if (valor == null || valor.trim().isEmpty) {
        return s.fieldRequired;
      }
      return null;
    };
  }

  // Devuelve error si el valor no es un entero >= 0.
  static String? Function(String?) enteroPositivo(AppLocalizations s) {
    return (String? valor) {
      if (valor == null || valor.isEmpty) {
        return s.invalidNumber;
      }
      final int? numero = int.tryParse(valor);
      if (numero == null || numero < 0) {
        return s.invalidNumber;
      }
      return null;
    };
  }

  // Devuelve error si el valor no es un entero >= 1.
  static String? Function(String?) enteroMayorQueCero(AppLocalizations s) {
    return (String? valor) {
      if (valor == null || valor.isEmpty) {
        return s.mustBeGreaterThanZero;
      }
      final int? numero = int.tryParse(valor);
      if (numero == null || numero < 1) {
        return s.mustBeGreaterThanZero;
      }
      return null;
    };
  }

  // Devuelve error si el valor no es un decimal >= 0.
  static String? Function(String?) decimalPositivo(AppLocalizations s) {
    return (String? valor) {
      if (valor == null || valor.isEmpty) {
        return s.invalidValue;
      }
      final double? numero = double.tryParse(valor);
      if (numero == null || numero < 0) {
        return s.invalidValue;
      }
      return null;
    };
  }

  // Devuelve error si el email no tiene formato válido.
  static String? Function(String?) email(AppLocalizations s) {
    return (String? valor) {
      if (valor == null || valor.trim().isEmpty) {
        return s.fieldRequired;
      }
      final RegExp regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
      if (!regex.hasMatch(valor)) {
        return s.invalidEmail;
      }
      return null;
    };
  }

  // Devuelve error si el texto tiene menos de [minimo] caracteres.
  static String? Function(String?) longitudMinima(AppLocalizations s, int minimo) {
    return (String? valor) {
      if (valor == null || valor.length < minimo) {
        return s.minChars(minimo);
      }
      return null;
    };
  }

  // Devuelve error si el valor del dropdown es null.
  static String? dropdownRequerido<T>(T? valor, String mensaje) {
    if (valor == null) {
      return mensaje;
    }
    return null;
  }

  // Devuelve error si la lista de selección está vacía.
  static String? listaRequerida<T>(List<T>? valor, String mensaje) {
    if (valor == null || valor.isEmpty) {
      return mensaje;
    }
    return null;
  }
}
