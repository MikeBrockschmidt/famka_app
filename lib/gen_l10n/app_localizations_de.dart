// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get addOrJoinGroupRequiredFieldError =>
      'Bitte füllen Sie alle erforderlichen Felder aus.';

  @override
  String get addOrJoinGroupTitle => 'Gruppe erstellen';

  @override
  String get addOrJoinGroupCreateHint => 'Gruppenname eingeben';

  @override
  String get addOrJoinGroupGroupNameEmpty =>
      'Bitte geben Sie einen Gruppennamen ein.';

  @override
  String get addOrJoinGroupDescriptionHint =>
      'Eine kurze Beschreibung Ihrer Gruppe';

  @override
  String get addOrJoinGroupLocationHint => 'Wo befindet sich Ihre Gruppe?';

  @override
  String get addOrJoinGroupCreateButton => 'Gruppe erstellen';

  @override
  String get addPassiveMemberTitle => 'Passives Mitglied hinzufügen';

  @override
  String get addPassiveMemberFirstNameLabel => 'Vorname';

  @override
  String get addPassiveMemberLastNameLabel => 'Nachname';

  @override
  String get addPassiveMemberLastNameError =>
      'Bitte geben Sie einen Nachnamen ein.';

  @override
  String get addPassiveMemberFirstNameError =>
      'Bitte geben Sie einen Vornamen ein.';

  @override
  String get addPassiveMemberAddButton => 'Hinzufügen';

  @override
  String get addPassiveMemberCancelButton => 'Abbrechen';

  @override
  String addPassiveMemberSuccess(String firstName) {
    return '$firstName wurde erfolgreich hinzugefügt.';
  }

  @override
  String addPassiveMemberError(String error) {
    return 'Fehler beim Hinzufügen des Mitglieds: $error';
  }

  @override
  String get enterLocationHint => 'Ort eingeben';

  @override
  String get enterDescriptionHint => 'Beschreibung eingeben';

  @override
  String get groupPageRoleAdmin => 'Rolle: Admin';

  @override
  String get groupPageRoleMember => 'Rolle: Mitglied';

  @override
  String get shareGroupIdInstruction =>
      'Teilen Sie diese Gruppen-ID mit anderen, damit sie der Gruppe beitreten können:';

  @override
  String get groupIdCopied => 'Gruppen-ID kopiert!';

  @override
  String get copyButton => 'Kopieren';

  @override
  String get menuTitle => 'Menü';

  @override
  String get newGroupTitle => 'Neue Gruppe erstellen';

  @override
  String get enterGroupName => 'Bitte geben Sie einen Gruppennamen ein.';

  @override
  String groupCreatedSuccess(String groupName) {
    return 'Gruppe \"$groupName\" erfolgreich erstellt!';
  }

  @override
  String createGroupError(String error) {
    return 'Fehler beim Erstellen der Gruppe: $error';
  }

  @override
  String get noGroupSelectedError =>
      'Bitte erstellen oder treten Sie einer Gruppe bei, um diese Funktion zu nutzen.';

  @override
  String get groupNameLabel => 'Gruppenname';

  @override
  String get locationLabel => 'Ort';

  @override
  String get descriptionLabel => 'Beschreibung';

  @override
  String get createButtonText => 'Erstellen';

  @override
  String get fillRequiredFields =>
      'Bitte füllen Sie alle erforderlichen Felder aus.';

  @override
  String get groupName => 'Gruppenname';

  @override
  String get groupDescription => 'Gruppenbeschreibung';

  @override
  String get appTitle => 'Famka';

  @override
  String get groupLocation => 'Ort';

  @override
  String get inviteUserPrompt =>
      'Geben Sie die Profil-ID des Benutzers ein, den Sie einladen möchten';

  @override
  String get userProfileIdHint => 'Benutzerprofil-ID eingeben';

  @override
  String get enterProfileIdError =>
      'Bitte geben Sie eine gültige Profil-ID ein';

  @override
  String get addButtonText => 'Hinzufügen';

  @override
  String get cancelButtonText => 'Abbrechen';

  @override
  String get noCurrentUserError =>
      'Fehler: Kein angemeldeter Benutzer verfügbar. Bitte melden Sie sich an.';

  @override
  String get noActiveGroupError =>
      'Es konnten keine Gruppen geladen werden oder es ist keine aktive Gruppe vorhanden.';

  @override
  String loadingGroupsError(String error) {
    return 'Fehler beim Laden der Gruppen: $error';
  }

  @override
  String get groupsDeletedError =>
      'Alle Gruppen wurden gelöscht oder konnten nicht geladen werden.';

  @override
  String get unknownError => 'Ein unbekannter Fehler ist aufgetreten.';

  @override
  String get createGroupNotImplemented =>
      'Gruppen-Erstellungsfunktion noch nicht implementiert.';

  @override
  String get createGroupButtonText => 'Neue Gruppe erstellen';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get groupsTitle => 'Gruppen';

  @override
  String loadingErrorWithDetails(String error) {
    return 'Fehler beim Laden: $error';
  }

  @override
  String get noGroupsJoined => 'Sie sind noch keiner Gruppe beigetreten.';

  @override
  String get imprintTitle => 'Impressum';

  @override
  String get languageTitle => 'Setup';

  @override
  String get languageSettingTitle => 'Sprache auswählen';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get closeButton => 'Schließen';

  @override
  String get loginScreenTitle => 'Anmeldung';

  @override
  String get emailInputLabel => 'E-Mail-Adresse';

  @override
  String get emailInputHint => 'E-Mail-Adresse eingeben';

  @override
  String get passwordInputLabel => 'Passwort';

  @override
  String get passwordInputHint => 'Passwort eingeben';

  @override
  String get checkInputsError => 'Bitte überprüfen Sie Ihre Eingaben.';

  @override
  String get loginButtonText => 'Anmelden';

  @override
  String get newHereButtonText => 'Neu hier? Folgen Sie mir!';

  @override
  String get notRegisteredYetText => 'Ich bin noch nicht registriert!';

  @override
  String get firebaseUserNotFound => 'Benutzer nicht in Firebase gefunden.';

  @override
  String get firestoreUserNotFound =>
      'Benutzerdaten nicht in Firestore gefunden.';

  @override
  String loginFailedGeneric(String message) {
    return 'Anmeldung fehlgeschlagen: $message';
  }

  @override
  String get loginFailedUserNotFound =>
      'Kein Benutzer für diese E-Mail-Adresse gefunden.';

  @override
  String get loginFailedWrongPassword =>
      'Falsches Passwort für diese E-Mail-Adresse.';

  @override
  String get googleLoginFailedNoUser =>
      'Google-Anmeldung fehlgeschlagen: Kein Firebase-Benutzer erhalten.';

  @override
  String get googleLoginNewUserCreated =>
      'Neues Google-Benutzerprofil erstellt.';

  @override
  String get googleLoginSuccess => 'Google-Benutzer erfolgreich angemeldet.';

  @override
  String googleLoginExistingUser(Object uid) {
    return 'Google-Benutzer in Firestore gefunden: $uid';
  }

  @override
  String get googleLoginFailedFirestoreLoad =>
      'Fehler: Benutzerdaten konnten nach der Erstellung nicht geladen werden.';

  @override
  String get googleLoginFailedDifferentCredential =>
      'Ein Konto mit dieser E-Mail-Adresse existiert bereits, aber mit einer anderen Anmeldemethode.';

  @override
  String get googleLoginAborted => 'Google-Anmeldung vom Benutzer abgebrochen.';

  @override
  String googleLoginUnexpectedError(String error) {
    return 'Unerwarteter Fehler bei der Google-Anmeldung: $error';
  }

  @override
  String get signInWithGoogleTooltip => 'Mit Google anmelden';

  @override
  String get signInWithAppleNotImplemented =>
      'Apple-Anmeldung noch nicht implementiert.';

  @override
  String get signInWithAppleTooltip => 'Mit Apple anmelden';

  @override
  String get appleLoginNewUserCreated => 'Neues Apple-Benutzerprofil erstellt.';

  @override
  String get appleLoginSuccess => 'Apple-Benutzer erfolgreich angemeldet.';

  @override
  String appleLoginExistingUser(Object uid) {
    return 'Apple-Benutzer in Firestore gefunden: $uid';
  }

  @override
  String get appleLoginFailedFirestoreLoad =>
      'Fehler: Benutzerdaten konnten nach der Erstellung nicht geladen werden.';

  @override
  String get appleLoginFailedDifferentCredential =>
      'Ein Konto mit dieser E-Mail-Adresse existiert bereits, aber mit einer anderen Anmeldemethode.';

  @override
  String get appleLoginAborted => 'Apple-Anmeldung abgebrochen.';

  @override
  String appleLoginUnexpectedError(String error) {
    return 'Unerwarteter Fehler bei der Apple-Anmeldung: $error';
  }

  @override
  String get appleLoginUnsupportedPlatform =>
      'Apple-Anmeldung wird nur auf iOS-Geräten unterstützt.';

  @override
  String get showPasswordTooltip => 'Show password';

  @override
  String get hidePasswordTooltip => 'Hide password';

  @override
  String get emailValidationEmpty => 'E-Mail-Adresse darf nicht leer sein';

  @override
  String get emailValidationInvalid =>
      'Bitte geben Sie eine gültige E-Mail-Adresse ein.';

  @override
  String get passwordValidationMinLength => 'Mind. 8 Zeichen';

  @override
  String get passwordValidationMaxLength => 'Max. 50 Zeichen';

  @override
  String get passwordValidationLowercase => 'Mind. ein Kleinbuchstabe';

  @override
  String get passwordValidationUppercase => 'Mind. ein Großbuchstabe';

  @override
  String get passwordValidationDigit => 'Mind. eine Ziffer';

  @override
  String get passwordValidationSpecialChar => 'Mind. ein Sonderzeichen';

  @override
  String get appointmentTitle => 'Termin';

  @override
  String get appointmentTitleLabel => 'Termintitel';

  @override
  String get appointmentTitleHint => 'Termintitel';

  @override
  String get dateLabel => 'Datum';

  @override
  String get dateHint => 'JJJJ-MM-TT';

  @override
  String get timeHint => 'HH:MM';

  @override
  String get allDayLabel => 'Ganztägig';

  @override
  String get startTimeLabel => 'Startzeit';

  @override
  String get endTimeLabel => 'Endzeit';

  @override
  String get locationHint => 'Terminort';

  @override
  String get descriptionHint => 'Details zum Termin (optional)';

  @override
  String createdByUser(String creator) {
    return 'Erstellt von: $creator';
  }

  @override
  String forGroup(String groupName) {
    return 'Für Gruppe: $groupName';
  }

  @override
  String get validatorTitleEmpty => 'Bitte geben Sie einen Titel ein';

  @override
  String get validatorTitleLength => 'Maximal 80 Zeichen erlaubt';

  @override
  String get validatorTitleEmojis => 'Keine Emojis erlaubt';

  @override
  String get validatorLocationEmpty => 'Bitte geben Sie einen Ort ein';

  @override
  String get validatorLocationInvalidChars => 'Ungültige Zeichen im Ort';

  @override
  String get validatorDescriptionLength => 'Maximal 500 Zeichen erlaubt';

  @override
  String get validatorRepeatCountEmpty => 'Bitte geben Sie eine Zahl ein';

  @override
  String get validatorRepeatCountInvalid => 'Ungültige Zahl (muss > 0 sein)';

  @override
  String get validatorRepeatCountMax => 'Max. 365 Wiederholungen';

  @override
  String get snackbarFillAllFields =>
      'Bitte füllen Sie alle Felder korrekt aus.';

  @override
  String get snackbarAddImage => 'Bitte geben Sie Ihrem Ereignis ein Gesicht.';

  @override
  String get snackbarSelectParticipants =>
      'Für wen ist der Termin? Bitte wählen Sie mindestens einen Teilnehmer aus.';

  @override
  String get snackbarDateParseError =>
      'Fehler beim Parsen von Datum oder Uhrzeit.';

  @override
  String get snackbarCreatorError =>
      'Fehler: Terminersteller konnte nicht ermittelt werden.';

  @override
  String get snackbarRecurringEventSaved => 'Terminserie gespeichert!';

  @override
  String get snackbarSingleEventSaved => 'Termin gespeichert!';

  @override
  String snackbarSaveError(String error) {
    return 'Fehler beim Speichern des Termins: $error';
  }

  @override
  String get repeatDaily => 'Täglich';

  @override
  String get repeatWeekly => 'Wöchentlich';

  @override
  String get repeatMonthly => 'Monatlich';

  @override
  String get repeatYearly => 'Jährlich';

  @override
  String get reminderOneHour => '1 Stunde';

  @override
  String get reminderOneDay => '1 Tag';

  @override
  String get reminder30Minutes => '30 Minuten';

  @override
  String get validateDateEmpty => 'Bitte wählen Sie ein Datum aus';

  @override
  String get validateDateInvalid => 'Ungültiges Datum';

  @override
  String get validateDateInPast =>
      'Datum kann nicht in der Vergangenheit liegen';

  @override
  String get validateTimeEmpty => 'Bitte geben Sie eine Zeit ein';

  @override
  String get validateTimeInvalid => 'Ungültige Zeit';

  @override
  String get eventParticipantsTitle => 'Für wen ist der Termin?';

  @override
  String errorLoadingMembers(String error) {
    return 'Fehler: $error';
  }

  @override
  String get noMembersFound => 'Keine Mitglieder gefunden.';

  @override
  String get addImageTitle => 'Foto oder Piktogramm hinzufügen';

  @override
  String get addImageDescription =>
      'Das ausgewählte Bild ersetzt den Titel des Termins in der Kalenderansicht.';

  @override
  String get repeatLabel => 'Wiederholen';

  @override
  String get repeatDropdownLabel => 'Wiederholung';

  @override
  String get numberOfRepeatsLabel => 'Anzahl der Wiederholungen';

  @override
  String get numberOfRepeatsHint => 'z.B. 5 (inkl. diesem Termin)';

  @override
  String get reminderLabel => 'Erinnerung';

  @override
  String get reminderBeforeLabel => 'Erinnerung vor';

  @override
  String get saveButtonText => 'Speichern';

  @override
  String groupAvatarLoadingError(String error) {
    return 'Fehler beim Laden des Gruppen-Avatars: $error';
  }

  @override
  String singleEventAvatarLoadingError(String error) {
    return 'Fehler beim Laden des Avatars in SingleEventAvatar: $error';
  }

  @override
  String get errorCreatingGroup => 'Error creating group';

  @override
  String imageUploadSuccess(String downloadUrl) {
    return 'Bild erfolgreich hochgeladen und aktualisiert.';
  }

  @override
  String get imageDeletedSuccess => 'Bild erfolgreich gelöscht.';

  @override
  String imageDeleteError(String error) {
    return 'Fehler beim Löschen des Bildes: $error';
  }

  @override
  String get imageUploadAborted =>
      'Bild-Upload abgebrochen oder fehlgeschlagen.';

  @override
  String imageUploadError(String error) {
    return 'Fehler beim Bild-Upload: $error';
  }

  @override
  String get manageMembersUpdateSuccess =>
      'Mitglieder erfolgreich aktualisiert.';

  @override
  String manageMembersUpdateError(String error) {
    return 'Fehler beim Aktualisieren der Mitglieder: $error';
  }

  @override
  String get manageMembersTitle => 'Mitglieder verwalten';

  @override
  String get manageMembersCurrentTitle => 'Aktuelle Mitglieder';

  @override
  String get manageMembersRoleAdmin => '(Admin)';

  @override
  String get manageMembersRoleMember => '(Mitglied)';

  @override
  String get manageMembersRolePassive => '(Passiv)';

  @override
  String get manageMembersNoEmailPhone => 'Keine E-Mail/Telefonnummer';

  @override
  String get manageMembersSavingButton => 'Wird gespeichert...';

  @override
  String get manageMembersSaveChangesButton => 'Änderungen speichern';

  @override
  String get manageMembersRemoveTitle => 'Mitglied entfernen';

  @override
  String manageMembersRemoveConfirmation(String memberName) {
    return 'Möchten Sie $memberName wirklich aus der Gruppe entfernen?';
  }

  @override
  String get manageMembersRemoveCancel => 'Abbrechen';

  @override
  String get manageMembersRemoveConfirm => 'Entfernen';

  @override
  String get deleteAppointment => 'Termin löschen';

  @override
  String confirmDeleteAppointment(Object eventName) {
    return 'Möchten Sie \"$eventName\" wirklich dauerhaft löschen?';
  }

  @override
  String get editDescription => 'Beschreibung bearbeiten';

  @override
  String participants(Object names) {
    return 'Teilnehmer: $names';
  }

  @override
  String get menuLabel => 'Menü';

  @override
  String get calendarLabel => 'Kalender';

  @override
  String get appointmentLabel => 'Termin';

  @override
  String get galleryLabel => 'Galerie';

  @override
  String get piktogrammeLabe => 'Piktogramme';

  @override
  String get gallerySourceCamera => 'Kamera';

  @override
  String get gallerySourceGallery => 'Galerie';

  @override
  String get timeAllDay => 'Uhrzeit: Ganztägig';

  @override
  String timeAt(Object time) {
    return 'Uhrzeit: $time Uhr';
  }

  @override
  String location(Object location) {
    return 'Ort: $location';
  }

  @override
  String description(Object description) {
    return 'Beschreibung: $description';
  }

  @override
  String get noDescription => 'Keine Beschreibung';

  @override
  String appointmentsFor(Object name) {
    return 'Termine für $name';
  }

  @override
  String get saveButton => 'Speichern';

  @override
  String get noChangesToSave => 'Keine Änderungen zum Speichern.';

  @override
  String get descriptionUpdateSuccess =>
      'Beschreibung erfolgreich aktualisiert.';

  @override
  String descriptionUpdateError(Object error) {
    return 'Fehler beim Aktualisieren der Beschreibung: $error';
  }

  @override
  String get imageLoadError => 'Bild konnte nicht geladen werden';

  @override
  String get deleteImageTitle => 'Bild löschen?';

  @override
  String get deleteImageDescription =>
      'Möchten Sie dieses Bild wirklich aus der Galerie entfernen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get deleteImageButton => 'Löschen';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get imageUploadSuccessSelectNow =>
      'Bild erfolgreich hochgeladen. Bitte auswählen.';

  @override
  String get passwordShowTooltip => 'Passwort anzeigen';

  @override
  String get passwordHideTooltip => 'Passwort verbergen';

  @override
  String get noUserDataError => 'Keine Benutzerdaten verfügbar.';

  @override
  String get dateFormat => 'yyyy-MM-dd';

  @override
  String get localeGerman => 'de';

  @override
  String errorLoadingAvatar(Object avatarUrl, Object exception) {
    return 'Fehler beim Laden des Avatars von $avatarUrl: $exception';
  }

  @override
  String get httpPrefix => 'http://';

  @override
  String get httpsPrefix => 'https://';

  @override
  String get assetsPrefix => 'assets/';

  @override
  String get defaultAvatarPath => 'assets/fotos/default.jpg';

  @override
  String errorLoadingGroupAvatar(Object exception) {
    return 'Fehler beim Laden des Gruppen-Avatars in ProfilAvatarRow: $exception';
  }

  @override
  String get cropImageTitle => 'Bild zuschneiden';

  @override
  String compressedImageName(Object timestamp) {
    return 'compressed_$timestamp.jpg';
  }

  @override
  String get compressionFailed => '❌ Komprimierung fehlgeschlagen.';

  @override
  String uploadSuccess(Object downloadUrl) {
    return '✅ Bild erfolgreich zu Firebase Storage hochgeladen: $downloadUrl';
  }

  @override
  String uploadError(Object state) {
    return '❌ Fehler beim Hochladen des Bildes: $state';
  }

  @override
  String errorLoadingActiveGroup(Object error) {
    return 'Fehler beim Laden der aktiven Gruppe: $error';
  }

  @override
  String get menuScreenRoute => '/menuScreen';

  @override
  String get calendarScreenRoute => '/calendarScreen';

  @override
  String get appointmentScreenRoute => '/appointmentScreen';

  @override
  String get logoutButton => 'Ausloggen';

  @override
  String get addGroupButton => 'Gruppe hinzufügen';

  @override
  String get invalidEmailError => 'Ungültige E-Mail Adresse';

  @override
  String get invalidPhoneNumberError =>
      'Ungültige Telefonnummer (min. 8 Ziffern, nur Zahlen)';

  @override
  String get profilePictureUpdated => 'Profilbild aktualisiert.';

  @override
  String get profilePictureUpdateError =>
      'Fehler beim Aktualisieren des Profilbilds:';

  @override
  String get profileInfoSaved => 'Profilinformationen gespeichert.';

  @override
  String get profileInfoSaveError =>
      'Fehler beim Speichern der Profilinformationen:';

  @override
  String get logoutError => 'Fehler beim Abmelden:';

  @override
  String get profileIdTitle => 'Deine Profil-ID';

  @override
  String get profileIdDescription =>
      'Dies ist deine persönliche ID. Du kannst sie mit anderen teilen, damit sie dich zu Gruppen einladen können.';

  @override
  String get profileIdCopied => 'Profil-ID kopiert!';

  @override
  String get enterPhoneNumber => 'Telefonnummer eingeben';

  @override
  String get additionalInfo => 'Zusätzliche Infos';

  @override
  String get enterEmailAddress => 'E-Mail Adresse eingeben';

  @override
  String get onboardingComplete =>
      'Daten wurden gespeichert und Onboarding abgeschlossen.';

  @override
  String get telefonnummerEingeben => 'Telefonnummer eingeben';

  @override
  String get emailAdresseEingeben => 'E-Mail Adresse eingeben';

  @override
  String get zusaetzlicheInfos => 'Zusätzliche Infos';

  @override
  String get keineGruppenGefunden => 'Keine Gruppen gefunden.';

  @override
  String get ungueltigeTelefonnummer => 'Invalid phone number';

  @override
  String get profilGesichtGeben => 'Geben Sie Ihrem Profil ein Gesicht';

  @override
  String get fortfahren => 'Fortfahren';

  @override
  String get ungueltigeEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get vorname => 'Vorname';

  @override
  String get bitteVornameEingeben => 'Bitte Vorname eingeben';

  @override
  String get nachname => 'Nachname';

  @override
  String get nachnameEingeben => 'Nachname eingeben';

  @override
  String get bitteNachnameEingeben => 'Bitte Nachname eingeben';

  @override
  String get emailAdresse => 'E-Mail-Adresse';

  @override
  String get telefonnummerOptional => 'Telefonnummer (optional)';

  @override
  String groupDeletedSuccess(Object groupName) {
    return 'Gruppe \"$groupName\" erfolgreich gelöscht.';
  }

  @override
  String groupDeleteError(Object error) {
    return 'Fehler beim Löschen der Gruppe: $error';
  }

  @override
  String userInviteError(Object error) {
    return 'Fehler beim Einladen des Benutzers: $error';
  }

  @override
  String get userNotFound => 'Benutzer mit dieser ID nicht gefunden.';

  @override
  String get userAlreadyMember =>
      'Benutzer ist bereits Mitglied dieser Gruppe.';

  @override
  String get membersManagementComplete => 'Mitgliederverwaltung abgeschlossen.';

  @override
  String groupAvatarUpdateError(Object error) {
    return 'Fehler beim Speichern des Gruppenbilds: $error';
  }

  @override
  String get groupAvatarUpdateSuccess =>
      'Gruppenbild erfolgreich aktualisiert!';

  @override
  String debugAvatarChange(Object newAvatarUrl) {
    return 'DEBUG: _onAvatarChanged in GroupPage aufgerufen mit newAvatarUrl: $newAvatarUrl';
  }

  @override
  String get changesSaved => 'Änderungen gespeichert!';

  @override
  String groupDataLoadError(Object error) {
    return 'Fehler beim Laden der Gruppendaten oder Benutzer-ID: $error';
  }

  @override
  String get groupLoadError =>
      'Fehler: Gruppe konnte nicht geladen werden oder Benutzer-ID fehlt.';

  @override
  String get members => 'Mitglieder';

  @override
  String calendarEventsLoaded(Object groupId, Object count) {
    return 'Kalender: Events für Gruppe $groupId geladen: $count Events';
  }

  @override
  String eventLoadingError(Object error) {
    return 'Fehler beim Laden der Termine: $error';
  }

  @override
  String get eventDeletedSuccess => 'Termin erfolgreich gelöscht.';

  @override
  String get eventDeleteTargetNotFound =>
      'Fehler: Zu löschender Termin nicht gefunden.';

  @override
  String eventDeletionError(Object error) {
    return 'Fehler beim Löschen des Termins: $error';
  }

  @override
  String get placeholderViewText => 'Hier könnte eine weitere Ansicht sein.';

  @override
  String get eventListLoading => 'Starte Laden der Events...';

  @override
  String eventListLoadingForGroup(Object groupId) {
    return 'Lade Events für Gruppe $groupId';
  }

  @override
  String eventListLoadingCount(Object count) {
    return '$count Events geladen';
  }

  @override
  String eventListLoadingError(Object error) {
    return 'Fehler beim Laden der Events: $error';
  }

  @override
  String get eventListNoEvents => 'Keine Termine für diese Gruppe gefunden.';

  @override
  String get eventListTodayHeader => 'HEUTE';

  @override
  String get eventListTomorrowHeader => 'MORGEN';

  @override
  String get eventListDeleteConfirmTitle => 'Termin löschen';

  @override
  String eventListDeleteConfirmMessage(Object eventName) {
    return 'Möchtest du \"$eventName\" wirklich löschen?';
  }

  @override
  String get eventListCancelButton => 'Abbrechen';

  @override
  String get eventListDeleteButton => 'Löschen';

  @override
  String get eventListDeletedSuccess => 'Termin erfolgreich gelöscht.';

  @override
  String eventListTimeFormat(Object time) {
    return '$time Uhr';
  }

  @override
  String oldEventsFoundMessage(Object count) {
    return 'Es wurden $count alte Ereignisse gefunden. Möchten Sie diese löschen, um Speicherplatz zu sparen?';
  }

  @override
  String get deleteOldEventsTitle => 'Alte Ereignisse löschen';

  @override
  String deleteOldEventsConfirmation(Object count) {
    return 'Möchten Sie $count Ereignisse löschen, die älter als 14 Tage sind? Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String oldEventsDeletedSuccess(Object count) {
    return '$count alte Ereignisse wurden erfolgreich gelöscht.';
  }

  @override
  String oldEventsDeletionError(Object error) {
    return 'Fehler beim Löschen der alten Ereignisse: $error';
  }

  @override
  String get selectImage => 'Bild auswählen';

  @override
  String get selectProfileImage => 'Profilbild auswählen';

  @override
  String get selectGroupImage => 'Gruppenbild auswählen';

  @override
  String get selectEventImage => 'Terminbild auswählen';

  @override
  String get selectFromGallery => 'Aus Galerie wählen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromStandard => 'Oder aus Standardbildern wählen:';

  @override
  String get cancelSelection => 'Abbrechen';

  @override
  String get imageSelectionCancelled => 'Bildauswahl abgebrochen.';

  @override
  String get standardImageSet => 'Bild erfolgreich als Standardbild gesetzt.';

  @override
  String get croppingCancelled => 'Zuschneiden abgebrochen.';

  @override
  String get processingError =>
      'Fehler bei der Bildverarbeitung für den Upload.';

  @override
  String get noUserIdError =>
      'Fehler: Keine Benutzer-ID verfügbar. Bitte melden Sie sich an.';

  @override
  String firebaseUploadError(Object error) {
    return 'Fehler beim Upload zu Firebase Storage: $error';
  }

  @override
  String unexpectedUploadError(Object error) {
    return 'Unerwarteter Fehler beim Bild-Upload: $error';
  }

  @override
  String get noImageSelected => 'Kein Bild ausgewählt.';

  @override
  String imagePickError(Object error) {
    return 'Fehler bei der Bildauswahl oder Zuschneiden: $error';
  }
}

