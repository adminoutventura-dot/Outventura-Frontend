// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Outventura';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get fieldRequired => 'Required field';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get mustBeGreaterThanZero => 'Must be greater than 0';

  @override
  String get invalidValue => 'Invalid value';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String minChars(int count) {
    return 'Minimum $count characters';
  }

  @override
  String get selectAnOption => 'Select an option';

  @override
  String get cancel => 'Cancel';

  @override
  String get accept => 'Accept';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get clearAll => 'Clear all';

  @override
  String get dates => 'DATES';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get clearDates => 'Clear dates';

  @override
  String get addImage => 'Add image';

  @override
  String get changeImage => 'Change image';

  @override
  String get loginTitle => 'OUTVENTURA';

  @override
  String get loginSubtitle => 'Your next adventure awaits';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get login => 'Log in';

  @override
  String get or => 'Or';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Sign up';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get personalData => 'Personal data';

  @override
  String get name => 'Name';

  @override
  String get surname => 'Surname';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get changePassword => 'Change password';

  @override
  String get newPasswordOptional => 'New password (optional)';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get minSixChars => 'Minimum 6 characters';

  @override
  String get confirmPasswordRequired => 'Confirm the password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get tabHome => 'Home';

  @override
  String get tabActividades => 'Activities';

  @override
  String get tabEquipment => 'Equipment';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get user => 'User';

  @override
  String get profile => 'Profile';

  @override
  String get componentCatalog => 'Component Catalog';

  @override
  String get preferences => 'Preferences';

  @override
  String get logout => 'Log out';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get actividadesLabel => 'ACTIVITIES';

  @override
  String get equipmentLabel => 'EQUIPMENT';

  @override
  String get pendingLabel => 'PENDING';

  @override
  String get management => 'MANAGEMENT';

  @override
  String get users => 'Users';

  @override
  String get reservations => 'Reservations';

  @override
  String get requests => 'Requests';

  @override
  String get recentRequests => 'RECENT REQUESTS';

  @override
  String get clientPanel => 'Client Panel';

  @override
  String get myReservations => 'MY RESERVATIONS';

  @override
  String get myRequests => 'MY REQUESTS';

  @override
  String greeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get clientDescription =>
      'From here you can create and review your reservations and requests.';

  @override
  String get myReservationsBtn => 'My Reservations';

  @override
  String get myRequestsBtn => 'My Requests';

  @override
  String get noRequestsYet => 'You have no requests yet.';

  @override
  String get nuevasActividades => 'NEW ACTIVITIES';

  @override
  String get noNuevasActividades => 'No new activities.';

  @override
  String get actividadesTitle => 'Activities';

  @override
  String get actividadCreada => 'Activity created successfully.';

  @override
  String get searchByRoute => 'Search by route...';

  @override
  String get noActividadesParaCategoria => 'No activities for this category.';

  @override
  String get actividadActualizada => 'Activity updated successfully.';

  @override
  String get deleteActividad => 'Delete activity';

  @override
  String deleteActividadConfirm(String route) {
    return 'Delete \"$route\"?';
  }

  @override
  String get requestCreatedWithReservation =>
      'Request created with material reservation.';

  @override
  String get requestCreated => 'Request created successfully.';

  @override
  String get equipmentTitle => 'Equipment';

  @override
  String get materialCreated => 'Material created successfully.';

  @override
  String get searchByName => 'Search by name...';

  @override
  String get noEquipmentForCategory => 'No equipment for this category.';

  @override
  String get materialUpdated => 'Material updated successfully.';

  @override
  String get deleteEquipment => 'Delete equipment';

  @override
  String deleteEquipmentConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get reservationCreated => 'Reservation created successfully.';

  @override
  String get reservationManagement => 'Reservation management';

  @override
  String get reservationsTitle => 'Reservations';

  @override
  String get searchByUserOrActividad => 'Search by user or activity...';

  @override
  String get noReservations => 'No reservations';

  @override
  String get reservationUpdated => 'Reservation updated successfully.';

  @override
  String get requestManagement => 'Request management';

  @override
  String get requestsTitle => 'Requests';

  @override
  String get searchByActividadRoute => 'Search by activity (route)...';

  @override
  String get noRequests => 'No requests';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get monShort => 'Mon';

  @override
  String get tueShort => 'Tue';

  @override
  String get wedShort => 'Wed';

  @override
  String get thuShort => 'Thu';

  @override
  String get friShort => 'Fri';

  @override
  String get satShort => 'Sat';

  @override
  String get sunShort => 'Sun';

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
    return 'Reservation #$id';
  }

  @override
  String requestEvent(int id) {
    return 'Request #$id';
  }

  @override
  String get noEventsToday => 'No events today';

  @override
  String get usersTitle => 'Users';

  @override
  String get userCreated => 'User created successfully.';

  @override
  String get searchByNameEmailPhone => 'Search by name, email or phone...';

  @override
  String get noUsers => 'No users';

  @override
  String get userUpdated => 'User updated successfully.';

  @override
  String reservationDetail(int id) {
    return 'Reservation #$id';
  }

  @override
  String get generalInfo => 'General information';

  @override
  String get actividad => 'Activity';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get reservedMaterial => 'Reserved material';

  @override
  String unitsShort(int count) {
    return '$count units';
  }

  @override
  String get damages => 'Damages';

  @override
  String get damageCharge => 'Damage charge';

  @override
  String priceEur(String price) {
    return '$price €';
  }

  @override
  String damagedItems(int count) {
    return '$count damaged';
  }

  @override
  String requestDetail(int id) {
    return 'Request #$id';
  }

  @override
  String get assignedExpert => 'Assigned expert';

  @override
  String get participants => 'Participants';

  @override
  String participantsCount(int count) {
    return '$count people';
  }

  @override
  String get totalPrice => 'Total price';

  @override
  String get associatedReservation => 'Associated reservation';

  @override
  String get route => 'Route';

  @override
  String get basePrice => 'Base price';

  @override
  String pricePerPerson(String price) {
    return '$price €/person';
  }

  @override
  String get requestedMaterial => 'Requested material';

  @override
  String get editActividad => 'Edit activity';

  @override
  String get nuevaActividad => 'New activity';

  @override
  String get actividadSection => 'Activity';

  @override
  String get startPoint => 'Start point';

  @override
  String get endPoint => 'End point';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get pricePerParticipant => 'Price per participant (€)';

  @override
  String get datesSection => 'Dates';

  @override
  String get startTime => 'Start time';

  @override
  String get endTime => 'End time';

  @override
  String get maxParticipants => 'Max participants';

  @override
  String get categories => 'Categories';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get status => 'Status';

  @override
  String get editEquipment => 'Edit equipment';

  @override
  String get newEquipment => 'New equipment';

  @override
  String get equipmentSection => 'Equipment';

  @override
  String get description => 'Description';

  @override
  String get stockSection => 'Stock';

  @override
  String get availableStock => 'Available stock';

  @override
  String get totalStock => 'Total stock';

  @override
  String get rates => 'Rates';

  @override
  String get pricePerDay => 'Price/day (€)';

  @override
  String get damageFee => 'Damage fee (€)';

  @override
  String get editUser => 'Edit user';

  @override
  String get newUser => 'New user';

  @override
  String get phone => 'Phone';

  @override
  String get role => 'Role';

  @override
  String get activeUser => 'Active user';

  @override
  String editReservation(int id) {
    return 'Edit reservation #$id';
  }

  @override
  String get newReservation => 'New reservation';

  @override
  String get yourUser => 'Your user';

  @override
  String get selectUser => 'Select a user';

  @override
  String get none => 'None';

  @override
  String get selectActividad => 'Select an activity';

  @override
  String get reservationLines => 'Reservation lines';

  @override
  String get add => 'Add';

  @override
  String get noMaterials => 'No materials.';

  @override
  String get totalDamages => 'Total damages';

  @override
  String get deleteReservation => 'Delete reservation';

  @override
  String get deleteReservationConfirm =>
      'Are you sure you want to delete this reservation? This action cannot be undone.';

  @override
  String get addAtLeastOneLine => 'Add at least one reservation line.';

  @override
  String get editRequest => 'Edit request';

  @override
  String get newRequest => 'New request';

  @override
  String get client => 'Client';

  @override
  String get selectClient => 'Select a client';

  @override
  String get numberOfParticipants => 'Number of participants';

  @override
  String get recommendedMaterial => 'Recommended material';

  @override
  String get addAll => 'Add all';

  @override
  String get selectActividadToSeeMaterial =>
      'Select an activity to see recommended material.';

  @override
  String get noRecommendedMaterial =>
      'This activity requires no recommended material.';

  @override
  String materialId(int id) {
    return 'Material #$id';
  }

  @override
  String get addMaterials => 'Add materials';

  @override
  String get reservedMaterialSection => 'Reserved material';

  @override
  String get expert => 'Expert';

  @override
  String get selectExpert => 'Select an expert';

  @override
  String get priceSummary => 'Price summary';

  @override
  String actividadPrice(int count) {
    return 'Activity (×$count)';
  }

  @override
  String get materialsRental => 'Materials (rental)';

  @override
  String get total => 'Total';

  @override
  String get editReservationBtn => 'Edit reservation';

  @override
  String get selectClientForReservation =>
      'Select a client to reserve materials.';

  @override
  String get addAtLeastOneMaterial =>
      'Add at least one material to create the reservation.';

  @override
  String placesCount(int count) {
    return '$count places';
  }

  @override
  String pricePerPersonShort(String price) {
    return '$price€/person';
  }

  @override
  String get requestBtn => 'Request';

  @override
  String pricePerDayShort(String price) {
    return '$price€/day';
  }

  @override
  String stockInfo(int available, int total) {
    return '$available/$total units';
  }

  @override
  String damageChargeAmount(String amount) {
    return 'Damage charge: $amount €';
  }

  @override
  String get noExpert => 'No expert';

  @override
  String get inactiveAccount => 'Inactive account';

  @override
  String get approveReservation => 'Approve reservation';

  @override
  String approveReservationConfirm(int id) {
    return 'Confirm reservation #$id?';
  }

  @override
  String get approve => 'Approve';

  @override
  String get reservationApproved => 'Reservation approved.';

  @override
  String get rejectReservation => 'Reject reservation';

  @override
  String rejectReservationConfirm(int id) {
    return 'Reject reservation #$id?';
  }

  @override
  String get reject => 'Reject';

  @override
  String get reservationRejected => 'Reservation rejected.';

  @override
  String get cancelReservation => 'Cancel reservation';

  @override
  String cancelReservationConfirm(int id) {
    return 'Cancel reservation #$id?';
  }

  @override
  String get registerReturn => 'Register return';

  @override
  String registerReturnConfirm(int id) {
    return 'Confirm the return of reservation #$id? You can register damages from the form.';
  }

  @override
  String get returnRegistered => 'Return registered.';

  @override
  String get damagedUnits => 'Damaged units';

  @override
  String damageFeePerUnit(String price) {
    return '$price €/unit';
  }

  @override
  String get addLine => 'Add line';

  @override
  String get editLine => 'Edit line';

  @override
  String get equipment => 'Equipment';

  @override
  String get noneSelected => 'None';

  @override
  String get quantity => 'Quantity';

  @override
  String get invalidQuantity => 'Enter a valid quantity';

  @override
  String get statusFilter => 'Status';

  @override
  String get categoryFilter => 'Category';

  @override
  String get acceptRequest => 'Accept request';

  @override
  String acceptRequestConfirm(int id) {
    return 'Accept request #$id?\nAn activity will be generated automatically.';
  }

  @override
  String get requestAccepted => 'Request accepted. Activity generated.';

  @override
  String get materialReservationCreated =>
      'Material reservation created successfully.';

  @override
  String get rejectRequest => 'Reject request';

  @override
  String rejectRequestConfirm(int id) {
    return 'Reject request #$id?';
  }

  @override
  String get requestRejected => 'Request rejected.';

  @override
  String get activeFilter => 'Active';

  @override
  String get inactiveFilter => 'Inactive';

  @override
  String get roleFilter => 'Role';

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusNotAvailable => 'Not available';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusFinished => 'Finished';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusOutOfStock => 'Out of stock';

  @override
  String get statusMaintenance => 'Under maintenance';

  @override
  String get statusOutOfService => 'Out of service';

  @override
  String get categoryAquatic => 'Aquatic';

  @override
  String get categorySnow => 'Snow';

  @override
  String get categoryMountain => 'Mountain';

  @override
  String get categoryCamping => 'Camping';

  @override
  String get roleSuperadmin => 'Superadmin';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleExpert => 'Expert';

  @override
  String get roleUser => 'User';

  @override
  String get roleGuest => 'Guest';

  @override
  String get preferencesTitle => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get catalan => 'Catalan';

  @override
  String get darkTheme => 'Dark theme';
}
