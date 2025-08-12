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
  String get groupPageRoleAdmin => 'Administrator';

  @override
  String get groupPageRoleMember => 'Mitglied';

  @override
  String get shareGroupIdInstruction =>
      'Teile diese Gruppen-ID mit deinen Freunden!';

  @override
  String get groupIdCopied => 'Gruppen-ID wurde kopiert!';

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
  String get groupNameLabel => 'Gruppenname';

  @override
  String get locationLabel => 'Ort';

  @override
  String get descriptionLabel => 'Beschreibung';

  @override
  String get createButtonText => 'Erstellen';

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
  String get languageTitle => 'Sprache';

  @override
  String get languageSettingTitle => 'Sprache auswählen';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'Englisch';

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
  String get checkInputsError => 'Bitte überprüfen Sie Ihre Eingaben';

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
    return 'Bild erfolgreich hochgeladen: $downloadUrl';
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
}