/// The translations for German (`de_Temp`).
class AppLocalizationsDeTemp extends AppLocalizationsDe {
  AppLocalizationsDeTemp() : super('de_Temp');

  @override
  String get addOrJoinGroupRequiredFieldError =>
      'Bitte füllen Sie alle erforderlichen Felder aus.';

  @override
  String get addOrJoinGroupTitle => 'Gruppe erstellen';

  @override
  String get addOrJoinGroupCreateHint => 'Gruppenname eingeben';

  @override
  String get addOrJoinGroupGroupNameEmpty =>
      'Bitte geben Sie einen Gruppennamen ein.';

  @override
  String get addOrJoinGroupDescriptionHint =>
      'Eine kurze Beschreibung Ihrer Gruppe';

  @override
  String get addOrJoinGroupLocationHint => 'Wo befindet sich Ihre Gruppe?';

  @override
  String get addOrJoinGroupCreateButton => 'Gruppe erstellen';

  @override
  String get addPassiveMemberTitle => 'Passives Mitglied hinzufügen';

  @override
  String get addPassiveMemberFirstNameLabel => 'Vorname';

  @override
  String get addPassiveMemberLastNameLabel => 'Nachname';

  @override
  String get addPassiveMemberLastNameError =>
      'Bitte geben Sie einen Nachnamen ein.';

