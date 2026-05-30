import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
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


// Traducciones para el estado del Material/Equipamiento (Ahora es una clase, evalua el 'code').
extension EstadoEquipamientoL10n on EquipmentStatus {
  String localizedLabel(AppLocalizations s) {
    switch (code) { 
      case 'AVAILABLE':
        return s.statusAvailable;
      case 'OUT_OF_STOCK':
        return s.statusOutOfStock;
      case 'MAINTENANCE':
        return s.statusMaintenance;
      case 'OUT_OF_SERVICE':
        return s.statusOutOfService;
      default:
        return s.statusAvailable; 
    }
  }
}

// Traducciones para los tipos de Categorías.
extension CategoriaActividadL10n on Category {
  String localizedLabel(AppLocalizations s) {
    switch (code.toUpperCase()) {
      case 'AQUATIC':
        return s.categoryAquatic;
      case 'SNOW':
        return s.categorySnow;
      case 'MOUNTAIN':
        return s.categoryMountain;
      case 'CAMPING':
        return s.categoryCamping;
      case 'HIKING':
        return "Hiking"; // TODO: HARDCODEADO
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