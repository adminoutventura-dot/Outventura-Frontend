// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Outventura';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get fieldRequired => 'Campo obligatorio';

  @override
  String get invalidNumber => 'Introduce un número válido';

  @override
  String get mustBeGreaterThanZero => 'Debe ser un número mayor que 0';

  @override
  String get invalidValue => 'Valor inválido';

  @override
  String get invalidEmail => 'Email no válido';

  @override
  String minChars(int count) {
    return 'Mínimo $count caracteres';
  }

  @override
  String get selectAnOption => 'Selecciona una opción';

  @override
  String get cancel => 'Cancelar';

  @override
  String get accept => 'Aceptar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Guardar';

  @override
  String get create => 'Crear';

  @override
  String get delete => 'Borrar';

  @override
  String get edit => 'Editar';

  @override
  String get filtersTitle => 'Filtros';

  @override
  String get clearAll => 'Limpiar todo';

  @override
  String get dates => 'FECHAS';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String get from => 'Desde';

  @override
  String get to => 'Hasta';

  @override
  String get clearDates => 'Limpiar fechas';

  @override
  String get addImage => 'Añadir imagen';

  @override
  String get changeImage => 'Cambiar imagen';

  @override
  String get loginTitle => 'OUTVENTURA';

  @override
  String get loginSubtitle => 'Tu próxima aventura te espera';

  @override
  String get email => 'Email';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get or => 'O';

  @override
  String get noAccount => '¿Aún no tienes cuenta? ';

  @override
  String get register => 'Regístrate';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get personalData => 'Datos personales';

  @override
  String get name => 'Nombre';

  @override
  String get surname => 'Apellidos';

  @override
  String get phoneOptional => 'Teléfono (opcional)';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get newPasswordOptional => 'Nueva contraseña (opcional)';

  @override
  String get confirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get passwordRequired => 'La contraseña es obligatoria';

  @override
  String get minSixChars => 'Mínimo 6 caracteres';

  @override
  String get confirmPasswordRequired => 'Confirma la contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabActividades => 'Actividades';

  @override
  String get tabEquipment => 'Equipamiento';

  @override
  String get tabCalendar => 'Calendario';

  @override
  String get user => 'Usuario';

  @override
  String get profile => 'Perfil';

  @override
  String get componentCatalog => 'Catálogo de Componentes';

  @override
  String get preferences => 'Preferencias';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get adminPanel => 'Panel de Administración';

  @override
  String get actividadesLabel => 'ACTIVIDADES';

  @override
  String get equipmentLabel => 'EQUIPAMIENTO';

  @override
  String get pendingLabel => 'PENDIENTES';

  @override
  String get management => 'GESTIÓN';

  @override
  String get users => 'Usuarios';

  @override
  String get reservations => 'Reservas';

  @override
  String get requests => 'Solicitudes';

  @override
  String get recentRequests => 'SOLICITUDES RECIENTES';

  @override
  String get clientPanel => 'Panel de Cliente';

  @override
  String get myReservations => 'MIS RESERVAS';

  @override
  String get myRequests => 'MIS SOLICITUDES';

  @override
  String greeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get clientDescription =>
      'Desde aquí puedes crear y revisar tus reservas y solicitudes.';

  @override
  String get myReservationsBtn => 'Mis Reservas';

  @override
  String get myRequestsBtn => 'Mis Solicitudes';

  @override
  String get noRequestsYet => 'No tienes solicitudes todavía.';

  @override
  String get nuevasActividades => 'NUEVAS ACTIVIDADES';

  @override
  String get noNuevasActividades => 'No hay actividades nuevas.';

  @override
  String get actividadesTitle => 'Actividades';

  @override
  String get actividadCreada => 'Actividad creada correctamente.';

  @override
  String get searchByRoute => 'Buscar por ruta...';

  @override
  String get noActividadesParaCategoria =>
      'No hay actividades para esta categoría.';

  @override
  String get actividadActualizada => 'Actividad actualizada correctamente.';

  @override
  String get deleteActividad => 'Eliminar actividad';

  @override
  String deleteActividadConfirm(String route) {
    return '¿Eliminar \"$route\"?';
  }

  @override
  String get requestCreatedWithReservation =>
      'Solicitud creada con reserva de materiales.';

  @override
  String get requestCreated => 'Solicitud creada correctamente.';

  @override
  String get equipmentTitle => 'Equipamiento';

  @override
  String get materialCreated => 'Material creado correctamente.';

  @override
  String get searchByName => 'Buscar por nombre...';

  @override
  String get noEquipmentForCategory =>
      'No hay equipamientos para esta categoría.';

  @override
  String get materialUpdated => 'Material actualizado correctamente.';

  @override
  String get deleteEquipment => 'Eliminar equipamiento';

  @override
  String deleteEquipmentConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get reservationCreated => 'Reserva creada correctamente.';

  @override
  String get reservationManagement => 'Gestión de reservas';

  @override
  String get reservationsTitle => 'Reservas';

  @override
  String get searchByUserOrActividad => 'Buscar por usuario o actividad...';

  @override
  String get noReservations => 'No hay reservas';

  @override
  String get reservationUpdated => 'Reserva actualizada correctamente.';

  @override
  String get requestManagement => 'Gestión de solicitudes';

  @override
  String get requestsTitle => 'Solicitudes';

  @override
  String get searchByActividadRoute => 'Buscar por actividad (ruta)...';

  @override
  String get noRequests => 'No hay solicitudes';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get monShort => 'lun';

  @override
  String get tueShort => 'mar';

  @override
  String get wedShort => 'mié';

  @override
  String get thuShort => 'jue';

  @override
  String get friShort => 'vie';

  @override
  String get satShort => 'sáb';

  @override
  String get sunShort => 'dom';

  @override
  String reservationsBadge(int count) {
    return '$count R';
  }

  @override
  String requestsBadge(int count) {
    return '$count S';
  }

  @override
  String reservationEvent(int id) {
    return 'Reserva #$id';
  }

  @override
  String requestEvent(int id) {
    return 'Solicitud #$id';
  }

  @override
  String get noEventsToday => 'No hay eventos este día';

  @override
  String get usersTitle => 'Usuarios';

  @override
  String get userCreated => 'Usuario creado correctamente.';

  @override
  String get searchByNameEmailPhone => 'Buscar por nombre, email o teléfono...';

  @override
  String get noUsers => 'No hay usuarios';

  @override
  String get userUpdated => 'Usuario actualizado correctamente.';

  @override
  String reservationDetail(int id) {
    return 'Reserva #$id';
  }

  @override
  String get generalInfo => 'Información general';

  @override
  String get actividad => 'Actividad';

  @override
  String get start => 'Inicio';

  @override
  String get end => 'Fin';

  @override
  String get reservedMaterial => 'Material reservado';

  @override
  String unitsShort(int count) {
    return '$count ud.';
  }

  @override
  String get damages => 'Daños';

  @override
  String get damageCharge => 'Cargo por daños';

  @override
  String priceEur(String price) {
    return '$price €';
  }

  @override
  String damagedItems(int count) {
    return '$count dañado(s)';
  }

  @override
  String requestDetail(int id) {
    return 'Solicitud #$id';
  }

  @override
  String get assignedExpert => 'Experto asignado';

  @override
  String get participants => 'Participantes';

  @override
  String participantsCount(int count) {
    return '$count personas';
  }

  @override
  String get totalPrice => 'Precio total';

  @override
  String get associatedReservation => 'Reserva asociada';

  @override
  String get route => 'Ruta';

  @override
  String get basePrice => 'Precio base';

  @override
  String pricePerPerson(String price) {
    return '$price €/persona';
  }

  @override
  String get requestedMaterial => 'Material solicitado';

  @override
  String get editActividad => 'Editar actividad';

  @override
  String get nuevaActividad => 'Nueva actividad';

  @override
  String get actividadSection => 'Actividad';

  @override
  String get startPoint => 'Punto de inicio';

  @override
  String get endPoint => 'Punto de llegada';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get pricePerParticipant => 'Precio por participante (€)';

  @override
  String get datesSection => 'Fechas';

  @override
  String get startTime => 'Hora inicio';

  @override
  String get endTime => 'Hora fin';

  @override
  String get maxParticipants => 'Nº máximo de participantes';

  @override
  String get categories => 'Categorías';

  @override
  String get selectCategory => 'Selecciona una categoría';

  @override
  String get status => 'Estado';

  @override
  String get editEquipment => 'Editar equipamiento';

  @override
  String get newEquipment => 'Nuevo equipamiento';

  @override
  String get equipmentSection => 'Equipamiento';

  @override
  String get description => 'Descripción';

  @override
  String get stockSection => 'Stock';

  @override
  String get availableStock => 'Stock disponible';

  @override
  String get totalStock => 'Stock total';

  @override
  String get rates => 'Tarifas';

  @override
  String get pricePerDay => 'Precio/día (€)';

  @override
  String get damageFee => 'Tarifa daños (€)';

  @override
  String get editUser => 'Editar usuario';

  @override
  String get newUser => 'Nuevo usuario';

  @override
  String get phone => 'Teléfono';

  @override
  String get role => 'Rol';

  @override
  String get activeUser => 'Usuario activo';

  @override
  String editReservation(int id) {
    return 'Editar reserva #$id';
  }

  @override
  String get newReservation => 'Nueva reserva';

  @override
  String get yourUser => 'Tu usuario';

  @override
  String get selectUser => 'Selecciona un usuario';

  @override
  String get none => 'Ninguna';

  @override
  String get selectActividad => 'Selecciona una Actividad';

  @override
  String get reservationLines => 'Líneas de reserva';

  @override
  String get add => 'Añadir';

  @override
  String get noMaterials => 'Sin materiales.';

  @override
  String get totalDamages => 'Total daños';

  @override
  String get deleteReservation => 'Borrar reserva';

  @override
  String get deleteReservationConfirm =>
      '¿Estás seguro de que quieres borrar esta reserva? Esta acción no se puede deshacer.';

  @override
  String get addAtLeastOneLine => 'Añade al menos una línea de reserva.';

  @override
  String get editRequest => 'Editar solicitud';

  @override
  String get newRequest => 'Nueva solicitud';

  @override
  String get client => 'Cliente';

  @override
  String get selectClient => 'Selecciona un cliente';

  @override
  String get numberOfParticipants => 'Número de participantes';

  @override
  String get recommendedMaterial => 'Material recomendado';

  @override
  String get addAll => 'Añadir todos';

  @override
  String get selectActividadToSeeMaterial =>
      'Selecciona una actividad para ver material recomendado.';

  @override
  String get noRecommendedMaterial =>
      'Esta actividad no requiere material recomendado.';

  @override
  String materialId(int id) {
    return 'Material #$id';
  }

  @override
  String get addMaterials => 'Añadir materiales';

  @override
  String get reservedMaterialSection => 'Material reservado';

  @override
  String get expert => 'Experto';

  @override
  String get selectExpert => 'Selecciona un experto';

  @override
  String get priceSummary => 'Resumen de precio';

  @override
  String actividadPrice(int count) {
    return 'Actividad (×$count)';
  }

  @override
  String get materialsRental => 'Materiales (alquiler)';

  @override
  String get total => 'Total';

  @override
  String get editReservationBtn => 'Editar reserva';

  @override
  String get selectClientForReservation =>
      'Selecciona un cliente para reservar materiales.';

  @override
  String get addAtLeastOneMaterial =>
      'Añade al menos un material para crear la reserva.';

  @override
  String placesCount(int count) {
    return '$count plazas';
  }

  @override
  String pricePerPersonShort(String price) {
    return '$price€/persona';
  }

  @override
  String get requestBtn => 'Solicitar';

  @override
  String pricePerDayShort(String price) {
    return '$price€/día';
  }

  @override
  String stockInfo(int available, int total) {
    return '$available/$total uds';
  }

  @override
  String damageChargeAmount(String amount) {
    return 'Cargo daños: $amount €';
  }

  @override
  String get noExpert => 'Sin experto';

  @override
  String get inactiveAccount => 'Cuenta inactiva';

  @override
  String get approveReservation => 'Aprobar reserva';

  @override
  String approveReservationConfirm(int id) {
    return '¿Confirmar la reserva #$id?';
  }

  @override
  String get approve => 'Aprobar';

  @override
  String get reservationApproved => 'Reserva aprobada.';

  @override
  String get rejectReservation => 'Rechazar reserva';

  @override
  String rejectReservationConfirm(int id) {
    return '¿Rechazar la reserva #$id?';
  }

  @override
  String get reject => 'Rechazar';

  @override
  String get reservationRejected => 'Reserva rechazada.';

  @override
  String get cancelReservation => 'Cancelar reserva';

  @override
  String cancelReservationConfirm(int id) {
    return '¿Cancelar la reserva #$id?';
  }

  @override
  String get registerReturn => 'Registrar devolución';

  @override
  String registerReturnConfirm(int id) {
    return '¿Confirmar la devolución de la reserva #$id? Podrás registrar los daños desde el formulario.';
  }

  @override
  String get returnRegistered => 'Devolución registrada.';

  @override
  String get damagedUnits => 'Unidades dañadas';

  @override
  String damageFeePerUnit(String price) {
    return '$price €/ud.';
  }

  @override
  String get addLine => 'Añadir línea';

  @override
  String get editLine => 'Editar línea';

  @override
  String get equipment => 'Equipamiento';

  @override
  String get noneSelected => 'Ninguno';

  @override
  String get quantity => 'Cantidad';

  @override
  String get invalidQuantity => 'Introduce una cantidad válida';

  @override
  String get statusFilter => 'Estado';

  @override
  String get categoryFilter => 'Categoría';

  @override
  String get acceptRequest => 'Aceptar solicitud';

  @override
  String acceptRequestConfirm(int id) {
    return '¿Aceptar la solicitud #$id?\nSe generará una actividad automáticamente.';
  }

  @override
  String get requestAccepted => 'Solicitud aceptada. Actividad generada.';

  @override
  String get materialReservationCreated =>
      'Reserva de materiales creada correctamente.';

  @override
  String get rejectRequest => 'Rechazar solicitud';

  @override
  String rejectRequestConfirm(int id) {
    return '¿Rechazar la solicitud #$id?';
  }

  @override
  String get requestRejected => 'Solicitud rechazada.';

  @override
  String get activeFilter => 'Activos';

  @override
  String get inactiveFilter => 'Inactivos';

  @override
  String get roleFilter => 'Rol';

  @override
  String get statusAvailable => 'Disponible';

  @override
  String get statusNotAvailable => 'No disponible';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusConfirmed => 'Confirmada';

  @override
  String get statusInProgress => 'En curso';

  @override
  String get statusFinished => 'Finalizada';

  @override
  String get statusCancelled => 'Cancelada';

  @override
  String get statusOutOfStock => 'Agotado';

  @override
  String get statusMaintenance => 'En mantenimiento';

  @override
  String get statusOutOfService => 'Fuera de servicio';

  @override
  String get categoryAquatic => 'Acuático';

  @override
  String get categorySnow => 'Nieve';

  @override
  String get categoryMountain => 'Montaña';

  @override
  String get categoryCamping => 'Camping';

  @override
  String get roleSuperadmin => 'Superadmin';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleExpert => 'Experto';

  @override
  String get roleUser => 'Usuario';

  @override
  String get roleGuest => 'Invitado';

  @override
  String get preferencesTitle => 'Preferencias';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get catalan => 'Català';

  @override
  String get darkTheme => 'Tema oscuro';
}
