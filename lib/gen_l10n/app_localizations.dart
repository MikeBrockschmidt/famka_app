import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @addOrJoinGroupRequiredFieldError.
  ///
  /// In de, this message translates to:
  /// **'Bitte füllen Sie alle erforderlichen Felder aus.'**
  String get addOrJoinGroupRequiredFieldError;

  /// No description provided for @addOrJoinGroupTitle.
  ///
  /// In de, this message translates to:
  /// **'Gruppe erstellen'**
  String get addOrJoinGroupTitle;

  /// No description provided for @addOrJoinGroupCreateHint.
  ///
  /// In de, this message translates to:
  /// **'Gruppenname eingeben'**
  String get addOrJoinGroupCreateHint;

  /// No description provided for @addOrJoinGroupGroupNameEmpty.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Gruppennamen ein.'**
  String get addOrJoinGroupGroupNameEmpty;

  /// No description provided for @addOrJoinGroupDescriptionHint.
  ///
  /// In de, this message translates to:
  /// **'Eine kurze Beschreibung Ihrer Gruppe'**
  String get addOrJoinGroupDescriptionHint;

  /// No description provided for @addOrJoinGroupLocationHint.
  ///
  /// In de, this message translates to:
  /// **'Wo befindet sich Ihre Gruppe?'**
  String get addOrJoinGroupLocationHint;

  /// No description provided for @addOrJoinGroupCreateButton.
  ///
  /// In de, this message translates to:
  /// **'Gruppe erstellen'**
  String get addOrJoinGroupCreateButton;

  /// No description provided for @addPassiveMemberTitle.
  ///
  /// In de, this message translates to:
  /// **'Passives Mitglied hinzufügen'**
  String get addPassiveMemberTitle;

  /// No description provided for @addPassiveMemberFirstNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Vorname'**
  String get addPassiveMemberFirstNameLabel;

  /// No description provided for @addPassiveMemberLastNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Nachname'**
  String get addPassiveMemberLastNameLabel;

  /// No description provided for @addPassiveMemberLastNameError.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Nachnamen ein.'**
  String get addPassiveMemberLastNameError;

  /// No description provided for @addPassiveMemberFirstNameError.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Vornamen ein.'**
  String get addPassiveMemberFirstNameError;

  /// No description provided for @addPassiveMemberAddButton.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get addPassiveMemberAddButton;

  /// No description provided for @addPassiveMemberCancelButton.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get addPassiveMemberCancelButton;

  /// Erfolgsmeldung beim Hinzufügen eines passiven Mitglieds
  ///
  /// In de, this message translates to:
  /// **'{firstName} wurde erfolgreich hinzugefügt.'**
  String addPassiveMemberSuccess(String firstName);

  /// Fehlermeldung beim Hinzufügen eines passiven Mitglieds
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Hinzufügen des Mitglieds: {error}'**
  String addPassiveMemberError(String error);

  /// No description provided for @enterLocationHint.
  ///
  /// In de, this message translates to:
  /// **'Ort eingeben'**
  String get enterLocationHint;

  /// No description provided for @enterDescriptionHint.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung eingeben'**
  String get enterDescriptionHint;

  /// No description provided for @groupPageRoleAdmin.
  ///
  /// In de, this message translates to:
  /// **'Administrator'**
  String get groupPageRoleAdmin;

  /// No description provided for @groupPageRoleMember.
  ///
  /// In de, this message translates to:
  /// **'Mitglied'**
  String get groupPageRoleMember;

  /// No description provided for @shareGroupIdInstruction.
  ///
  /// In de, this message translates to:
  /// **'Teile diese Gruppen-ID mit deinen Freunden!'**
  String get shareGroupIdInstruction;

  /// No description provided for @groupIdCopied.
  ///
  /// In de, this message translates to:
  /// **'Gruppen-ID wurde kopiert!'**
  String get groupIdCopied;

  /// No description provided for @newGroupTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue Gruppe erstellen'**
  String get newGroupTitle;

  /// No description provided for @enterGroupName.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Gruppennamen ein.'**
  String get enterGroupName;

  /// Erfolgsmeldung bei Gruppenerstellung
  ///
  /// In de, this message translates to:
  /// **'Gruppe \"{groupName}\" erfolgreich erstellt!'**
  String groupCreatedSuccess(String groupName);

  /// Fehlermeldung bei Gruppenerstellung
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Erstellen der Gruppe: {error}'**
  String createGroupError(String error);

  /// No description provided for @groupNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Gruppenname'**
  String get groupNameLabel;

  /// No description provided for @locationLabel.
  ///
  /// In de, this message translates to:
  /// **'Ort'**
  String get locationLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get descriptionLabel;

  /// No description provided for @createButtonText.
  ///
  /// In de, this message translates to:
  /// **'Erstellen'**
  String get createButtonText;

  /// No description provided for @noCurrentUserError.
  ///
  /// In de, this message translates to:
  /// **'Fehler: Kein angemeldeter Benutzer verfügbar. Bitte melden Sie sich an.'**
  String get noCurrentUserError;

  /// No description provided for @noActiveGroupError.
  ///
  /// In de, this message translates to:
  /// **'Es konnten keine Gruppen geladen werden oder es ist keine aktive Gruppe vorhanden.'**
  String get noActiveGroupError;

  /// Fehlermeldung beim Laden von Gruppen
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Gruppen: {error}'**
  String loadingGroupsError(String error);

  /// No description provided for @groupsDeletedError.
  ///
  /// In de, this message translates to:
  /// **'Alle Gruppen wurden gelöscht oder konnten nicht geladen werden.'**
  String get groupsDeletedError;

  /// No description provided for @unknownError.
  ///
  /// In de, this message translates to:
  /// **'Ein unbekannter Fehler ist aufgetreten.'**
  String get unknownError;

  /// No description provided for @createGroupNotImplemented.
  ///
  /// In de, this message translates to:
  /// **'Gruppen-Erstellungsfunktion noch nicht implementiert.'**
  String get createGroupNotImplemented;

  /// No description provided for @createGroupButtonText.
  ///
  /// In de, this message translates to:
  /// **'Neue Gruppe erstellen'**
  String get createGroupButtonText;

  /// No description provided for @calendarTitle.
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get calendarTitle;

  /// No description provided for @groupsTitle.
  ///
  /// In de, this message translates to:
  /// **'Gruppen'**
  String get groupsTitle;

  /// Allgemeine Fehlermeldung beim Laden
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden: {error}'**
  String loadingErrorWithDetails(String error);

  /// No description provided for @noGroupsJoined.
  ///
  /// In de, this message translates to:
  /// **'Sie sind noch keiner Gruppe beigetreten.'**
  String get noGroupsJoined;

  /// No description provided for @imprintTitle.
  ///
  /// In de, this message translates to:
  /// **'Impressum'**
  String get imprintTitle;

  /// No description provided for @languageTitle.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get languageTitle;

  /// No description provided for @languageSettingTitle.
  ///
  /// In de, this message translates to:
  /// **'Sprache auswählen'**
  String get languageSettingTitle;

  /// No description provided for @languageGerman.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In de, this message translates to:
  /// **'Englisch'**
  String get languageEnglish;

  /// No description provided for @loginScreenTitle.
  ///
  /// In de, this message translates to:
  /// **'Anmeldung'**
  String get loginScreenTitle;

  /// No description provided for @emailInputLabel.
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Adresse'**
  String get emailInputLabel;

  /// No description provided for @emailInputHint.
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Adresse eingeben'**
  String get emailInputHint;

  /// No description provided for @passwordInputLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get passwordInputLabel;

  /// No description provided for @passwordInputHint.
  ///
  /// In de, this message translates to:
  /// **'Passwort eingeben'**
  String get passwordInputHint;

  /// No description provided for @checkInputsError.
  ///
  /// In de, this message translates to:
  /// **'Bitte überprüfen Sie Ihre Eingaben'**
  String get checkInputsError;

  /// No description provided for @loginButtonText.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get loginButtonText;

  /// No description provided for @newHereButtonText.
  ///
  /// In de, this message translates to:
  /// **'Neu hier? Folgen Sie mir!'**
  String get newHereButtonText;

  /// No description provided for @notRegisteredYetText.
  ///
  /// In de, this message translates to:
  /// **'Ich bin noch nicht registriert!'**
  String get notRegisteredYetText;

  /// No description provided for @firebaseUserNotFound.
  ///
  /// In de, this message translates to:
  /// **'Benutzer nicht in Firebase gefunden.'**
  String get firebaseUserNotFound;

  /// No description provided for @firestoreUserNotFound.
  ///
  /// In de, this message translates to:
  /// **'Benutzerdaten nicht in Firestore gefunden.'**
  String get firestoreUserNotFound;

  /// Allgemeine Fehlermeldung bei Login
  ///
  /// In de, this message translates to:
  /// **'Anmeldung fehlgeschlagen: {message}'**
  String loginFailedGeneric(String message);

  /// No description provided for @loginFailedUserNotFound.
  ///
  /// In de, this message translates to:
  /// **'Kein Benutzer für diese E-Mail-Adresse gefunden.'**
  String get loginFailedUserNotFound;

  /// No description provided for @loginFailedWrongPassword.
  ///
  /// In de, this message translates to:
  /// **'Falsches Passwort für diese E-Mail-Adresse.'**
  String get loginFailedWrongPassword;

  /// No description provided for @googleLoginFailedNoUser.
  ///
  /// In de, this message translates to:
  /// **'Google-Anmeldung fehlgeschlagen: Kein Firebase-Benutzer erhalten.'**
  String get googleLoginFailedNoUser;

  /// No description provided for @googleLoginNewUserCreated.
  ///
  /// In de, this message translates to:
  /// **'Neues Google-Benutzerprofil erstellt.'**
  String get googleLoginNewUserCreated;

  /// No description provided for @googleLoginSuccess.
  ///
  /// In de, this message translates to:
  /// **'Google-Benutzer erfolgreich angemeldet.'**
  String get googleLoginSuccess;

  /// No description provided for @googleLoginExistingUser.
  ///
  /// In de, this message translates to:
  /// **'Google-Benutzer in Firestore gefunden: {uid}'**
  String googleLoginExistingUser(Object uid);

  /// No description provided for @googleLoginFailedFirestoreLoad.
  ///
  /// In de, this message translates to:
  /// **'Fehler: Benutzerdaten konnten nach der Erstellung nicht geladen werden.'**
  String get googleLoginFailedFirestoreLoad;

  /// No description provided for @googleLoginFailedDifferentCredential.
  ///
  /// In de, this message translates to:
  /// **'Ein Konto mit dieser E-Mail-Adresse existiert bereits, aber mit einer anderen Anmeldemethode.'**
  String get googleLoginFailedDifferentCredential;

  /// No description provided for @googleLoginAborted.
  ///
  /// In de, this message translates to:
  /// **'Google-Anmeldung vom Benutzer abgebrochen.'**
  String get googleLoginAborted;

  /// Unerwarteter Fehler bei Google-Login
  ///
  /// In de, this message translates to:
  /// **'Unerwarteter Fehler bei der Google-Anmeldung: {error}'**
  String googleLoginUnexpectedError(String error);

  /// No description provided for @signInWithGoogleTooltip.
  ///
  /// In de, this message translates to:
  /// **'Mit Google anmelden'**
  String get signInWithGoogleTooltip;

  /// No description provided for @signInWithAppleNotImplemented.
  ///
  /// In de, this message translates to:
  /// **'Apple-Anmeldung noch nicht implementiert.'**
  String get signInWithAppleNotImplemented;

  /// No description provided for @signInWithAppleTooltip.
  ///
  /// In de, this message translates to:
  /// **'Mit Apple anmelden'**
  String get signInWithAppleTooltip;

  /// No description provided for @emailValidationEmpty.
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Adresse darf nicht leer sein'**
  String get emailValidationEmpty;

  /// No description provided for @emailValidationInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie eine gültige E-Mail-Adresse ein.'**
  String get emailValidationInvalid;

  /// No description provided for @passwordValidationMinLength.
  ///
  /// In de, this message translates to:
  /// **'Mind. 8 Zeichen'**
  String get passwordValidationMinLength;

  /// No description provided for @passwordValidationMaxLength.
  ///
  /// In de, this message translates to:
  /// **'Max. 50 Zeichen'**
  String get passwordValidationMaxLength;

  /// No description provided for @passwordValidationLowercase.
  ///
  /// In de, this message translates to:
  /// **'Mind. ein Kleinbuchstabe'**
  String get passwordValidationLowercase;

  /// No description provided for @passwordValidationUppercase.
  ///
  /// In de, this message translates to:
  /// **'Mind. ein Großbuchstabe'**
  String get passwordValidationUppercase;

  /// No description provided for @passwordValidationDigit.
  ///
  /// In de, this message translates to:
  /// **'Mind. eine Ziffer'**
  String get passwordValidationDigit;

  /// No description provided for @passwordValidationSpecialChar.
  ///
  /// In de, this message translates to:
  /// **'Mind. ein Sonderzeichen'**
  String get passwordValidationSpecialChar;

  /// No description provided for @appointmentTitle.
  ///
  /// In de, this message translates to:
  /// **'Termin'**
  String get appointmentTitle;

  /// No description provided for @appointmentTitleLabel.
  ///
  /// In de, this message translates to:
  /// **'Termintitel'**
  String get appointmentTitleLabel;

  /// No description provided for @appointmentTitleHint.
  ///
  /// In de, this message translates to:
  /// **'Termintitel'**
  String get appointmentTitleHint;

  /// No description provided for @dateLabel.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get dateLabel;

  /// No description provided for @dateHint.
  ///
  /// In de, this message translates to:
  /// **'JJJJ-MM-TT'**
  String get dateHint;

  /// No description provided for @timeHint.
  ///
  /// In de, this message translates to:
  /// **'HH:MM'**
  String get timeHint;

  /// No description provided for @allDayLabel.
  ///
  /// In de, this message translates to:
  /// **'Ganztägig'**
  String get allDayLabel;

  /// No description provided for @startTimeLabel.
  ///
  /// In de, this message translates to:
  /// **'Startzeit'**
  String get startTimeLabel;

  /// No description provided for @endTimeLabel.
  ///
  /// In de, this message translates to:
  /// **'Endzeit'**
  String get endTimeLabel;

  /// No description provided for @locationHint.
  ///
  /// In de, this message translates to:
  /// **'Terminort'**
  String get locationHint;

  /// No description provided for @descriptionHint.
  ///
  /// In de, this message translates to:
  /// **'Details zum Termin (optional)'**
  String get descriptionHint;

  /// Ersteller eines Elements
  ///
  /// In de, this message translates to:
  /// **'Erstellt von: {creator}'**
  String createdByUser(String creator);

  /// Gruppenzugehörigkeit eines Elements
  ///
  /// In de, this message translates to:
  /// **'Für Gruppe: {groupName}'**
  String forGroup(String groupName);

  /// No description provided for @validatorTitleEmpty.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Titel ein'**
  String get validatorTitleEmpty;

  /// No description provided for @validatorTitleLength.
  ///
  /// In de, this message translates to:
  /// **'Maximal 80 Zeichen erlaubt'**
  String get validatorTitleLength;

  /// No description provided for @validatorTitleEmojis.
  ///
  /// In de, this message translates to:
  /// **'Keine Emojis erlaubt'**
  String get validatorTitleEmojis;

  /// No description provided for @validatorLocationEmpty.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Ort ein'**
  String get validatorLocationEmpty;

  /// No description provided for @validatorLocationInvalidChars.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Zeichen im Ort'**
  String get validatorLocationInvalidChars;

  /// No description provided for @validatorDescriptionLength.
  ///
  /// In de, this message translates to:
  /// **'Maximal 500 Zeichen erlaubt'**
  String get validatorDescriptionLength;

  /// No description provided for @validatorRepeatCountEmpty.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie eine Zahl ein'**
  String get validatorRepeatCountEmpty;

  /// No description provided for @validatorRepeatCountInvalid.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Zahl (muss > 0 sein)'**
  String get validatorRepeatCountInvalid;

  /// No description provided for @validatorRepeatCountMax.
  ///
  /// In de, this message translates to:
  /// **'Max. 365 Wiederholungen'**
  String get validatorRepeatCountMax;

  /// No description provided for @snackbarFillAllFields.
  ///
  /// In de, this message translates to:
  /// **'Bitte füllen Sie alle Felder korrekt aus.'**
  String get snackbarFillAllFields;

  /// No description provided for @snackbarAddImage.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie Ihrem Ereignis ein Gesicht.'**
  String get snackbarAddImage;

  /// No description provided for @snackbarSelectParticipants.
  ///
  /// In de, this message translates to:
  /// **'Für wen ist der Termin? Bitte wählen Sie mindestens einen Teilnehmer aus.'**
  String get snackbarSelectParticipants;

  /// No description provided for @snackbarDateParseError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Parsen von Datum oder Uhrzeit.'**
  String get snackbarDateParseError;

  /// No description provided for @snackbarCreatorError.
  ///
  /// In de, this message translates to:
  /// **'Fehler: Terminersteller konnte nicht ermittelt werden.'**
  String get snackbarCreatorError;

  /// No description provided for @snackbarRecurringEventSaved.
  ///
  /// In de, this message translates to:
  /// **'Terminserie gespeichert!'**
  String get snackbarRecurringEventSaved;

  /// No description provided for @snackbarSingleEventSaved.
  ///
  /// In de, this message translates to:
  /// **'Termin gespeichert!'**
  String get snackbarSingleEventSaved;

  /// Fehlermeldung beim Speichern
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern des Termins: {error}'**
  String snackbarSaveError(String error);

  /// No description provided for @repeatDaily.
  ///
  /// In de, this message translates to:
  /// **'Täglich'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In de, this message translates to:
  /// **'Wöchentlich'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In de, this message translates to:
  /// **'Monatlich'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In de, this message translates to:
  /// **'Jährlich'**
  String get repeatYearly;

  /// No description provided for @reminderOneHour.
  ///
  /// In de, this message translates to:
  /// **'1 Stunde'**
  String get reminderOneHour;

  /// No description provided for @reminderOneDay.
  ///
  /// In de, this message translates to:
  /// **'1 Tag'**
  String get reminderOneDay;

  /// No description provided for @reminder30Minutes.
  ///
  /// In de, this message translates to:
  /// **'30 Minuten'**
  String get reminder30Minutes;

  /// No description provided for @validateDateEmpty.
  ///
  /// In de, this message translates to:
  /// **'Bitte wählen Sie ein Datum aus'**
  String get validateDateEmpty;

  /// No description provided for @validateDateInvalid.
  ///
  /// In de, this message translates to:
  /// **'Ungültiges Datum'**
  String get validateDateInvalid;

  /// No description provided for @validateDateInPast.
  ///
  /// In de, this message translates to:
  /// **'Datum kann nicht in der Vergangenheit liegen'**
  String get validateDateInPast;

  /// No description provided for @validateTimeEmpty.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie eine Zeit ein'**
  String get validateTimeEmpty;

  /// No description provided for @validateTimeInvalid.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Zeit'**
  String get validateTimeInvalid;

  /// No description provided for @eventParticipantsTitle.
  ///
  /// In de, this message translates to:
  /// **'Für wen ist der Termin?'**
  String get eventParticipantsTitle;

  /// Fehlermeldung beim Laden von Mitgliedern
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String errorLoadingMembers(String error);

  /// No description provided for @noMembersFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Mitglieder gefunden.'**
  String get noMembersFound;

  /// No description provided for @addImageTitle.
  ///
  /// In de, this message translates to:
  /// **'Foto oder Piktogramm hinzufügen'**
  String get addImageTitle;

  /// No description provided for @addImageDescription.
  ///
  /// In de, this message translates to:
  /// **'Das ausgewählte Bild ersetzt den Titel des Termins in der Kalenderansicht.'**
  String get addImageDescription;

  /// No description provided for @repeatLabel.
  ///
  /// In de, this message translates to:
  /// **'Wiederholen'**
  String get repeatLabel;

  /// No description provided for @repeatDropdownLabel.
  ///
  /// In de, this message translates to:
  /// **'Wiederholung'**
  String get repeatDropdownLabel;

  /// No description provided for @numberOfRepeatsLabel.
  ///
  /// In de, this message translates to:
  /// **'Anzahl der Wiederholungen'**
  String get numberOfRepeatsLabel;

  /// No description provided for @numberOfRepeatsHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. 5 (inkl. diesem Termin)'**
  String get numberOfRepeatsHint;

  /// No description provided for @reminderLabel.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung'**
  String get reminderLabel;

  /// No description provided for @reminderBeforeLabel.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung vor'**
  String get reminderBeforeLabel;

  /// No description provided for @saveButtonText.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get saveButtonText;

  /// Fehlermeldung beim Laden des Gruppenbildes
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden des Gruppen-Avatars: {error}'**
  String groupAvatarLoadingError(String error);

  /// Fehlermeldung beim Laden des Ereignisbildes
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden des Avatars in SingleEventAvatar: {error}'**
  String singleEventAvatarLoadingError(String error);

  /// Erfolgsmeldung beim Hochladen eines Bildes
  ///
  /// In de, this message translates to:
  /// **'Bild erfolgreich hochgeladen: {downloadUrl}'**
  String imageUploadSuccess(String downloadUrl);

  /// No description provided for @imageDeletedSuccess.
  ///
  /// In de, this message translates to:
  /// **'Bild erfolgreich gelöscht.'**
  String get imageDeletedSuccess;

  /// Fehlermeldung beim Löschen eines Bildes
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Löschen des Bildes: {error}'**
  String imageDeleteError(String error);

  /// No description provided for @imageUploadAborted.
  ///
  /// In de, this message translates to:
  /// **'Bild-Upload abgebrochen oder fehlgeschlagen.'**
  String get imageUploadAborted;

  /// Fehlermeldung beim Hochladen eines Bildes
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Bild-Upload: {error}'**
  String imageUploadError(String error);

  /// No description provided for @manageMembersUpdateSuccess.
  ///
  /// In de, this message translates to:
  /// **'Mitglieder erfolgreich aktualisiert.'**
  String get manageMembersUpdateSuccess;

  /// Fehlermeldung beim Aktualisieren der Mitglieder
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Aktualisieren der Mitglieder: {error}'**
  String manageMembersUpdateError(String error);

  /// No description provided for @manageMembersTitle.
  ///
  /// In de, this message translates to:
  /// **'Mitglieder verwalten'**
  String get manageMembersTitle;

  /// No description provided for @manageMembersCurrentTitle.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Mitglieder'**
  String get manageMembersCurrentTitle;

  /// No description provided for @manageMembersRoleAdmin.
  ///
  /// In de, this message translates to:
  /// **'(Admin)'**
  String get manageMembersRoleAdmin;

  /// No description provided for @manageMembersRoleMember.
  ///
  /// In de, this message translates to:
  /// **'(Mitglied)'**
  String get manageMembersRoleMember;

  /// No description provided for @manageMembersRolePassive.
  ///
  /// In de, this message translates to:
  /// **'(Passiv)'**
  String get manageMembersRolePassive;

  /// No description provided for @manageMembersNoEmailPhone.
  ///
  /// In de, this message translates to:
  /// **'Keine E-Mail/Telefonnummer'**
  String get manageMembersNoEmailPhone;

  /// No description provided for @manageMembersSavingButton.
  ///
  /// In de, this message translates to:
  /// **'Wird gespeichert...'**
  String get manageMembersSavingButton;

  /// No description provided for @manageMembersSaveChangesButton.
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern'**
  String get manageMembersSaveChangesButton;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
