import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Outventura'**
  String get appTitle;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No description provided for @fieldRequired.
  ///
  /// In es, this message translates to:
  /// **'Campo obligatorio'**
  String get fieldRequired;

  /// No description provided for @invalidNumber.
  ///
  /// In es, this message translates to:
  /// **'Introduce un número válido'**
  String get invalidNumber;

  /// No description provided for @mustBeGreaterThanZero.
  ///
  /// In es, this message translates to:
  /// **'Debe ser un número mayor que 0'**
  String get mustBeGreaterThanZero;

  /// No description provided for @invalidValue.
  ///
  /// In es, this message translates to:
  /// **'Valor inválido'**
  String get invalidValue;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Email no válido'**
  String get invalidEmail;

  /// No description provided for @minChars.
  ///
  /// In es, this message translates to:
  /// **'Mínimo {count} caracteres'**
  String minChars(int count);

  /// No description provided for @selectAnOption.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una opción'**
  String get selectAnOption;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @filtersTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filtersTitle;

  /// No description provided for @clearAll.
  ///
  /// In es, this message translates to:
  /// **'Limpiar todo'**
  String get clearAll;

  /// No description provided for @dates.
  ///
  /// In es, this message translates to:
  /// **'FECHAS'**
  String get dates;

  /// No description provided for @applyFilters.
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get applyFilters;

  /// No description provided for @from.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get from;

  /// No description provided for @to.
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get to;

  /// No description provided for @clearDates.
  ///
  /// In es, this message translates to:
  /// **'Limpiar fechas'**
  String get clearDates;

  /// No description provided for @addImage.
  ///
  /// In es, this message translates to:
  /// **'Añadir imagen'**
  String get addImage;

  /// No description provided for @changeImage.
  ///
  /// In es, this message translates to:
  /// **'Cambiar imagen'**
  String get changeImage;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'OUTVENTURA'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu próxima aventura te espera'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get login;

  /// No description provided for @or.
  ///
  /// In es, this message translates to:
  /// **'O'**
  String get or;

  /// No description provided for @noAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Aún no tienes cuenta? '**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get register;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @personalData.
  ///
  /// In es, this message translates to:
  /// **'Datos personales'**
  String get personalData;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get name;

  /// No description provided for @surname.
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get surname;

  /// No description provided for @phoneOptional.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get phoneOptional;

  /// No description provided for @changePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePassword;

  /// No description provided for @newPasswordOptional.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña (opcional)'**
  String get newPasswordOptional;

  /// No description provided for @confirmNewPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar nueva contraseña'**
  String get confirmNewPassword;

  /// No description provided for @passwordRequired.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es obligatoria'**
  String get passwordRequired;

  /// No description provided for @minSixChars.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get minSixChars;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Confirma la contraseña'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// No description provided for @tabHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get tabHome;

  /// No description provided for @tabActividades.
  ///
  /// In es, this message translates to:
  /// **'Actividades'**
  String get tabActividades;

  /// No description provided for @tabEquipment.
  ///
  /// In es, this message translates to:
  /// **'Equipamiento'**
  String get tabEquipment;

  /// No description provided for @tabCalendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get tabCalendar;

  /// No description provided for @user.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get user;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @componentCatalog.
  ///
  /// In es, this message translates to:
  /// **'Catálogo de Componentes'**
  String get componentCatalog;

  /// No description provided for @preferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferences;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @adminPanel.
  ///
  /// In es, this message translates to:
  /// **'Panel de Administración'**
  String get adminPanel;

  /// No description provided for @actividadesLabel.
  ///
  /// In es, this message translates to:
  /// **'ACTIVIDADES'**
  String get actividadesLabel;

  /// No description provided for @equipmentLabel.
  ///
  /// In es, this message translates to:
  /// **'EQUIPAMIENTO'**
  String get equipmentLabel;

  /// No description provided for @pendingLabel.
  ///
  /// In es, this message translates to:
  /// **'PENDIENTES'**
  String get pendingLabel;

  /// No description provided for @management.
  ///
  /// In es, this message translates to:
  /// **'GESTIÓN'**
  String get management;

  /// No description provided for @users.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get users;

  /// No description provided for @reservations.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get reservations;

  /// No description provided for @requests.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes'**
  String get requests;

  /// No description provided for @recentRequests.
  ///
  /// In es, this message translates to:
  /// **'SOLICITUDES RECIENTES'**
  String get recentRequests;

  /// No description provided for @clientPanel.
  ///
  /// In es, this message translates to:
  /// **'Panel de Cliente'**
  String get clientPanel;

  /// No description provided for @myReservations.
  ///
  /// In es, this message translates to:
  /// **'MIS RESERVAS'**
  String get myReservations;

  /// No description provided for @myRequests.
  ///
  /// In es, this message translates to:
  /// **'MIS SOLICITUDES'**
  String get myRequests;

  /// No description provided for @greeting.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String greeting(String name);

  /// No description provided for @clientDescription.
  ///
  /// In es, this message translates to:
  /// **'Desde aquí puedes crear y revisar tus reservas y solicitudes.'**
  String get clientDescription;

  /// No description provided for @myReservationsBtn.
  ///
  /// In es, this message translates to:
  /// **'Mis Reservas'**
  String get myReservationsBtn;

  /// No description provided for @myRequestsBtn.
  ///
  /// In es, this message translates to:
  /// **'Mis Solicitudes'**
  String get myRequestsBtn;

  /// No description provided for @noRequestsYet.
  ///
  /// In es, this message translates to:
  /// **'No tienes solicitudes todavía.'**
  String get noRequestsYet;

  /// No description provided for @nuevasActividades.
  ///
  /// In es, this message translates to:
  /// **'NUEVAS ACTIVIDADES'**
  String get nuevasActividades;

  /// No description provided for @noNuevasActividades.
  ///
  /// In es, this message translates to:
  /// **'No hay actividades nuevas.'**
  String get noNuevasActividades;

  /// No description provided for @actividadesTitle.
  ///
  /// In es, this message translates to:
  /// **'Actividades'**
  String get actividadesTitle;

  /// No description provided for @actividadCreada.
  ///
  /// In es, this message translates to:
  /// **'Actividad creada correctamente.'**
  String get actividadCreada;

  /// No description provided for @searchByRoute.
  ///
  /// In es, this message translates to:
  /// **'Buscar por ruta...'**
  String get searchByRoute;

  /// No description provided for @noActividadesParaCategoria.
  ///
  /// In es, this message translates to:
  /// **'No hay actividades para esta categoría.'**
  String get noActividadesParaCategoria;

  /// No description provided for @actividadActualizada.
  ///
  /// In es, this message translates to:
  /// **'Actividad actualizada correctamente.'**
  String get actividadActualizada;

  /// No description provided for @deleteActividad.
  ///
  /// In es, this message translates to:
  /// **'Eliminar actividad'**
  String get deleteActividad;

  /// No description provided for @deleteActividadConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{route}\"?'**
  String deleteActividadConfirm(String route);

  /// No description provided for @requestCreatedWithReservation.
  ///
  /// In es, this message translates to:
  /// **'Solicitud creada con reserva de materiales.'**
  String get requestCreatedWithReservation;

  /// No description provided for @requestCreated.
  ///
  /// In es, this message translates to:
  /// **'Solicitud creada correctamente.'**
  String get requestCreated;

  /// No description provided for @equipmentTitle.
  ///
  /// In es, this message translates to:
  /// **'Equipamiento'**
  String get equipmentTitle;

  /// No description provided for @materialCreated.
  ///
  /// In es, this message translates to:
  /// **'Material creado correctamente.'**
  String get materialCreated;

  /// No description provided for @searchByName.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre...'**
  String get searchByName;

  /// No description provided for @noEquipmentForCategory.
  ///
  /// In es, this message translates to:
  /// **'No hay equipamientos para esta categoría.'**
  String get noEquipmentForCategory;

  /// No description provided for @materialUpdated.
  ///
  /// In es, this message translates to:
  /// **'Material actualizado correctamente.'**
  String get materialUpdated;

  /// No description provided for @deleteEquipment.
  ///
  /// In es, this message translates to:
  /// **'Eliminar equipamiento'**
  String get deleteEquipment;

  /// No description provided for @deleteEquipmentConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String deleteEquipmentConfirm(String name);

  /// No description provided for @reservationCreated.
  ///
  /// In es, this message translates to:
  /// **'Reserva creada correctamente.'**
  String get reservationCreated;

  /// No description provided for @reservationManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de reservas'**
  String get reservationManagement;

  /// No description provided for @reservationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get reservationsTitle;

  /// No description provided for @searchByUserOrActividad.
  ///
  /// In es, this message translates to:
  /// **'Buscar por usuario o actividad...'**
  String get searchByUserOrActividad;

  /// No description provided for @noReservations.
  ///
  /// In es, this message translates to:
  /// **'No hay reservas'**
  String get noReservations;

  /// No description provided for @reservationUpdated.
  ///
  /// In es, this message translates to:
  /// **'Reserva actualizada correctamente.'**
  String get reservationUpdated;

  /// No description provided for @requestManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de solicitudes'**
  String get requestManagement;

  /// No description provided for @requestsTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes'**
  String get requestsTitle;

  /// No description provided for @searchByActividadRoute.
  ///
  /// In es, this message translates to:
  /// **'Buscar por actividad (ruta)...'**
  String get searchByActividadRoute;

  /// No description provided for @noRequests.
  ///
  /// In es, this message translates to:
  /// **'No hay solicitudes'**
  String get noRequests;

  /// No description provided for @calendarTitle.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get calendarTitle;

  /// No description provided for @monShort.
  ///
  /// In es, this message translates to:
  /// **'lun'**
  String get monShort;

  /// No description provided for @tueShort.
  ///
  /// In es, this message translates to:
  /// **'mar'**
  String get tueShort;

  /// No description provided for @wedShort.
  ///
  /// In es, this message translates to:
  /// **'mié'**
  String get wedShort;

  /// No description provided for @thuShort.
  ///
  /// In es, this message translates to:
  /// **'jue'**
  String get thuShort;

  /// No description provided for @friShort.
  ///
  /// In es, this message translates to:
  /// **'vie'**
  String get friShort;

  /// No description provided for @satShort.
  ///
  /// In es, this message translates to:
  /// **'sáb'**
  String get satShort;

  /// No description provided for @sunShort.
  ///
  /// In es, this message translates to:
  /// **'dom'**
  String get sunShort;

  /// No description provided for @reservationsBadge.
  ///
  /// In es, this message translates to:
  /// **'{count} R'**
  String reservationsBadge(int count);

  /// No description provided for @requestsBadge.
  ///
  /// In es, this message translates to:
  /// **'{count} S'**
  String requestsBadge(int count);

  /// No description provided for @reservationEvent.
  ///
  /// In es, this message translates to:
  /// **'Reserva #{id}'**
  String reservationEvent(int id);

  /// No description provided for @requestEvent.
  ///
  /// In es, this message translates to:
  /// **'Solicitud #{id}'**
  String requestEvent(int id);

  /// No description provided for @noEventsToday.
  ///
  /// In es, this message translates to:
  /// **'No hay eventos este día'**
  String get noEventsToday;

  /// No description provided for @usersTitle.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get usersTitle;

  /// No description provided for @userCreated.
  ///
  /// In es, this message translates to:
  /// **'Usuario creado correctamente.'**
  String get userCreated;

  /// No description provided for @searchByNameEmailPhone.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre, email o teléfono...'**
  String get searchByNameEmailPhone;

  /// No description provided for @noUsers.
  ///
  /// In es, this message translates to:
  /// **'No hay usuarios'**
  String get noUsers;

  /// No description provided for @userUpdated.
  ///
  /// In es, this message translates to:
  /// **'Usuario actualizado correctamente.'**
  String get userUpdated;

  /// No description provided for @reservationDetail.
  ///
  /// In es, this message translates to:
  /// **'Reserva #{id}'**
  String reservationDetail(int id);

  /// No description provided for @generalInfo.
  ///
  /// In es, this message translates to:
  /// **'Información general'**
  String get generalInfo;

  /// No description provided for @actividad.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get actividad;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get start;

  /// No description provided for @end.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get end;

  /// No description provided for @reservedMaterial.
  ///
  /// In es, this message translates to:
  /// **'Material reservado'**
  String get reservedMaterial;

  /// No description provided for @unitsShort.
  ///
  /// In es, this message translates to:
  /// **'{count} ud.'**
  String unitsShort(int count);

  /// No description provided for @damages.
  ///
  /// In es, this message translates to:
  /// **'Daños'**
  String get damages;

  /// No description provided for @damageCharge.
  ///
  /// In es, this message translates to:
  /// **'Cargo por daños'**
  String get damageCharge;

  /// No description provided for @priceEur.
  ///
  /// In es, this message translates to:
  /// **'{price} €'**
  String priceEur(String price);

  /// No description provided for @damagedItems.
  ///
  /// In es, this message translates to:
  /// **'{count} dañado(s)'**
  String damagedItems(int count);

  /// No description provided for @requestDetail.
  ///
  /// In es, this message translates to:
  /// **'Solicitud #{id}'**
  String requestDetail(int id);

  /// No description provided for @assignedExpert.
  ///
  /// In es, this message translates to:
  /// **'Experto asignado'**
  String get assignedExpert;

  /// No description provided for @participants.
  ///
  /// In es, this message translates to:
  /// **'Participantes'**
  String get participants;

  /// No description provided for @participantsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} personas'**
  String participantsCount(int count);

  /// No description provided for @totalPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio total'**
  String get totalPrice;

  /// No description provided for @associatedReservation.
  ///
  /// In es, this message translates to:
  /// **'Reserva asociada'**
  String get associatedReservation;

  /// No description provided for @route.
  ///
  /// In es, this message translates to:
  /// **'Ruta'**
  String get route;

  /// No description provided for @basePrice.
  ///
  /// In es, this message translates to:
  /// **'Precio base'**
  String get basePrice;

  /// No description provided for @pricePerPerson.
  ///
  /// In es, this message translates to:
  /// **'{price} €/persona'**
  String pricePerPerson(String price);

  /// No description provided for @requestedMaterial.
  ///
  /// In es, this message translates to:
  /// **'Material solicitado'**
  String get requestedMaterial;

  /// No description provided for @editActividad.
  ///
  /// In es, this message translates to:
  /// **'Editar actividad'**
  String get editActividad;

  /// No description provided for @nuevaActividad.
  ///
  /// In es, this message translates to:
  /// **'Nueva actividad'**
  String get nuevaActividad;

  /// No description provided for @actividadSection.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get actividadSection;

  /// No description provided for @startPoint.
  ///
  /// In es, this message translates to:
  /// **'Punto de inicio'**
  String get startPoint;

  /// No description provided for @endPoint.
  ///
  /// In es, this message translates to:
  /// **'Punto de llegada'**
  String get endPoint;

  /// No description provided for @descriptionOptional.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get descriptionOptional;

  /// No description provided for @pricePerParticipant.
  ///
  /// In es, this message translates to:
  /// **'Precio por participante (€)'**
  String get pricePerParticipant;

  /// No description provided for @datesSection.
  ///
  /// In es, this message translates to:
  /// **'Fechas'**
  String get datesSection;

  /// No description provided for @startTime.
  ///
  /// In es, this message translates to:
  /// **'Hora inicio'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In es, this message translates to:
  /// **'Hora fin'**
  String get endTime;

  /// No description provided for @maxParticipants.
  ///
  /// In es, this message translates to:
  /// **'Nº máximo de participantes'**
  String get maxParticipants;

  /// No description provided for @categories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get categories;

  /// No description provided for @selectCategory.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una categoría'**
  String get selectCategory;

  /// No description provided for @status.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get status;

  /// No description provided for @editEquipment.
  ///
  /// In es, this message translates to:
  /// **'Editar equipamiento'**
  String get editEquipment;

  /// No description provided for @newEquipment.
  ///
  /// In es, this message translates to:
  /// **'Nuevo equipamiento'**
  String get newEquipment;

  /// No description provided for @equipmentSection.
  ///
  /// In es, this message translates to:
  /// **'Equipamiento'**
  String get equipmentSection;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @stockSection.
  ///
  /// In es, this message translates to:
  /// **'Stock'**
  String get stockSection;

  /// No description provided for @availableStock.
  ///
  /// In es, this message translates to:
  /// **'Stock disponible'**
  String get availableStock;

  /// No description provided for @totalStock.
  ///
  /// In es, this message translates to:
  /// **'Stock total'**
  String get totalStock;

  /// No description provided for @rates.
  ///
  /// In es, this message translates to:
  /// **'Tarifas'**
  String get rates;

  /// No description provided for @pricePerDay.
  ///
  /// In es, this message translates to:
  /// **'Precio/día (€)'**
  String get pricePerDay;

  /// No description provided for @damageFee.
  ///
  /// In es, this message translates to:
  /// **'Tarifa daños (€)'**
  String get damageFee;

  /// No description provided for @editUser.
  ///
  /// In es, this message translates to:
  /// **'Editar usuario'**
  String get editUser;

  /// No description provided for @newUser.
  ///
  /// In es, this message translates to:
  /// **'Nuevo usuario'**
  String get newUser;

  /// No description provided for @phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phone;

  /// No description provided for @role.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get role;

  /// No description provided for @activeUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario activo'**
  String get activeUser;

  /// No description provided for @editReservation.
  ///
  /// In es, this message translates to:
  /// **'Editar reserva #{id}'**
  String editReservation(int id);

  /// No description provided for @newReservation.
  ///
  /// In es, this message translates to:
  /// **'Nueva reserva'**
  String get newReservation;

  /// No description provided for @yourUser.
  ///
  /// In es, this message translates to:
  /// **'Tu usuario'**
  String get yourUser;

  /// No description provided for @selectUser.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un usuario'**
  String get selectUser;

  /// No description provided for @none.
  ///
  /// In es, this message translates to:
  /// **'Ninguna'**
  String get none;

  /// No description provided for @selectActividad.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una Actividad'**
  String get selectActividad;

  /// No description provided for @reservationLines.
  ///
  /// In es, this message translates to:
  /// **'Líneas de reserva'**
  String get reservationLines;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get add;

  /// No description provided for @noMaterials.
  ///
  /// In es, this message translates to:
  /// **'Sin materiales.'**
  String get noMaterials;

  /// No description provided for @totalDamages.
  ///
  /// In es, this message translates to:
  /// **'Total daños'**
  String get totalDamages;

  /// No description provided for @deleteReservation.
  ///
  /// In es, this message translates to:
  /// **'Borrar reserva'**
  String get deleteReservation;

  /// No description provided for @deleteReservationConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres borrar esta reserva? Esta acción no se puede deshacer.'**
  String get deleteReservationConfirm;

  /// No description provided for @addAtLeastOneLine.
  ///
  /// In es, this message translates to:
  /// **'Añade al menos una línea de reserva.'**
  String get addAtLeastOneLine;

  /// No description provided for @editRequest.
  ///
  /// In es, this message translates to:
  /// **'Editar solicitud'**
  String get editRequest;

  /// No description provided for @newRequest.
  ///
  /// In es, this message translates to:
  /// **'Nueva solicitud'**
  String get newRequest;

  /// No description provided for @client.
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get client;

  /// No description provided for @selectClient.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un cliente'**
  String get selectClient;

  /// No description provided for @numberOfParticipants.
  ///
  /// In es, this message translates to:
  /// **'Número de participantes'**
  String get numberOfParticipants;

  /// No description provided for @recommendedMaterial.
  ///
  /// In es, this message translates to:
  /// **'Material recomendado'**
  String get recommendedMaterial;

  /// No description provided for @addAll.
  ///
  /// In es, this message translates to:
  /// **'Añadir todos'**
  String get addAll;

  /// No description provided for @selectActividadToSeeMaterial.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una actividad para ver material recomendado.'**
  String get selectActividadToSeeMaterial;

  /// No description provided for @noRecommendedMaterial.
  ///
  /// In es, this message translates to:
  /// **'Esta actividad no requiere material recomendado.'**
  String get noRecommendedMaterial;

  /// No description provided for @materialId.
  ///
  /// In es, this message translates to:
  /// **'Material #{id}'**
  String materialId(int id);

  /// No description provided for @addMaterials.
  ///
  /// In es, this message translates to:
  /// **'Añadir materiales'**
  String get addMaterials;

  /// No description provided for @reservedMaterialSection.
  ///
  /// In es, this message translates to:
  /// **'Material reservado'**
  String get reservedMaterialSection;

  /// No description provided for @expert.
  ///
  /// In es, this message translates to:
  /// **'Experto'**
  String get expert;

  /// No description provided for @selectExpert.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un experto'**
  String get selectExpert;

  /// No description provided for @priceSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de precio'**
  String get priceSummary;

  /// No description provided for @actividadPrice.
  ///
  /// In es, this message translates to:
  /// **'Actividad (×{count})'**
  String actividadPrice(int count);

  /// No description provided for @materialsRental.
  ///
  /// In es, this message translates to:
  /// **'Materiales (alquiler)'**
  String get materialsRental;

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @editReservationBtn.
  ///
  /// In es, this message translates to:
  /// **'Editar reserva'**
  String get editReservationBtn;

  /// No description provided for @selectClientForReservation.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un cliente para reservar materiales.'**
  String get selectClientForReservation;

  /// No description provided for @addAtLeastOneMaterial.
  ///
  /// In es, this message translates to:
  /// **'Añade al menos un material para crear la reserva.'**
  String get addAtLeastOneMaterial;

  /// No description provided for @placesCount.
  ///
  /// In es, this message translates to:
  /// **'{count} plazas'**
  String placesCount(int count);

  /// No description provided for @pricePerPersonShort.
  ///
  /// In es, this message translates to:
  /// **'{price}€/persona'**
  String pricePerPersonShort(String price);

  /// No description provided for @requestBtn.
  ///
  /// In es, this message translates to:
  /// **'Solicitar'**
  String get requestBtn;

  /// No description provided for @pricePerDayShort.
  ///
  /// In es, this message translates to:
  /// **'{price}€/día'**
  String pricePerDayShort(String price);

  /// No description provided for @stockInfo.
  ///
  /// In es, this message translates to:
  /// **'{available}/{total} uds'**
  String stockInfo(int available, int total);

  /// No description provided for @damageChargeAmount.
  ///
  /// In es, this message translates to:
  /// **'Cargo daños: {amount} €'**
  String damageChargeAmount(String amount);

  /// No description provided for @noExpert.
  ///
  /// In es, this message translates to:
  /// **'Sin experto'**
  String get noExpert;

  /// No description provided for @inactiveAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta inactiva'**
  String get inactiveAccount;

  /// No description provided for @approveReservation.
  ///
  /// In es, this message translates to:
  /// **'Aprobar reserva'**
  String get approveReservation;

  /// No description provided for @approveReservationConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Confirmar la reserva #{id}?'**
  String approveReservationConfirm(int id);

  /// No description provided for @approve.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get approve;

  /// No description provided for @reservationApproved.
  ///
  /// In es, this message translates to:
  /// **'Reserva aprobada.'**
  String get reservationApproved;

  /// No description provided for @rejectReservation.
  ///
  /// In es, this message translates to:
  /// **'Rechazar reserva'**
  String get rejectReservation;

  /// No description provided for @rejectReservationConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Rechazar la reserva #{id}?'**
  String rejectReservationConfirm(int id);

  /// No description provided for @reject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get reject;

  /// No description provided for @reservationRejected.
  ///
  /// In es, this message translates to:
  /// **'Reserva rechazada.'**
  String get reservationRejected;

  /// No description provided for @cancelReservation.
  ///
  /// In es, this message translates to:
  /// **'Cancelar reserva'**
  String get cancelReservation;

  /// No description provided for @cancelReservationConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar la reserva #{id}?'**
  String cancelReservationConfirm(int id);

  /// No description provided for @registerReturn.
  ///
  /// In es, this message translates to:
  /// **'Registrar devolución'**
  String get registerReturn;

  /// No description provided for @registerReturnConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Confirmar la devolución de la reserva #{id}? Podrás registrar los daños desde el formulario.'**
  String registerReturnConfirm(int id);

  /// No description provided for @returnRegistered.
  ///
  /// In es, this message translates to:
  /// **'Devolución registrada.'**
  String get returnRegistered;

  /// No description provided for @damagedUnits.
  ///
  /// In es, this message translates to:
  /// **'Unidades dañadas'**
  String get damagedUnits;

  /// No description provided for @damageFeePerUnit.
  ///
  /// In es, this message translates to:
  /// **'{price} €/ud.'**
  String damageFeePerUnit(String price);

  /// No description provided for @addLine.
  ///
  /// In es, this message translates to:
  /// **'Añadir línea'**
  String get addLine;

  /// No description provided for @editLine.
  ///
  /// In es, this message translates to:
  /// **'Editar línea'**
  String get editLine;

  /// No description provided for @equipment.
  ///
  /// In es, this message translates to:
  /// **'Equipamiento'**
  String get equipment;

  /// No description provided for @noneSelected.
  ///
  /// In es, this message translates to:
  /// **'Ninguno'**
  String get noneSelected;

  /// No description provided for @quantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get quantity;

  /// No description provided for @invalidQuantity.
  ///
  /// In es, this message translates to:
  /// **'Introduce una cantidad válida'**
  String get invalidQuantity;

  /// No description provided for @statusFilter.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get statusFilter;

  /// No description provided for @categoryFilter.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get categoryFilter;

  /// No description provided for @acceptRequest.
  ///
  /// In es, this message translates to:
  /// **'Aceptar solicitud'**
  String get acceptRequest;

  /// No description provided for @acceptRequestConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Aceptar la solicitud #{id}?\nSe generará una actividad automáticamente.'**
  String acceptRequestConfirm(int id);

  /// No description provided for @requestAccepted.
  ///
  /// In es, this message translates to:
  /// **'Solicitud aceptada. Actividad generada.'**
  String get requestAccepted;

  /// No description provided for @materialReservationCreated.
  ///
  /// In es, this message translates to:
  /// **'Reserva de materiales creada correctamente.'**
  String get materialReservationCreated;

  /// No description provided for @rejectRequest.
  ///
  /// In es, this message translates to:
  /// **'Rechazar solicitud'**
  String get rejectRequest;

  /// No description provided for @rejectRequestConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Rechazar la solicitud #{id}?'**
  String rejectRequestConfirm(int id);

  /// No description provided for @requestRejected.
  ///
  /// In es, this message translates to:
  /// **'Solicitud rechazada.'**
  String get requestRejected;

  /// No description provided for @activeFilter.
  ///
  /// In es, this message translates to:
  /// **'Activos'**
  String get activeFilter;

  /// No description provided for @inactiveFilter.
  ///
  /// In es, this message translates to:
  /// **'Inactivos'**
  String get inactiveFilter;

  /// No description provided for @roleFilter.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get roleFilter;

  /// No description provided for @statusAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get statusAvailable;

  /// No description provided for @statusNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get statusNotAvailable;

  /// No description provided for @statusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get statusConfirmed;

  /// No description provided for @statusInProgress.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get statusInProgress;

  /// No description provided for @statusFinished.
  ///
  /// In es, this message translates to:
  /// **'Finalizada'**
  String get statusFinished;

  /// No description provided for @statusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get statusCancelled;

  /// No description provided for @statusOutOfStock.
  ///
  /// In es, this message translates to:
  /// **'Agotado'**
  String get statusOutOfStock;

  /// No description provided for @statusMaintenance.
  ///
  /// In es, this message translates to:
  /// **'En mantenimiento'**
  String get statusMaintenance;

  /// No description provided for @statusOutOfService.
  ///
  /// In es, this message translates to:
  /// **'Fuera de servicio'**
  String get statusOutOfService;

  /// No description provided for @categoryAquatic.
  ///
  /// In es, this message translates to:
  /// **'Acuático'**
  String get categoryAquatic;

  /// No description provided for @categorySnow.
  ///
  /// In es, this message translates to:
  /// **'Nieve'**
  String get categorySnow;

  /// No description provided for @categoryMountain.
  ///
  /// In es, this message translates to:
  /// **'Montaña'**
  String get categoryMountain;

  /// No description provided for @categoryCamping.
  ///
  /// In es, this message translates to:
  /// **'Camping'**
  String get categoryCamping;

  /// No description provided for @roleSuperadmin.
  ///
  /// In es, this message translates to:
  /// **'Superadmin'**
  String get roleSuperadmin;

  /// No description provided for @roleAdmin.
  ///
  /// In es, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleExpert.
  ///
  /// In es, this message translates to:
  /// **'Experto'**
  String get roleExpert;

  /// No description provided for @roleUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get roleUser;

  /// No description provided for @roleGuest.
  ///
  /// In es, this message translates to:
  /// **'Invitado'**
  String get roleGuest;

  /// No description provided for @preferencesTitle.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferencesTitle;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// No description provided for @catalan.
  ///
  /// In es, this message translates to:
  /// **'Català'**
  String get catalan;

  /// No description provided for @darkTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema oscuro'**
  String get darkTheme;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