  @override
  String get addPassiveMemberFirstNameError =>
      'Bitte geben Sie einen Vornamen ein.';

  @override
  String get addPassiveMemberAddButton => 'Hinzufügen';

  @override
  String get addPassiveMemberCancelButton => 'Abbrechen';

  @override
  String addPassiveMemberSuccess(String firstName) {
    return '$firstName wurde erfolgreich hinzugefügt.';
  }

  @override
  String addPassiveMemberError(String error) {
    return 'Fehler beim Hinzufügen des Mitglieds: $error';
  }

  @override
  String get enterLocationHint => 'Ort eingeben';

  @override
  String get enterDescriptionHint => 'Beschreibung eingeben';

  @override
  String get groupPageRoleAdmin => 'Rolle: Admin';

  @override
  String get groupPageRoleMember => 'Rolle: Mitglied';

  @override
  String get shareGroupIdInstruction =>
      'Teilen Sie diese Gruppen-ID mit anderen, damit sie der Gruppe beitreten können:';

  @override
  String get groupIdCopied => 'Gruppen-ID kopiert!';

  @override
  String get copyButton => 'Kopieren';

  @override
  String get menuTitle => 'Menü';

  @override
  String get newGroupTitle => 'Neue Gruppe erstellen';

  @override
  String get enterGroupName => 'Bitte geben Sie einen Gruppennamen ein.';

