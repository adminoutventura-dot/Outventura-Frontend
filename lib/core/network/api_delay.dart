// TEMPORAL: Esta clase entera se elimina al conectar el backend. Los Future.delayed se sustituyen por llamadas HTTP reales.
/// Delays simulados para las llamadas al backend.
/// Se sustituirán por llamadas reales a la API.
class ApiDelay {
  /// Simula la carga inicial de datos (GET).
  static const Duration carga = Duration(milliseconds: 800);

  /// Simula una acción de escritura (POST, PUT, DELETE).
  static const Duration accion = Duration(milliseconds: 500);
}
