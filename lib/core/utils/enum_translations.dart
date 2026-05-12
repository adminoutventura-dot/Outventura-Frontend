import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/l10n/app_localizations.dart';

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

extension EstadoSolicitudL10n on EstadoSolicitud {
  String localizedLabel(AppLocalizations s) => _estadoComunLabel(name, s);
}

extension EstadoReservaL10n on EstadoReserva {
  String localizedLabel(AppLocalizations s) => _estadoComunLabel(name, s);
}

extension EstadoExcursionL10n on EstadoExcursion {
  String localizedLabel(AppLocalizations s) {
    switch (this) {
      case EstadoExcursion.disponible:
        return s.statusAvailable;
      case EstadoExcursion.noDisponible:
        return s.statusNotAvailable;
    }
  }
}

extension EstadoEquipamientoL10n on EstadoEquipamiento {
  String localizedLabel(AppLocalizations s) {
    switch (this) {
      case EstadoEquipamiento.disponible:
        return s.statusAvailable;
      case EstadoEquipamiento.agotado:
        return s.statusOutOfStock;
      case EstadoEquipamiento.mantenimiento:
        return s.statusMaintenance;
      case EstadoEquipamiento.fueraDeServicio:
        return s.statusOutOfService;
    }
  }
}

extension CategoriaActividadL10n on CategoriaActividad {
  String localizedLabel(AppLocalizations s) {
    switch (this) {
      case CategoriaActividad.acuatico:
        return s.categoryAquatic;
      case CategoriaActividad.nieve:
        return s.categorySnow;
      case CategoriaActividad.montana:
        return s.categoryMountain;
      case CategoriaActividad.camping:
        return s.categoryCamping;
    }
  }
}

extension TipoRolL10n on TipoRol {
  String localizedLabel(AppLocalizations s) {
    switch (this) {
      case TipoRol.superadmin:
        return s.roleSuperadmin;
      case TipoRol.admin:
        return s.roleAdmin;
      case TipoRol.usuario:
        return s.roleUser;
      case TipoRol.invitado:
        return s.roleGuest;
    }
  }
}