  @override
  String groupCreatedSuccess(String groupName) {
    return 'Gruppe \"$groupName\" erfolgreich erstellt!';
  }

  @override
  String createGroupError(String error) {
    return 'Fehler beim Erstellen der Gruppe: $error';
  }

  @override
  String get noGroupSelectedError =>
      'Bitte erstellen oder treten Sie einer Gruppe bei, um diese Funktion zu nutzen.';

  @override
  String get groupNameLabel => 'Gruppenname';

  @override
  String get locationLabel => 'Ort';

  @override
  String get descriptionLabel => 'Beschreibung';

  @override
  String get createButtonText => 'Erstellen';

  @override
  String get fillRequiredFields =>
      'Bitte füllen Sie alle erforderlichen Felder aus.';

  @override
  String get groupName => 'Gruppenname';

  @override
  String get groupDescription => 'Gruppenbeschreibung';

  @override
  String get appTitle => 'Famka';

  @override
  String get groupLocation => 'Ort';

  @override
  String get inviteUserPrompt =>
      'Geben Sie die Profil-ID des Benutzers ein, den Sie einladen möchten';

  @override
  String get userProfileIdHint => 'Benutzerprofil-ID eingeben';

  @override
  String get enterProfileIdError =>
      'Bitte geben Sie eine gültige Profil-ID ein';

