import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/l10n/app_localizations.dart';

// Función para traducir los estados que comparten las Reservas y las Solicitudes.
String _estadoComunLabel(String name, AppLocalizations s) {
  switch (name) {
    case 'pendiente':  
      return s.statusPending;
    case 'confirmada': 
      return s.statusConfirmed;
    case 'enCurso':    
      return s.statusInProgress;
    case 'finalizada': 
      return s.statusFinished;
    case 'cancelada':  
      return s.statusCancelled;
    default:          
      return 'Unknown estado: $name';
  }
}

// Traducciones para los estados de una Solicitud.
extension EstadoSolicitudL10n on RequestStatus {
  String localizedLabel(AppLocalizations s) => _estadoComunLabel(name, s);
}

// Traducciones para los estados de una Reserva.
extension EstadoReservaL10n on BookingStatus {
  String localizedLabel(AppLocalizations s) => _estadoComunLabel(name, s);
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
    switch (this) {
      case Category.acuatico:
        return s.categoryAquatic;
      case Category.nieve:
        return s.categorySnow;
      case Category.montana:
        return s.categoryMountain;
      case Category.camping:
        return s.categoryCamping;
    }
  }
}

// Traducciones para los Roles de los usuarios en la app.
extension TipoRolL10n on UserRole {
  String localizedLabel(AppLocalizations s) {
    switch (this) {
      case UserRole.superadmin:
        return s.roleSuperadmin;
      case UserRole.admin:
        return s.roleAdmin;
      case UserRole.usuario:
        return s.roleUser;
      case UserRole.invitado:
        return s.roleGuest;
    }
  }
}