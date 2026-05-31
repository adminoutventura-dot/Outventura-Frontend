// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'Outventura';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get fieldRequired => 'Camp obligatori';

  @override
  String get invalidNumber => 'Introdueix un número vàlid';

  @override
  String get mustBeGreaterThanZero => 'Ha de ser un número major que 0';

  @override
  String get invalidValue => 'Valor invàlid';

  @override
  String get invalidEmail => 'Email no vàlid';

  @override
  String minChars(int count) {
    return 'Mínim $count caràcters';
  }

  @override
  String get selectAnOption => 'Selecciona una opció';

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get accept => 'Acceptar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Desar';

  @override
  String get create => 'Crear';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get filtersTitle => 'Filtres';

  @override
  String get clearAll => 'Netejar tot';

  @override
  String get dates => 'DATES';

  @override
  String get applyFilters => 'Aplicar filtres';

  @override
  String get from => 'Des de';

  @override
  String get to => 'Fins a';

  @override
  String get clearDates => 'Netejar dates';

  @override
  String get addImage => 'Afegir imatge';

  @override
  String get changeImage => 'Canviar imatge';

  @override
  String get loginTitle => 'OUTVENTURA';

  @override
  String get loginSubtitle => 'La teva propera aventura t\'espera';

  @override
  String get email => 'Email';

  @override
  String get password => 'Contrasenya';

  @override
  String get forgotPassword => 'Has oblidat la contrasenya?';

  @override
  String get login => 'Iniciar sessió';

  @override
  String get or => 'O';

  @override
  String get noAccount => 'Encara no tens compte? ';

  @override
  String get register => 'Registra\'t';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get personalData => 'Dades personals';

  @override
  String get name => 'Nom';

  @override
  String get surname => 'Cognoms';

  @override
  String get phoneOptional => 'Telèfon (opcional)';

  @override
  String get changePassword => 'Canviar contrasenya';

  @override
  String get newPasswordOptional => 'Nova contrasenya (opcional)';

  @override
  String get confirmNewPassword => 'Confirmar nova contrasenya';

  @override
  String get passwordRequired => 'La contrasenya és obligatòria';

  @override
  String get minSixChars => 'Mínim 6 caràcters';

  @override
  String get confirmPasswordRequired => 'Confirma la contrasenya';

  @override
  String get passwordsDoNotMatch => 'Les contrasenyes no coincideixen';

  @override
  String get tabHome => 'Inici';

  @override
  String get tabActividades => 'Activitats';

  @override
  String get tabEquipment => 'Equip';

  @override
  String get tabCalendar => 'Calendari';

  @override
  String get user => 'Usuari';

  @override
  String get profile => 'Perfil';

  @override
  String get componentCatalog => 'Catàleg de Components';

  @override
  String get preferences => 'Preferències';

  @override
  String get logout => 'Tancar sessió';

  @override
  String get adminPanel => 'Panell d\'Administració';

  @override
  String get actividadesLabel => 'ACTIVITATS';

  @override
  String get equipmentLabel => 'EQUIPAMENT';

  @override
  String get pendingLabel => 'PENDENTS';

  @override
  String get management => 'GESTIÓ';

  @override
  String get users => 'Usuaris';

  @override
  String get reservations => 'Reserves';

  @override
  String get clientPanel => 'Panell de Client';

  @override
  String get myReservations => 'LES MEVES RESERVES';

  @override
  String get myMaterialReservations => 'Material';

  @override
  String get myActivityReservations => 'Activitats';

  @override
  String greeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get clientDescription =>
      'Des d\'aquí pots crear i revisar les teves reserves.';

  @override
  String get myReservationsBtn => 'Les meves Reserves';

  @override
  String get myActivitiesBtn => 'Les meves Activitats';

  @override
  String get guideReservationsBtn => 'Reserves com a Guia';

  @override
  String get nuevasActividades => 'NOVES ACTIVITATS';

  @override
  String get noNuevasActividades => 'No hi ha activitats noves.';

  @override
  String get actividadesTitle => 'Activitats';

  @override
  String get actividadCreada => 'Activitat creada correctament.';

  @override
  String get searchByRoute => 'Cercar per ruta...';

  @override
  String get noActividadesParaCategoria =>
      'No hi ha activitats per aquesta categoria.';

  @override
  String get actividadActualizada => 'Activitat actualitzada correctament.';

  @override
  String get deleteActividad => 'Eliminar activitat';

  @override
  String deleteActividadConfirm(String route) {
    return 'Eliminar \"$route\"?';
  }

  @override
  String get requestCreatedWithReservation =>
      'Solicitud creada con reserva de materiales.';

  @override
  String get requestCreated => 'Solicitud creada correctamente.';

  @override
  String get equipmentTitle => 'Equipament';

  @override
  String get materialCreated => 'Material creat correctament.';

  @override
  String get searchByName => 'Cercar per nom...';

  @override
  String get noEquipmentForCategory =>
      'No hi ha equipaments per aquesta categoria.';

  @override
  String get materialUpdated => 'Material actualitzat correctament.';

  @override
  String get deleteEquipment => 'Eliminar equipament';

  @override
  String deleteEquipmentConfirm(String name) {
    return 'Eliminar \"$name\"?';
  }

  @override
  String get reservationCreated => 'Reserva creada correctament.';

  @override
  String get reservationManagement => 'Gestió de reserves';

  @override
  String get reservationsTitle => 'Reserves';

  @override
  String get searchByUserOrActividad => 'Cercar per usuari o activitat...';

  @override
  String get noReservations => 'No hi ha reserves';

  @override
  String get reservationNotFound => 'No s\'ha trobat la reserva associada.';

  @override
  String get reservationUpdated => 'Reserva actualitzada correctament.';

  @override
  String get calendarTitle => 'Calendari';

  @override
  String get monShort => 'dl';

  @override
  String get tueShort => 'dt';

  @override
  String get wedShort => 'dc';

  @override
  String get thuShort => 'dj';

  @override
  String get friShort => 'dv';

  @override
  String get satShort => 'ds';

  @override
  String get sunShort => 'dg';

  @override
  String reservationsBadge(int count) {
    return '$count R';
  }

  @override
  String get reservationEvent => 'Reserva';

  @override
  String get noEventsToday => 'No hi ha events avui';

  @override
  String get usersTitle => 'Usuaris';

  @override
  String get userCreated => 'Usuari creat correctament.';

  @override
  String get searchByNameEmailPhone => 'Cercar per nom, email o telèfon...';

  @override
  String get noUsers => 'No hi ha usuaris';

  @override
  String get userUpdated => 'Usuari actualitzat correctament.';

  @override
  String get deleteUser => 'Eliminar usuari';

  @override
  String deleteUserConfirm(String name) {
    return 'Eliminar a $name? Aquesta acció no es pot desfer.';
  }

  @override
  String get userDeleted => 'Usuari eliminat correctament.';

  @override
  String get reservationDetail => 'Reserva';

  @override
  String get generalInfo => 'Informació general';

  @override
  String get actividad => 'Activitat';

  @override
  String get start => 'Inici';

  @override
  String get end => 'Fi';

  @override
  String get reservedMaterial => 'Material reservat';

  @override
  String unitsShort(int count) {
    return '$count ud.';
  }

  @override
  String get damages => 'Danys';

  @override
  String get damageCharge => 'Càrrec per danys';

  @override
  String priceEur(String price) {
    return '$price €';
  }

  @override
  String damagedItems(int count) {
    return '$count danyat(s)';
  }

  @override
  String get requestDetail => 'Reserva';

  @override
  String get assignedExpert => 'Expert assignat';

  @override
  String get participants => 'Participants';

  @override
  String participantsCount(int count) {
    return '$count persones';
  }

  @override
  String get totalPrice => 'Preu total';

  @override
  String get associatedReservation => 'Reserva associada';

  @override
  String get editActividad => 'Editar activitat';

  @override
  String get nuevaActividad => 'Nova activitat';

  @override
  String get actividadSection => 'Activitat';

  @override
  String get startPoint => 'Punt d\'inici';

  @override
  String get endPoint => 'Punt d\'arribada';

  @override
  String get descriptionOptional => 'Descripció (opcional)';

  @override
  String get pricePerParticipant => 'Preu per participant (€)';

  @override
  String get datesSection => 'Dates';

  @override
  String get startTime => 'Hora inici';

  @override
  String get endTime => 'Hora fi';

  @override
  String get maxParticipants => 'Nº màxim de participants';

  @override
  String get categories => 'Categories';

  @override
  String get selectCategory => 'Selecciona una categoria';

  @override
  String get status => 'Estat';

  @override
  String get editEquipment => 'Editar equipament';

  @override
  String get newEquipment => 'Nou equipament';

  @override
  String get equipmentSection => 'Equipament';

  @override
  String get description => 'Descripció';

  @override
  String get stockSection => 'Stock';

  @override
  String get availableStock => 'Stock disponible';

  @override
  String get totalStock => 'Stock total';

  @override
  String get rates => 'Tarifes';

  @override
  String get pricePerDay => 'Preu/dia (€)';

  @override
  String get damageFee => 'Tarifa danys (€)';

  @override
  String get editUser => 'Editar usuari';

  @override
  String get newUser => 'Nou usuari';

  @override
  String get phone => 'Telèfon';

  @override
  String get role => 'Rol';

  @override
  String get activeUser => 'Usuari actiu';

  @override
  String get editReservation => 'Editar reserva';

  @override
  String get newReservation => 'Nova reserva';

  @override
  String get yourUser => 'El teu usuari';

  @override
  String get selectUser => 'Selecciona un usuari';

  @override
  String get none => 'Cap';

  @override
  String get selectActividad => 'Selecciona una activitat';

  @override
  String get reservationLines => 'Línies de reserva';

  @override
  String get add => 'Afegir';

  @override
  String get noMaterials => 'Sense materials.';

  @override
  String get totalDamages => 'Total danys';

  @override
  String get deleteReservation => 'Eliminar reserva';

  @override
  String get deleteReservationConfirm =>
      'Estàs segur que vols eliminar aquesta reserva? Aquesta acció no es pot desfer.';

  @override
  String get addAtLeastOneLine => 'Afegeix almenys una línia de reserva.';

  @override
  String get client => 'Client';

  @override
  String get selectClient => 'Selecciona un client';

  @override
  String get numberOfParticipants => 'Nombre de participants';

  @override
  String get recommendedMaterial => 'Material recomanat';

  @override
  String get addAll => 'Afegir tots';

  @override
  String get selectActividadToSeeMaterial =>
      'Selecciona una activitat per veure material recomanat.';

  @override
  String get noRecommendedMaterial =>
      'Aquesta activitat no requereix material recomanat.';

  @override
  String materialId(int id) {
    return 'Material #$id';
  }

  @override
  String get addMaterials => 'Afegir materials';

  @override
  String get reservedMaterialSection => 'Material reservat';

  @override
  String get availableEquipment => 'Material disponible';

  @override
  String get noAvailableEquipment => 'No hi ha material disponible.';

  @override
  String get expert => 'Expert';

  @override
  String get selectExpert => 'Selecciona un expert';

  @override
  String get priceSummary => 'Resum de preu';

  @override
  String actividadPrice(int count) {
    return 'Activitat (×$count)';
  }

  @override
  String get materialsRental => 'Materials (lloguer)';

  @override
  String get total => 'Total';

  @override
  String get editReservationBtn => 'Editar reserva';

  @override
  String get selectClientForReservation =>
      'Selecciona un client per reservar materials.';

  @override
  String get addAtLeastOneMaterial =>
      'Afegeix almenys un material per crear la reserva.';

  @override
  String pricePerPersonShort(String price) {
    return '$price€/persona';
  }

  @override
  String get requestBtn => 'Reservar';

  @override
  String pricePerDayShort(String price) {
    return '$price€/dia';
  }

  @override
  String stockInfo(int available, int total) {
    return '$available/$total uds';
  }

  @override
  String damageChargeAmount(String amount) {
    return 'Càrrec danys: $amount €';
  }

  @override
  String get noExpert => 'Sense expert';

  @override
  String get inactiveAccount => 'Compte inactiu';

  @override
  String get approveReservation => 'Aprovar reserva';

  @override
  String get approveReservationConfirm => 'Confirmar la reserva?';

  @override
  String get approve => 'Aprovar';

  @override
  String get reservationApproved => 'Reserva aprovada.';

  @override
  String get rejectReservation => 'Rebutjar reserva';

  @override
  String get rejectReservationConfirm => 'Rebutjar la reserva?';

  @override
  String get reject => 'Rebutjar';

  @override
  String get reservationRejected => 'Reserva rebutjada.';

  @override
  String get cancelReservation => 'Cancel·lar reserva';

  @override
  String get cancelReservationConfirm => 'Cancel·lar la reserva?';

  @override
  String get registerReturn => 'Registrar devolució';

  @override
  String get registerReturnConfirm =>
      'Confirmar la devolució de la reserva? Podràs registrar els danys des del formulari.';

  @override
  String get returnRegistered => 'Devolució registrada.';

  @override
  String get damagedUnits => 'Unitats danyades';

  @override
  String damageFeePerUnit(String price) {
    return '$price €/ud.';
  }

  @override
  String get addLine => 'Afegir línia';

  @override
  String get editLine => 'Editar línia';

  @override
  String get equipment => 'Equipament';

  @override
  String get noneSelected => 'Cap';

  @override
  String get quantity => 'Quantitat';

  @override
  String get invalidQuantity => 'Introdueix una quantitat vàlida';

  @override
  String get statusFilter => 'Estat';

  @override
  String get categoryFilter => 'Categoria';

  @override
  String get activeFilter => 'Actius';

  @override
  String get inactiveFilter => 'Inactius';

  @override
  String get roleFilter => 'Rol';

  @override
  String get statusAvailable => 'Disponible';

  @override
  String get statusNotAvailable => 'No disponible';

  @override
  String get statusPending => 'Pendent';

  @override
  String get statusConfirmed => 'Confirmada';

  @override
  String get statusInProgress => 'En curs';

  @override
  String get statusFinished => 'Finalitzada';

  @override
  String get statusCancelled => 'Cancel·lada';

  @override
  String get statusOutOfStock => 'Esgotat';

  @override
  String get statusMaintenance => 'En manteniment';

  @override
  String get statusOutOfService => 'Fora de servei';

  @override
  String get categoryAquatic => 'Aquàtic';

  @override
  String get categorySnow => 'Neu';

  @override
  String get categoryMountain => 'Muntanya';

  @override
  String get categoryCamping => 'Càmping';

  @override
  String get categoryHiking => 'Hiking';

  @override
  String get roleSuperadmin => 'Superadmin';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleExpert => 'Expert';

  @override
  String get roleUser => 'Usuari';

  @override
  String get roleGuest => 'Convidat';

  @override
  String get preferencesTitle => 'Preferències';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Castellà';

  @override
  String get english => 'Anglès';

  @override
  String get catalan => 'Català';

  @override
  String get darkTheme => 'Tema fosc';

  @override
  String get userDataSection => 'Dades d\'usuari';

  @override
  String get reservationDataSection => 'Dades de la reserva';

  @override
  String get unknownUser => 'Usuari desconegut';

  @override
  String get unknown => 'Desconegut';

  @override
  String pricePerUnitDay(String price) {
    return '$price €/ud·dia';
  }

  @override
  String get navSubtitleActivities => 'Rutes i activitats d\'aventura';

  @override
  String maxParticipantsExceeded(int max) {
    return 'Màxim $max participants permesos';
  }

  @override
  String insufficientStock(int id, int available) {
    return 'Estoc insuficient per a l\'equipament $id. Disponible: $available';
  }

  @override
  String get navSubtitleEquipment => 'Material i estoc disponible';

  @override
  String get navSubtitleUsers => 'Clients i experts';

  @override
  String get navSubtitleReservations => 'Gestió de reserves';

  @override
  String get summary => 'Resum';

  @override
  String get allGood => 'Tot en ordre';

  @override
  String get todaySection => 'AVUI';

  @override
  String get activitiesToday => 'Excursions d\'avui';

  @override
  String get reservationsToday => 'Reserves d\'avui';

  @override
  String get materialReservationsToday => 'Material avui';

  @override
  String get upcomingActivities => 'PROPERES ACTIVITATS';

  @override
  String get noUpcomingActivities => 'Sense activitats aquesta setmana';

  @override
  String get revenue => 'Ingressos';

  @override
  String get totalUsers => 'Usuaris';

  @override
  String get totalReservations => 'Reserves totals';

  @override
  String get occupancyRate => 'Ocupació';

  @override
  String get weeklyOverview => 'ACTIVITAT SETMANAL';

  @override
  String get quickActions => 'ACCESSOS RÀPIDS';

  @override
  String get recentActivity => 'ACTIVITAT RECENT';

  @override
  String get confirmed => 'Confirmades';

  @override
  String get pending => 'Pendents';

  @override
  String get inProgress => 'En curs';

  @override
  String get finished => 'Finalitzades';

  @override
  String get cancelled => 'Cancel·lades';

  @override
  String get mon => 'Dl';

  @override
  String get tue => 'Dt';

  @override
  String get wed => 'Dc';

  @override
  String get thu => 'Dj';

  @override
  String get fri => 'Dv';

  @override
  String get sat => 'Ds';

  @override
  String get sun => 'Dg';

  @override
  String get title => 'Títol';

  @override
  String get assignedGuide => 'Guia assignat';

  @override
  String get selectGuideRequired => 'Selecciona un guia obligatori';

  @override
  String get pleaseSelectGuideRequired =>
      'Si us plau, selecciona un guia obligatori';

  @override
  String get noRecommendedMaterialSelected =>
      'No hi ha material recomanat seleccionat';

  @override
  String get endTimeCannotBeBeforeStart =>
      'L\'hora de fi no pot ser anterior a la d\'inici';

  @override
  String get signIn => 'Iniciar sessió';

  @override
  String get activityDetails => 'Detalls de l\'activitat';

  @override
  String get date => 'Data';

  @override
  String get occupancy => 'Ocupació';

  @override
  String get guide => 'Guia';

  @override
  String get schedule => 'Horari';

  @override
  String get meetingPoint => 'Punt de trobada';

  @override
  String get difficulty => 'Dificultat';

  @override
  String get level => 'Nivell';

  @override
  String get selectMaterial => 'Seleccionar Material';

  @override
  String get searchByNameOrCategory => 'Cercar per nom o categoria...';

  @override
  String get noResults => 'No hi ha resultats';

  @override
  String activitiesBadge(Object count) {
    return '$count A';
  }

  @override
  String get emailAlreadyRegistered => 'L\'email ja està registrat';

  @override
  String get linkedActivity => 'Activitat vinculada';

  @override
  String get noneMaterialOnly => 'Cap (Només lloguer de material)';

  @override
  String get deleteReservationWarning =>
      '⚠️ Atenció! En eliminar aquesta reserva s\'esborraran permanentment totes les seves línies de materials associades.';

  @override
  String get endTimeMustBeAfterStart =>
      'L\'hora de fi ha de ser posterior a la d\'inici.';

  @override
  String get noCategory => 'Sense categoria';

  @override
  String get temporarilyUnavailable => 'No disponible temporalment';

  @override
  String get discontinued => 'Descatalogat';

  @override
  String get routeNotSpecified => 'Ruta no especificada';

  @override
  String get places => 'places';

  @override
  String get excursion => 'Excursió';

  @override
  String get userDetail => 'Detall d\'Usuari';

  @override
  String get active => 'Actiu';

  @override
  String get inactive => 'Inactiu';

  @override
  String get guides => 'Guies';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Següent';

  @override
  String placesCount(int count) {
    return '$count places';
  }
}