  @override
  String get addButtonText => 'Hinzufügen';

  @override
  String get cancelButtonText => 'Abbrechen';

  @override
  String get noCurrentUserError =>
      'Fehler: Kein angemeldeter Benutzer verfügbar. Bitte melden Sie sich an.';

  @override
  String get noActiveGroupError =>
      'Es konnten keine Gruppen geladen werden oder es ist keine aktive Gruppe vorhanden.';

  @override
  String loadingGroupsError(String error) {
    return 'Fehler beim Laden der Gruppen: $error';
  }

  @override
  String get groupsDeletedError =>
      'Alle Gruppen wurden gelöscht oder konnten nicht geladen werden.';

  @override
  String get unknownError => 'Ein unbekannter Fehler ist aufgetreten.';

  @override
  String get createGroupNotImplemented =>
      'Gruppen-Erstellungsfunktion noch nicht implementiert.';

  @override
  String get createGroupButtonText => 'Neue Gruppe erstellen';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get groupsTitle => 'Gruppen';

  @override
  String loadingErrorWithDetails(String error) {
    return 'Fehler beim Laden: $error';
  }

  @override
  String get noGroupsJoined => 'Sie sind noch keiner Gruppe beigetreten.';

  @override
  String get imprintTitle => 'Impressum';

  @override
  String get languageTitle => 'Setup';

  @override
  String get languageSettingTitle => 'Sprache auswählen';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get closeButton => 'Schließen';

  @override
  String get loginScreenTitle => 'Anmeldung';

  @override
  String get emailInputLabel => 'E-Mail-Adresse';

  @override
  String get emailInputHint => 'E-Mail-Adresse eingeben';

  @override
  String get passwordInputLabel => 'Passwort';

  @override
  String get passwordInputHint => 'Passwort eingeben';

  @override
  String get checkInputsError => 'Bitte überprüfen Sie Ihre Eingaben.';

  @override
  String get loginButtonText => 'Anmelden';

  @override
  String get newHereButtonText => 'Neu hier? Folgen Sie mir!';

  @override
  String get notRegisteredYetText => 'Ich bin noch nicht registriert!';

  @override
  String get firebaseUserNotFound => 'Benutzer nicht in Firebase gefunden.';

  @override
  String get firestoreUserNotFound =>
      'Benutzerdaten nicht in Firestore gefunden.';

  @override
  String loginFailedGeneric(String message) {
    return 'Anmeldung fehlgeschlagen: $message';
  }

  @override
  String get loginFailedUserNotFound =>
      'Kein Benutzer für diese E-Mail-Adresse gefunden.';

  @override
  String get loginFailedWrongPassword =>
      'Falsches Passwort für diese E-Mail-Adresse.';

  @override
  String get googleLoginFailedNoUser =>
      'Google-Anmeldung fehlgeschlagen: Kein Firebase-Benutzer erhalten.';

