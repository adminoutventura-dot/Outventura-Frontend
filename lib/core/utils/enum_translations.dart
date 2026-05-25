import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/l10n/app_localizations.dart';

// Traducciones para los estados de Solicitudes y Reservas (WorkflowStatus unificado).
extension WorkflowStatusL10n on WorkflowStatus {
  String localizedLabel(AppLocalizations s) {
    switch (this) {
      case WorkflowStatus.pendiente:  return s.statusPending;
      case WorkflowStatus.confirmada: return s.statusConfirmed;
      case WorkflowStatus.enCurso:    return s.statusInProgress;
      case WorkflowStatus.finalizada: return s.statusFinished;
      case WorkflowStatus.cancelada:  return s.statusCancelled;
    }
  }
}

// Traducciones para la disponibilidad de las Actividades.
extension ActivityStatusL10n on ActivityStatus {
  String localizedLabel(AppLocalizations s) {
    switch (this) {
      case ActivityStatus.disponible:
        return s.statusAvailable;
      case ActivityStatus.noDisponible:
        return s.statusNotAvailable;
    }
  }
}

// Traducciones para el estado del Material/Equipamiento.
extension EstadoEquipamientoL10n on EquipmentStatus {
  String localizedLabel(AppLocalizations s) {
    switch (this) {
      case EquipmentStatus.disponible:
        return s.statusAvailable;
      case EquipmentStatus.agotado:
        return s.statusOutOfStock;
      case EquipmentStatus.mantenimiento:
        return s.statusMaintenance;
      case EquipmentStatus.fueraDeServicio:
        return s.statusOutOfService;
    }
  }
}

// Traducciones para los tipos de Categorías.
extension CategoriaActividadL10n on Category {
  String localizedLabel(AppLocalizations s) {
    switch (code) {
      case 'AQUATIC':
        return s.categoryAquatic;
      case 'SNOW':
        return s.categorySnow;
      case 'MOUNTAIN':
        return s.categoryMountain;
      case 'CAMPING':
        return s.categoryCamping;
      default:
        return code;
    }
  }
}

// Traducciones para los Roles de los usuarios en la app.
extension TipoRolL10n on UserRole {
  String localizedLabel(AppLocalizations s) {
    switch (code) {
      case 'SUPER': return s.roleSuperadmin;
      case 'ADMIN': return s.roleAdmin;
      case 'GUIDE': return s.roleExpert;
      case 'USER':  return s.roleUser;
      default:      return s.roleGuest;
    }
  }
}