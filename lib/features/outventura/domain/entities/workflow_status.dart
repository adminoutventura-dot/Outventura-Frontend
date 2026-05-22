// Estado unificado para Solicitudes (Request) y Reservas (Booking).
// Equivale al enum WorkflowStatus del backend.
enum WorkflowStatus {
  pendiente,
  confirmada,
  enCurso,
  finalizada,
  cancelada;

  String get code {
    switch (this) {
      case WorkflowStatus.pendiente:
        return 'PENDING';
      case WorkflowStatus.confirmada:
        return 'CONFIRMED';
      case WorkflowStatus.enCurso:
        return 'IN_PROGRESS';
      case WorkflowStatus.finalizada:
        return 'FINISHED';
      case WorkflowStatus.cancelada:
        return 'CANCELLED';
    }
  }

  // Crea un estado a partir del código que devuelve el backend.
  static WorkflowStatus fromCode(String value) {
    for (final WorkflowStatus status in WorkflowStatus.values) {
      if (status.code == value) {
        return status;
      }
    }
    return WorkflowStatus.pendiente;
  }
}