  @override
  String get googleLoginNewUserCreated =>
      'Neues Google-Benutzerprofil erstellt.';

  @override
  String get googleLoginSuccess => 'Google-Benutzer erfolgreich angemeldet.';

  @override
  String googleLoginExistingUser(Object uid) {
    return 'Google-Benutzer in Firestore gefunden: $uid';
  }

  @override
  String get googleLoginFailedFirestoreLoad =>
      'Fehler: Benutzerdaten konnten nach der Erstellung nicht geladen werden.';

  @override
  String get googleLoginFailedDifferentCredential =>
      'Ein Konto mit dieser E-Mail-Adresse existiert bereits, aber mit einer anderen Anmeldemethode.';

  @override
  String get googleLoginAborted => 'Google-Anmeldung vom Benutzer abgebrochen.';

  @override
  String googleLoginUnexpectedError(String error) {
    return 'Unerwarteter Fehler bei der Google-Anmeldung: $error';
  }

  @override
  String get signInWithGoogleTooltip => 'Mit Google anmelden';

  @override
  String get signInWithAppleNotImplemented =>
      'Apple-Anmeldung noch nicht implementiert.';

  @override
  String get signInWithAppleTooltip => 'Mit Apple anmelden';

  @override
  String get appleLoginNewUserCreated => 'Neues Apple-Benutzerprofil erstellt.';

  @override
  String get appleLoginSuccess => 'Apple-Benutzer erfolgreich angemeldet.';

  @override
  String appleLoginExistingUser(Object uid) {
    return 'Apple-Benutzer in Firestore gefunden: $uid';
  }

  @override
  String get appleLoginFailedFirestoreLoad =>
      'Fehler: Benutzerdaten konnten nach der Erstellung nicht geladen werden.';

  @override
  String get appleLoginFailedDifferentCredential =>
      'Ein Konto mit dieser E-Mail-Adresse existiert bereits, aber mit einer anderen Anmeldemethode.';

  @override
  String get appleLoginAborted => 'Apple-Anmeldung abgebrochen.';

  @override
  String appleLoginUnexpectedError(String error) {
    return 'Unerwarteter Fehler bei der Apple-Anmeldung: $error';
  }

  @override
  String get appleLoginUnsupportedPlatform =>
      'Apple-Anmeldung wird nur auf iOS-Geräten unterstützt.';

  @override
  String get emailValidationEmpty => 'E-Mail-Adresse darf nicht leer sein';

  @override
  String get emailValidationInvalid =>
      'Bitte geben Sie eine gültige E-Mail-Adresse ein.';

  @override
  String get passwordValidationMinLength => 'Mind. 8 Zeichen';

  @override
  String get passwordValidationMaxLength => 'Max. 50 Zeichen';

  @override
  String get passwordValidationLowercase => 'Mind. ein Kleinbuchstabe';

  @override
  String get passwordValidationUppercase => 'Mind. ein Großbuchstabe';

  @override
  String get passwordValidationDigit => 'Mind. eine Ziffer';

  @override
  String get passwordValidationSpecialChar => 'Mind. ein Sonderzeichen';

  @override
  String get appointmentTitle => 'Termin';

  @override
  String get appointmentTitleLabel => 'Termintitel';

  @override
  String get appointmentTitleHint => 'Termintitel';

  @override
  String get dateLabel => 'Datum';

  @override
  String get dateHint => 'JJJJ-MM-TT';

  @override
  String get timeHint => 'HH:MM';

  @override
  String get allDayLabel => 'Ganztägig';

  @override
  String get startTimeLabel => 'Startzeit';

  @override
  String get endTimeLabel => 'Endzeit';

  @override
  String get locationHint => 'Terminort';

  @override
  String get descriptionHint => 'Details zum Termin (optional)';

  @override
  String createdByUser(String creator) {
    return 'Erstellt von: $creator';
  }

  @override
  String forGroup(String groupName) {
    return 'Für Gruppe: $groupName';
  }

  @override
  String get validatorTitleEmpty => 'Bitte geben Sie einen Titel ein';

  @override
  String get validatorTitleLength => 'Maximal 80 Zeichen erlaubt';

  @override
  String get validatorTitleEmojis => 'Keine Emojis erlaubt';

  @override
  String get validatorLocationEmpty => 'Bitte geben Sie einen Ort ein';

  @override
  String get validatorLocationInvalidChars => 'Ungültige Zeichen im Ort';

  @override
  String get validatorDescriptionLength => 'Maximal 500 Zeichen erlaubt';

  @override
  String get validatorRepeatCountEmpty => 'Bitte geben Sie eine Zahl ein';

  @override
  String get validatorRepeatCountInvalid => 'Ungültige Zahl (muss > 0 sein)';

  @override
  String get validatorRepeatCountMax => 'Max. 365 Wiederholungen';

  @override
  String get snackbarFillAllFields =>
      'Bitte füllen Sie alle Felder korrekt aus.';

  @override
  String get snackbarAddImage => 'Bitte geben Sie Ihrem Ereignis ein Gesicht.';

  @override
  String get snackbarSelectParticipants =>
      'Für wen ist der Termin? Bitte wählen Sie mindestens einen Teilnehmer aus.';

  @override
  String get snackbarDateParseError =>
      'Fehler beim Parsen von Datum oder Uhrzeit.';

  @override
  String get snackbarCreatorError =>
      'Fehler: Terminersteller konnte nicht ermittelt werden.';

  @override
  String get snackbarRecurringEventSaved => 'Terminserie gespeichert!';

  @override
  String get snackbarSingleEventSaved => 'Termin gespeichert!';

  @override
  String snackbarSaveError(String error) {
    return 'Fehler beim Speichern des Termins: $error';
  }

  @override
  String get repeatDaily => 'Täglich';

  @override
  String get repeatWeekly => 'Wöchentlich';

  @override
  String get repeatMonthly => 'Monatlich';

  @override
  String get repeatYearly => 'Jährlich';

  @override
  String get reminderOneHour => '1 Stunde';

  @override
  String get reminderOneDay => '1 Tag';

  @override
  String get reminder30Minutes => '30 Minuten';

  @override
  String get validateDateEmpty => 'Bitte wählen Sie ein Datum aus';

  @override
  String get validateDateInvalid => 'Ungültiges Datum';

  @override
  String get validateDateInPast =>
      'Datum kann nicht in der Vergangenheit liegen';

  @override
  String get validateTimeEmpty => 'Bitte geben Sie eine Zeit ein';

  @override
  String get validateTimeInvalid => 'Ungültige Zeit';

  @override
  String get eventParticipantsTitle => 'Für wen ist der Termin?';

  @override
  String errorLoadingMembers(String error) {
    return 'Fehler: $error';
  }

  @override
  String get noMembersFound => 'Keine Mitglieder gefunden.';

  @override
  String get addImageTitle => 'Foto oder Piktogramm hinzufügen';

  @override
  String get addImageDescription =>
      'Das ausgewählte Bild ersetzt den Titel des Termins in der Kalenderansicht.';

  @override
  String get repeatLabel => 'Wiederholen';

