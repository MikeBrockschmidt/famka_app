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
  /// In en, this message translates to:
  /// **'Please fill out all required fields.'**
  String get addOrJoinGroupRequiredFieldError;

  /// No description provided for @addOrJoinGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get addOrJoinGroupTitle;

  /// No description provided for @addOrJoinGroupCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name'**
  String get addOrJoinGroupCreateHint;

  /// No description provided for @addOrJoinGroupGroupNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name.'**
  String get addOrJoinGroupGroupNameEmpty;

  /// No description provided for @addOrJoinGroupDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'A short description of your group'**
  String get addOrJoinGroupDescriptionHint;

  /// No description provided for @addOrJoinGroupLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Where is your group located?'**
  String get addOrJoinGroupLocationHint;

  /// No description provided for @addOrJoinGroupCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get addOrJoinGroupCreateButton;

  /// No description provided for @addPassiveMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Passive Member'**
  String get addPassiveMemberTitle;

  /// No description provided for @addPassiveMemberFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get addPassiveMemberFirstNameLabel;

  /// No description provided for @addPassiveMemberLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get addPassiveMemberLastNameLabel;

  /// No description provided for @addPassiveMemberLastNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a last name.'**
  String get addPassiveMemberLastNameError;

  /// No description provided for @addPassiveMemberFirstNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a first name.'**
  String get addPassiveMemberFirstNameError;

  /// No description provided for @addPassiveMemberAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addPassiveMemberAddButton;

  /// No description provided for @addPassiveMemberCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addPassiveMemberCancelButton;

  /// Success message when adding a passive member
  ///
  /// In en, this message translates to:
  /// **'{firstName} has been successfully added.'**
  String addPassiveMemberSuccess(String firstName);

  /// Error message when adding a passive member fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add member: {error}'**
  String addPassiveMemberError(String error);

  /// No description provided for @enterLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter location'**
  String get enterLocationHint;

  /// No description provided for @enterDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescriptionHint;

  /// No description provided for @groupPageRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get groupPageRoleAdmin;

  /// No description provided for @groupPageRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupPageRoleMember;

  /// No description provided for @shareGroupIdInstruction.
  ///
  /// In en, this message translates to:
  /// **'Share this group ID with your friends!'**
  String get shareGroupIdInstruction;

  /// No description provided for @groupIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Group ID copied!'**
  String get groupIdCopied;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menü'**
  String get menuTitle;

  /// No description provided for @newGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Group'**
  String get newGroupTitle;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name.'**
  String get enterGroupName;

  /// Success message when creating a group
  ///
  /// In en, this message translates to:
  /// **'Group \"{groupName}\" successfully created!'**
  String groupCreatedSuccess(String groupName);

  /// Error message when creating a group
  ///
  /// In en, this message translates to:
  /// **'Error creating group: {error}'**
  String createGroupError(String error);

  /// No description provided for @noGroupSelectedError.
  ///
  /// In en, this message translates to:
  /// **'Please create or join a group to use this feature.'**
  String get noGroupSelectedError;

  /// No description provided for @groupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupNameLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @createButtonText.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButtonText;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get fillRequiredFields;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @groupDescription.
  ///
  /// In en, this message translates to:
  /// **'Group Description'**
  String get groupDescription;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Famka'**
  String get appTitle;

  /// No description provided for @groupLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get groupLocation;

  /// No description provided for @inviteUserPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the profile ID of the user you want to invite'**
  String get inviteUserPrompt;

  /// No description provided for @userProfileIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter user profile ID'**
  String get userProfileIdHint;

  /// No description provided for @enterProfileIdError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid profile ID'**
  String get enterProfileIdError;

  /// No description provided for @addButtonText.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButtonText;

  /// No description provided for @cancelButtonText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonText;

  /// No description provided for @noCurrentUserError.
  ///
  /// In en, this message translates to:
  /// **'Error: No current user available. Please sign in.'**
  String get noCurrentUserError;

  /// No description provided for @noActiveGroupError.
  ///
  /// In en, this message translates to:
  /// **'Could not load any groups or no active group to display.'**
  String get noActiveGroupError;

  /// Error message when loading groups
  ///
  /// In en, this message translates to:
  /// **'Error loading groups: {error}'**
  String loadingGroupsError(String error);

  /// No description provided for @groupsDeletedError.
  ///
  /// In en, this message translates to:
  /// **'All groups have been deleted or could not be loaded.'**
  String get groupsDeletedError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get unknownError;

  /// No description provided for @createGroupNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Create group function not yet implemented.'**
  String get createGroupNotImplemented;

  /// No description provided for @createGroupButtonText.
  ///
  /// In en, this message translates to:
  /// **'Create New Group'**
  String get createGroupButtonText;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @groupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTitle;

  /// General loading error message
  ///
  /// In en, this message translates to:
  /// **'Loading Error: {error}'**
  String loadingErrorWithDetails(String error);

  /// No description provided for @noGroupsJoined.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t joined any groups yet.'**
  String get noGroupsJoined;

  /// No description provided for @imprintTitle.
  ///
  /// In en, this message translates to:
  /// **'Imprint'**
  String get imprintTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageSettingTitle;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @loginScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginScreenTitle;

  /// No description provided for @emailInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailInputLabel;

  /// No description provided for @emailInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get emailInputHint;

  /// No description provided for @passwordInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordInputLabel;

  /// No description provided for @passwordInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordInputHint;

  /// No description provided for @checkInputsError.
  ///
  /// In en, this message translates to:
  /// **'Please check your inputs'**
  String get checkInputsError;

  /// No description provided for @loginButtonText.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButtonText;

  /// No description provided for @newHereButtonText.
  ///
  /// In en, this message translates to:
  /// **'New here? Follow me!'**
  String get newHereButtonText;

  /// No description provided for @notRegisteredYetText.
  ///
  /// In en, this message translates to:
  /// **'I\'m not registered yet!'**
  String get notRegisteredYetText;

  /// No description provided for @firebaseUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found in Firebase.'**
  String get firebaseUserNotFound;

  /// No description provided for @firestoreUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User data not found in Firestore.'**
  String get firestoreUserNotFound;

  /// Generic login error message
  ///
  /// In en, this message translates to:
  /// **'Login failed: {message}'**
  String loginFailedGeneric(String message);

  /// No description provided for @loginFailedUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found for this email.'**
  String get loginFailedUserNotFound;

  /// No description provided for @loginFailedWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password for this email.'**
  String get loginFailedWrongPassword;

  /// No description provided for @googleLoginFailedNoUser.
  ///
  /// In en, this message translates to:
  /// **'Google login failed: No Firebase user received.'**
  String get googleLoginFailedNoUser;

  /// No description provided for @googleLoginNewUserCreated.
  ///
  /// In en, this message translates to:
  /// **'New Google user profile created.'**
  String get googleLoginNewUserCreated;

  /// No description provided for @googleLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Google user logged in successfully.'**
  String get googleLoginSuccess;

  /// Existing Google user found
  ///
  /// In en, this message translates to:
  /// **'Google user found in Firestore: {uid}'**
  String googleLoginExistingUser(Object uid);

  /// No description provided for @googleLoginFailedFirestoreLoad.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not load user data after creation.'**
  String get googleLoginFailedFirestoreLoad;

  /// No description provided for @googleLoginFailedDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email but with a different sign-in method.'**
  String get googleLoginFailedDifferentCredential;

  /// No description provided for @googleLoginAborted.
  ///
  /// In en, this message translates to:
  /// **'Google login aborted by user.'**
  String get googleLoginAborted;

  /// Unexpected error during Google login
  ///
  /// In en, this message translates to:
  /// **'Unexpected Google login error: {error}'**
  String googleLoginUnexpectedError(String error);

  /// No description provided for @signInWithGoogleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogleTooltip;

  /// No description provided for @signInWithAppleNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Apple login not yet implemented.'**
  String get signInWithAppleNotImplemented;

  /// No description provided for @signInWithAppleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithAppleTooltip;

  /// No description provided for @showPasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPasswordTooltip;

  /// No description provided for @hidePasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePasswordTooltip;

  /// No description provided for @emailValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email address cannot be empty'**
  String get emailValidationEmpty;

  /// No description provided for @emailValidationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get emailValidationInvalid;

  /// No description provided for @passwordValidationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters'**
  String get passwordValidationMinLength;

  /// No description provided for @passwordValidationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Max. 50 characters'**
  String get passwordValidationMaxLength;

  /// No description provided for @passwordValidationLowercase.
  ///
  /// In en, this message translates to:
  /// **'Min. one lowercase letter'**
  String get passwordValidationLowercase;

  /// No description provided for @passwordValidationUppercase.
  ///
  /// In en, this message translates to:
  /// **'Min. one uppercase letter'**
  String get passwordValidationUppercase;

  /// No description provided for @passwordValidationDigit.
  ///
  /// In en, this message translates to:
  /// **'Min. one digit'**
  String get passwordValidationDigit;

  /// No description provided for @passwordValidationSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'Min. one special character'**
  String get passwordValidationSpecialChar;

  /// No description provided for @appointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointmentTitle;

  /// No description provided for @appointmentTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Appointment Title'**
  String get appointmentTitleLabel;

  /// No description provided for @appointmentTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Appointment Title'**
  String get appointmentTitleHint;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @dateHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get dateHint;

  /// No description provided for @timeHint.
  ///
  /// In en, this message translates to:
  /// **'HH:MM'**
  String get timeHint;

  /// No description provided for @allDayLabel.
  ///
  /// In en, this message translates to:
  /// **'All Day'**
  String get allDayLabel;

  /// No description provided for @startTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTimeLabel;

  /// No description provided for @endTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTimeLabel;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'Appointment Location'**
  String get locationHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Details about the appointment (optional)'**
  String get descriptionHint;

  /// Creator of an item
  ///
  /// In en, this message translates to:
  /// **'Created by: {creator}'**
  String createdByUser(String creator);

  /// Group association of an item
  ///
  /// In en, this message translates to:
  /// **'For Group: {groupName}'**
  String forGroup(String groupName);

  /// No description provided for @validatorTitleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get validatorTitleEmpty;

  /// No description provided for @validatorTitleLength.
  ///
  /// In en, this message translates to:
  /// **'Maximum 80 characters allowed'**
  String get validatorTitleLength;

  /// No description provided for @validatorTitleEmojis.
  ///
  /// In en, this message translates to:
  /// **'No emojis allowed'**
  String get validatorTitleEmojis;

  /// No description provided for @validatorLocationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a location'**
  String get validatorLocationEmpty;

  /// No description provided for @validatorLocationInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Invalid characters in location'**
  String get validatorLocationInvalidChars;

  /// No description provided for @validatorDescriptionLength.
  ///
  /// In en, this message translates to:
  /// **'Maximum 500 characters allowed'**
  String get validatorDescriptionLength;

  /// No description provided for @validatorRepeatCountEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number'**
  String get validatorRepeatCountEmpty;

  /// No description provided for @validatorRepeatCountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid number (must be > 0)'**
  String get validatorRepeatCountInvalid;

  /// No description provided for @validatorRepeatCountMax.
  ///
  /// In en, this message translates to:
  /// **'Max. 365 repetitions'**
  String get validatorRepeatCountMax;

  /// No description provided for @snackbarFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill out all fields correctly.'**
  String get snackbarFillAllFields;

  /// No description provided for @snackbarAddImage.
  ///
  /// In en, this message translates to:
  /// **'Please give your event a face.'**
  String get snackbarAddImage;

  /// No description provided for @snackbarSelectParticipants.
  ///
  /// In en, this message translates to:
  /// **'For whom is the appointment? Please select at least one participant.'**
  String get snackbarSelectParticipants;

  /// No description provided for @snackbarDateParseError.
  ///
  /// In en, this message translates to:
  /// **'Error parsing date or time.'**
  String get snackbarDateParseError;

  /// No description provided for @snackbarCreatorError.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not determine appointment creator.'**
  String get snackbarCreatorError;

  /// No description provided for @snackbarRecurringEventSaved.
  ///
  /// In en, this message translates to:
  /// **'Event series saved!'**
  String get snackbarRecurringEventSaved;

  /// No description provided for @snackbarSingleEventSaved.
  ///
  /// In en, this message translates to:
  /// **'Event saved!'**
  String get snackbarSingleEventSaved;

  /// Error message when saving
  ///
  /// In en, this message translates to:
  /// **'Error saving event: {error}'**
  String snackbarSaveError(String error);

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get repeatYearly;

  /// No description provided for @reminderOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get reminderOneHour;

  /// No description provided for @reminderOneDay.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get reminderOneDay;

  /// No description provided for @reminder30Minutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get reminder30Minutes;

  /// No description provided for @validateDateEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get validateDateEmpty;

  /// No description provided for @validateDateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get validateDateInvalid;

  /// No description provided for @validateDateInPast.
  ///
  /// In en, this message translates to:
  /// **'Date cannot be in the past'**
  String get validateDateInPast;

  /// No description provided for @validateTimeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter time'**
  String get validateTimeEmpty;

  /// No description provided for @validateTimeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid time'**
  String get validateTimeInvalid;

  /// No description provided for @eventParticipantsTitle.
  ///
  /// In en, this message translates to:
  /// **'For whom is the appointment?'**
  String get eventParticipantsTitle;

  /// Error message when loading members
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLoadingMembers(String error);

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get noMembersFound;

  /// No description provided for @addImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add photo or pictogram'**
  String get addImageTitle;

  /// No description provided for @addImageDescription.
  ///
  /// In en, this message translates to:
  /// **'The selected image will replace the event\'s title in the calendar view.'**
  String get addImageDescription;

  /// No description provided for @repeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatLabel;

  /// No description provided for @repeatDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Repetition'**
  String get repeatDropdownLabel;

  /// No description provided for @numberOfRepeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of repetitions'**
  String get numberOfRepeatsLabel;

  /// No description provided for @numberOfRepeatsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5 (incl. this event)'**
  String get numberOfRepeatsHint;

  /// No description provided for @reminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderLabel;

  /// No description provided for @reminderBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder before'**
  String get reminderBeforeLabel;

  /// No description provided for @saveButtonText.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButtonText;

  /// Error message when loading group avatar
  ///
  /// In en, this message translates to:
  /// **'Error loading group avatar: {error}'**
  String groupAvatarLoadingError(String error);

  /// Error message when loading event avatar
  ///
  /// In en, this message translates to:
  /// **'Error loading avatar in SingleEventAvatar: {error}'**
  String singleEventAvatarLoadingError(String error);

  /// No description provided for @errorCreatingGroup.
  ///
  /// In en, this message translates to:
  /// **'Error creating group'**
  String get errorCreatingGroup;

  /// Success message when uploading an image
  ///
  /// In en, this message translates to:
  /// **'Image successfully uploaded: {downloadUrl}'**
  String imageUploadSuccess(String downloadUrl);

  /// No description provided for @imageDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image successfully deleted.'**
  String get imageDeletedSuccess;

  /// Error message when deleting an image
  ///
  /// In en, this message translates to:
  /// **'Error deleting image: {error}'**
  String imageDeleteError(String error);

  /// No description provided for @imageUploadAborted.
  ///
  /// In en, this message translates to:
  /// **'Image upload aborted or failed.'**
  String get imageUploadAborted;

  /// Error message when uploading an image
  ///
  /// In en, this message translates to:
  /// **'Error during image upload: {error}'**
  String imageUploadError(String error);

  /// No description provided for @manageMembersUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Members updated successfully.'**
  String get manageMembersUpdateSuccess;

  /// Error message when updating members
  ///
  /// In en, this message translates to:
  /// **'Failed to update members: {error}'**
  String manageMembersUpdateError(String error);

  /// No description provided for @manageMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Members'**
  String get manageMembersTitle;

  /// No description provided for @manageMembersCurrentTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Members'**
  String get manageMembersCurrentTitle;

  /// No description provided for @manageMembersRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'(Admin)'**
  String get manageMembersRoleAdmin;

  /// No description provided for @manageMembersRoleMember.
  ///
  /// In en, this message translates to:
  /// **'(Member)'**
  String get manageMembersRoleMember;

  /// No description provided for @manageMembersRolePassive.
  ///
  /// In en, this message translates to:
  /// **'(Passive)'**
  String get manageMembersRolePassive;

  /// No description provided for @manageMembersNoEmailPhone.
  ///
  /// In en, this message translates to:
  /// **'No email/phone number'**
  String get manageMembersNoEmailPhone;

  /// No description provided for @manageMembersSavingButton.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get manageMembersSavingButton;

  /// No description provided for @manageMembersSaveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get manageMembersSaveChangesButton;

  /// No description provided for @deleteAppointment.
  ///
  /// In en, this message translates to:
  /// **'Delete Appointment'**
  String get deleteAppointment;

  /// No description provided for @confirmDeleteAppointment.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete \"{eventName}\" permanently?'**
  String confirmDeleteAppointment(Object eventName);

  /// No description provided for @editDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get editDescription;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @menuLabel.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuLabel;

  /// No description provided for @calendarLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarLabel;

  /// No description provided for @appointmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointmentLabel;

  /// No description provided for @galleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryLabel;

  /// No description provided for @piktogrammeLabe.
  ///
  /// In en, this message translates to:
  /// **'Pictograms'**
  String get piktogrammeLabe;

  /// No description provided for @passwordShowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordShowTooltip;

  /// No description provided for @passwordHideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordHideTooltip;

  /// No description provided for @noUserDataError.
  ///
  /// In en, this message translates to:
  /// **'No user data available.'**
  String get noUserDataError;
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