  @override
  String get repeatDropdownLabel => 'Wiederholung';

  @override
  String get numberOfRepeatsLabel => 'Anzahl der Wiederholungen';

  @override
  String get numberOfRepeatsHint => 'z.B. 5 (inkl. diesem Termin)';

  @override
  String get reminderLabel => 'Erinnerung';

  @override
  String get reminderBeforeLabel => 'Erinnerung vor';

  @override
  String get saveButtonText => 'Speichern';

  @override
  String groupAvatarLoadingError(String error) {
    return 'Fehler beim Laden des Gruppen-Avatars: $error';
  }

  @override
  String singleEventAvatarLoadingError(String error) {
    return 'Fehler beim Laden des Avatars in SingleEventAvatar: $error';
  }

  @override
  String imageUploadSuccess(String downloadUrl) {
    return 'Bild erfolgreich hochgeladen und aktualisiert.';
  }

  @override
  String get imageDeletedSuccess => 'Bild erfolgreich gelöscht.';

  @override
  String imageDeleteError(String error) {
    return 'Fehler beim Löschen des Bildes: $error';
  }

  @override
  String get imageUploadAborted =>
      'Bild-Upload abgebrochen oder fehlgeschlagen.';

  @override
  String imageUploadError(String error) {
    return 'Fehler beim Bild-Upload: $error';
  }

  @override
  String get manageMembersUpdateSuccess =>
      'Mitglieder erfolgreich aktualisiert.';

  @override
  String manageMembersUpdateError(String error) {
    return 'Fehler beim Aktualisieren der Mitglieder: $error';
  }

  @override
  String get manageMembersTitle => 'Mitglieder verwalten';

  @override
  String get manageMembersCurrentTitle => 'Aktuelle Mitglieder';

  @override
  String get manageMembersRoleAdmin => '(Admin)';

  @override
  String get manageMembersRoleMember => '(Mitglied)';

  @override
  String get manageMembersRolePassive => '(Passiv)';

  @override
  String get manageMembersNoEmailPhone => 'Keine E-Mail/Telefonnummer';

  @override
  String get manageMembersSavingButton => 'Wird gespeichert...';

  @override
  String get manageMembersSaveChangesButton => 'Änderungen speichern';

  @override
  String get deleteAppointment => 'Termin löschen';

  @override
  String confirmDeleteAppointment(Object eventName) {
    return 'Möchten Sie \"$eventName\" wirklich dauerhaft löschen?';
  }

  @override
  String get editDescription => 'Beschreibung bearbeiten';

  @override
  String participants(Object names) {
    return 'Teilnehmer: $names';
  }

  @override
  String get menuLabel => 'Menü';

  @override
  String get calendarLabel => 'Kalender';

  @override
  String get appointmentLabel => 'Termin';

  @override
  String get galleryLabel => 'Galerie';

  @override
  String get piktogrammeLabe => 'Piktogramme';

  @override
  String get gallerySourceCamera => 'Kamera';

  @override
  String get gallerySourceGallery => 'Galerie';

  @override
  String get timeAllDay => 'Uhrzeit: Ganztägig';

  @override
  String timeAt(Object time) {
    return 'Uhrzeit: $time Uhr';
  }

  @override
  String location(Object location) {
    return 'Ort: $location';
  }

  @override
  String description(Object description) {
    return 'Beschreibung: $description';
  }

  @override
  String get noDescription => 'Keine Beschreibung';

  @override
  String appointmentsFor(Object name) {
    return 'Termine für $name';
  }

  @override
  String get saveButton => 'Speichern';

  @override
  String get noChangesToSave => 'Keine Änderungen zum Speichern.';

  @override
  String get descriptionUpdateSuccess =>
      'Beschreibung erfolgreich aktualisiert.';

  @override
  String descriptionUpdateError(Object error) {
    return 'Fehler beim Aktualisieren der Beschreibung: $error';
  }

  @override
  String get imageLoadError => 'Bild konnte nicht geladen werden';

  @override
  String get deleteImageTitle => 'Bild löschen?';

  @override
  String get deleteImageDescription =>
      'Möchten Sie dieses Bild wirklich aus der Galerie entfernen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get deleteImageButton => 'Löschen';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get imageUploadSuccessSelectNow =>
      'Bild erfolgreich hochgeladen. Bitte auswählen.';

  @override
  String get passwordShowTooltip => 'Passwort anzeigen';

  @override
  String get passwordHideTooltip => 'Passwort verbergen';

  @override
  String get noUserDataError => 'Keine Benutzerdaten verfügbar.';

  @override
  String get dateFormat => 'yyyy-MM-dd';

  @override
  String get localeGerman => 'de';

  @override
  String errorLoadingAvatar(Object avatarUrl, Object exception) {
    return 'Fehler beim Laden des Avatars von $avatarUrl: $exception';
  }

  @override
  String get httpPrefix => 'http://';

  @override
  String get httpsPrefix => 'https://';

  @override
  String get assetsPrefix => 'assets/';

  @override
  String get defaultAvatarPath => 'assets/fotos/default.jpg';

  @override
  String errorLoadingGroupAvatar(Object exception) {
    return 'Fehler beim Laden des Gruppen-Avatars in ProfilAvatarRow: $exception';
  }

  @override
  String get cropImageTitle => 'Bild zuschneiden';

  @override
  String compressedImageName(Object timestamp) {
    return 'compressed_$timestamp.jpg';
  }

  @override
  String get compressionFailed => '❌ Komprimierung fehlgeschlagen.';

  @override
  String uploadSuccess(Object downloadUrl) {
    return '✅ Bild erfolgreich zu Firebase Storage hochgeladen: $downloadUrl';
  }

  @override
  String uploadError(Object state) {
    return '❌ Fehler beim Hochladen des Bildes: $state';
  }

  @override
  String errorLoadingActiveGroup(Object error) {
    return 'Fehler beim Laden der aktiven Gruppe: $error';
  }

  @override
  String get menuScreenRoute => '/menuScreen';

  @override
  String get calendarScreenRoute => '/calendarScreen';

  @override
  String get appointmentScreenRoute => '/appointmentScreen';

  @override
  String get logoutButton => 'Ausloggen';

  @override
  String get addGroupButton => 'Gruppe hinzufügen';

  @override
  String get invalidEmailError => 'Ungültige E-Mail Adresse';

  @override
  String get invalidPhoneNumberError =>
      'Ungültige Telefonnummer (min. 8 Ziffern, nur Zahlen)';

  @override
  String get profilePictureUpdated => 'Profilbild aktualisiert.';

  @override
  String get profilePictureUpdateError =>
      'Fehler beim Aktualisieren des Profilbilds:';

  @override
  String get profileInfoSaved => 'Profilinformationen gespeichert.';

  @override
  String get profileInfoSaveError =>
      'Fehler beim Speichern der Profilinformationen:';

  @override
  String get logoutError => 'Fehler beim Abmelden:';

  @override
  String get profileIdTitle => 'Deine Profil-ID';

  @override
  String get profileIdDescription =>
      'Dies ist deine persönliche ID. Du kannst sie mit anderen teilen, damit sie dich zu Gruppen einladen können.';

  @override
  String get profileIdCopied => 'Profil-ID kopiert!';

  @override
  String get enterPhoneNumber => 'Telefonnummer eingeben';

  @override
  String get additionalInfo => 'Zusätzliche Infos';

  @override
  String get enterEmailAddress => 'E-Mail Adresse eingeben';

  @override
  String get onboardingComplete =>
      'Daten wurden gespeichert und Onboarding abgeschlossen.';

  @override
  String get telefonnummerEingeben => 'Telefonnummer eingeben';

  @override
  String get emailAdresseEingeben => 'E-Mail Adresse eingeben';

  @override
  String get zusaetzlicheInfos => 'Zusätzliche Infos';

  @override
  String get keineGruppenGefunden => 'Keine Gruppen gefunden.';

  @override
  String get profilGesichtGeben => 'Geben Sie Ihrem Profil ein Gesicht';

  @override
  String get fortfahren => 'Fortfahren';

  @override
  String get ungueltigeEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get vorname => 'Vorname';

  @override
  String get bitteVornameEingeben => 'Bitte Vorname eingeben';

  @override
  String get nachname => 'Nachname';

  @override
  String get nachnameEingeben => 'Nachname eingeben';

  @override
  String get bitteNachnameEingeben => 'Bitte Nachname eingeben';

  @override
  String get emailAdresse => 'E-Mail-Adresse';

  @override
  String get telefonnummerOptional => 'Telefonnummer (optional)';

  @override
  String groupDeletedSuccess(Object groupName) {
    return 'Gruppe \"$groupName\" erfolgreich gelöscht.';
  }

  @override
  String groupDeleteError(Object error) {
    return 'Fehler beim Löschen der Gruppe: $error';
  }

  @override
  String userInviteError(Object error) {
    return 'Fehler beim Einladen des Benutzers: $error';
  }

  @override
  String get userNotFound => 'Benutzer mit dieser ID nicht gefunden.';

  @override
  String get userAlreadyMember =>
      'Benutzer ist bereits Mitglied dieser Gruppe.';

  @override
  String get membersManagementComplete => 'Mitgliederverwaltung abgeschlossen.';

  @override
  String groupAvatarUpdateError(Object error) {
    return 'Fehler beim Speichern des Gruppenbilds: $error';
  }

  @override
  String get groupAvatarUpdateSuccess =>
      'Gruppenbild erfolgreich aktualisiert!';

  @override
  String debugAvatarChange(Object newAvatarUrl) {
    return 'DEBUG: _onAvatarChanged in GroupPage aufgerufen mit newAvatarUrl: $newAvatarUrl';
  }

  @override
  String get changesSaved => 'Änderungen gespeichert!';

  @override
  String groupDataLoadError(Object error) {
    return 'Fehler beim Laden der Gruppendaten oder Benutzer-ID: $error';
  }

  @override
  String get groupLoadError =>
      'Fehler: Gruppe konnte nicht geladen werden oder Benutzer-ID fehlt.';

  @override
  String get members => 'Mitglieder';

  @override
  String calendarEventsLoaded(Object groupId, Object count) {
    return 'Kalender: Events für Gruppe $groupId geladen: $count Events';
  }

  @override
  String eventLoadingError(Object error) {
    return 'Fehler beim Laden der Termine: $error';
  }

  @override
  String get eventDeletedSuccess => 'Termin erfolgreich gelöscht.';

  @override
  String get eventDeleteTargetNotFound =>
      'Fehler: Zu löschender Termin nicht gefunden.';

  @override
  String eventDeletionError(Object error) {
    return 'Fehler beim Löschen des Termins: $error';
  }

  @override
  String get placeholderViewText => 'Hier könnte eine weitere Ansicht sein.';

  @override
  String get eventListLoading => 'Starte Laden der Events...';

  @override
  String eventListLoadingForGroup(Object groupId) {
    return 'Lade Events für Gruppe $groupId';
  }

  @override
  String eventListLoadingCount(Object count) {
    return '$count Events geladen';
  }

  @override
  String eventListLoadingError(Object error) {
    return 'Fehler beim Laden der Events: $error';
  }

  @override
  String get eventListNoEvents => 'Keine Termine für diese Gruppe gefunden.';

  @override
  String get eventListTodayHeader => 'HEUTE';

  @override
  String get eventListTomorrowHeader => 'MORGEN';

  @override
  String get eventListDeleteConfirmTitle => 'Termin löschen';

  @override
  String eventListDeleteConfirmMessage(Object eventName) {
    return 'Möchtest du \"$eventName\" wirklich löschen?';
  }

  @override
  String get eventListCancelButton => 'Abbrechen';

  @override
  String get eventListDeleteButton => 'Löschen';

  @override
  String get eventListDeletedSuccess => 'Termin erfolgreich gelöscht.';

  @override
  String eventListTimeFormat(Object time) {
    return '$time Uhr';
  }

  @override
  String oldEventsFoundMessage(Object count) {
    return 'Es wurden $count alte Ereignisse gefunden. Möchten Sie diese löschen, um Speicherplatz zu sparen?';
  }

  @override
  String get deleteOldEventsTitle => 'Alte Ereignisse löschen';

  @override
  String deleteOldEventsConfirmation(Object count) {
    return 'Möchten Sie $count Ereignisse löschen, die älter als 14 Tage sind? Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String oldEventsDeletedSuccess(Object count) {
    return '$count alte Ereignisse wurden erfolgreich gelöscht.';
  }

  @override
  String oldEventsDeletionError(Object error) {
    return 'Fehler beim Löschen der alten Ereignisse: $error';
  }

  @override
  String get selectImage => 'Bild auswählen';

  @override
  String get selectProfileImage => 'Profilbild auswählen';

  @override
  String get selectGroupImage => 'Gruppenbild auswählen';

  @override
  String get selectEventImage => 'Terminbild auswählen';

  @override
  String get selectFromGallery => 'Aus Galerie wählen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromStandard => 'Oder aus Standardbildern wählen:';

  @override
  String get cancelSelection => 'Abbrechen';

  @override
  String get imageSelectionCancelled => 'Bildauswahl abgebrochen.';

  @override
  String get standardImageSet => 'Bild erfolgreich als Standardbild gesetzt.';

  @override
  String get croppingCancelled => 'Zuschneiden abgebrochen.';

  @override
  String get processingError =>
      'Fehler bei der Bildverarbeitung für den Upload.';

  @override
  String get noUserIdError =>
      'Fehler: Keine Benutzer-ID verfügbar. Bitte melden Sie sich an.';

  @override
  String firebaseUploadError(Object error) {
    return 'Fehler beim Upload zu Firebase Storage: $error';
  }

  @override
  String unexpectedUploadError(Object error) {
    return 'Unerwarteter Fehler beim Bild-Upload: $error';
  }

  @override
  String get noImageSelected => 'Kein Bild ausgewählt.';

  @override
  String imagePickError(Object error) {
    return 'Fehler bei der Bildauswahl oder Zuschneiden: $error';
  }
}
