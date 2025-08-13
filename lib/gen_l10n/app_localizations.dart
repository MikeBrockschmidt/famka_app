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
  /// **'Role: Admin'**
  String get groupPageRoleAdmin;

  /// No description provided for @groupPageRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Role: Member'**
  String get groupPageRoleMember;

  /// No description provided for @shareGroupIdInstruction.
  ///
  /// In en, this message translates to:
  /// **'Share this Group ID with others so they can join the group:'**
  String get shareGroupIdInstruction;

  /// No description provided for @groupIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Group ID copied!'**
  String get groupIdCopied;

  /// No description provided for @copyButton.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyButton;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @newGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Group'**
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
  /// **'Setup'**
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

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

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
  /// **'Please check your inputs.'**
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
  /// **'Image successfully uploaded and updated.'**
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
  /// **'Participants: {names}'**
  String participants(Object names);

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

  /// No description provided for @gallerySourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get gallerySourceCamera;

  /// No description provided for @gallerySourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallerySourceGallery;

  /// No description provided for @timeAllDay.
  ///
  /// In en, this message translates to:
  /// **'Time: All-day'**
  String get timeAllDay;

  /// No description provided for @timeAt.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String timeAt(Object time);

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location: {location}'**
  String location(Object location);

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description: {description}'**
  String description(Object description);

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @appointmentsFor.
  ///
  /// In en, this message translates to:
  /// **'Appointments for {name}'**
  String appointmentsFor(Object name);

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @noChangesToSave.
  ///
  /// In en, this message translates to:
  /// **'No changes to save.'**
  String get noChangesToSave;

  /// No description provided for @descriptionUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Description successfully updated.'**
  String get descriptionUpdateSuccess;

  /// No description provided for @descriptionUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating description: {error}'**
  String descriptionUpdateError(Object error);

  /// No description provided for @imageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Image could not be loaded'**
  String get imageLoadError;

  /// No description provided for @deleteImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Image?'**
  String get deleteImageTitle;

  /// No description provided for @deleteImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to remove this image from the gallery? This action cannot be undone.'**
  String get deleteImageDescription;

  /// No description provided for @deleteImageButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteImageButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @imageUploadSuccessSelectNow.
  ///
  /// In en, this message translates to:
  /// **'Image successfully uploaded. Please select it.'**
  String get imageUploadSuccessSelectNow;

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

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'yyyy-MM-dd'**
  String get dateFormat;

  /// No description provided for @localeGerman.
  ///
  /// In en, this message translates to:
  /// **'de'**
  String get localeGerman;

  /// No description provided for @errorLoadingAvatar.
  ///
  /// In en, this message translates to:
  /// **'Error loading avatar from {avatarUrl}: {exception}'**
  String errorLoadingAvatar(Object avatarUrl, Object exception);

  /// No description provided for @httpPrefix.
  ///
  /// In en, this message translates to:
  /// **'http://'**
  String get httpPrefix;

  /// No description provided for @httpsPrefix.
  ///
  /// In en, this message translates to:
  /// **'https://'**
  String get httpsPrefix;

  /// No description provided for @assetsPrefix.
  ///
  /// In en, this message translates to:
  /// **'assets/'**
  String get assetsPrefix;

  /// No description provided for @defaultAvatarPath.
  ///
  /// In en, this message translates to:
  /// **'assets/fotos/default.jpg'**
  String get defaultAvatarPath;

  /// No description provided for @errorLoadingGroupAvatar.
  ///
  /// In en, this message translates to:
  /// **'Error loading group avatar in ProfilAvatarRow: {exception}'**
  String errorLoadingGroupAvatar(Object exception);

  /// No description provided for @cropImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get cropImageTitle;

  /// No description provided for @compressedImageName.
  ///
  /// In en, this message translates to:
  /// **'compressed_{timestamp}.jpg'**
  String compressedImageName(Object timestamp);

  /// No description provided for @compressionFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Compression failed.'**
  String get compressionFailed;

  /// No description provided for @uploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Image successfully uploaded to Firebase Storage: {downloadUrl}'**
  String uploadSuccess(Object downloadUrl);

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error uploading image: {state}'**
  String uploadError(Object state);

  /// No description provided for @errorLoadingActiveGroup.
  ///
  /// In en, this message translates to:
  /// **'Error loading active group: {error}'**
  String errorLoadingActiveGroup(Object error);

  /// No description provided for @menuScreenRoute.
  ///
  /// In en, this message translates to:
  /// **'/menuScreen'**
  String get menuScreenRoute;

  /// No description provided for @calendarScreenRoute.
  ///
  /// In en, this message translates to:
  /// **'/calendarScreen'**
  String get calendarScreenRoute;

  /// No description provided for @appointmentScreenRoute.
  ///
  /// In en, this message translates to:
  /// **'/appointmentScreen'**
  String get appointmentScreenRoute;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @addGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get addGroupButton;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmailError;

  /// No description provided for @invalidPhoneNumberError.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number (min. 8 digits, numbers only)'**
  String get invalidPhoneNumberError;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated.'**
  String get profilePictureUpdated;

  /// No description provided for @profilePictureUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile picture:'**
  String get profilePictureUpdateError;

  /// No description provided for @profileInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile information saved.'**
  String get profileInfoSaved;

  /// No description provided for @profileInfoSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile information:'**
  String get profileInfoSaveError;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Error logging out:'**
  String get logoutError;

  /// No description provided for @profileIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Profile ID'**
  String get profileIdTitle;

  /// No description provided for @profileIdDescription.
  ///
  /// In en, this message translates to:
  /// **'This is your personal ID. You can share it with others so they can invite you to groups.'**
  String get profileIdDescription;

  /// No description provided for @profileIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Profile ID copied!'**
  String get profileIdCopied;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional info'**
  String get additionalInfo;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmailAddress;

  /// No description provided for @onboardingComplete.
  ///
  /// In en, this message translates to:
  /// **'Data has been saved and onboarding completed.'**
  String get onboardingComplete;

  /// No description provided for @telefonnummerEingeben.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get telefonnummerEingeben;

  /// No description provided for @emailAdresseEingeben.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get emailAdresseEingeben;

  /// No description provided for @zusaetzlicheInfos.
  ///
  /// In en, this message translates to:
  /// **'Additional info'**
  String get zusaetzlicheInfos;

  /// No description provided for @keineGruppenGefunden.
  ///
  /// In en, this message translates to:
  /// **'No groups found.'**
  String get keineGruppenGefunden;

  /// No description provided for @ungueltigeTelefonnummer.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get ungueltigeTelefonnummer;

  /// No description provided for @profilGesichtGeben.
  ///
  /// In en, this message translates to:
  /// **'Give your profile a face'**
  String get profilGesichtGeben;

  /// No description provided for @fortfahren.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get fortfahren;

  /// No description provided for @ungueltigeEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get ungueltigeEmail;

  /// No description provided for @vorname.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get vorname;

  /// No description provided for @bitteVornameEingeben.
  ///
  /// In en, this message translates to:
  /// **'Please enter first name'**
  String get bitteVornameEingeben;

  /// No description provided for @nachname.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get nachname;

  /// No description provided for @nachnameEingeben.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get nachnameEingeben;

  /// No description provided for @bitteNachnameEingeben.
  ///
  /// In en, this message translates to:
  /// **'Please enter last name'**
  String get bitteNachnameEingeben;

  /// No description provided for @emailAdresse.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAdresse;

  /// No description provided for @telefonnummerOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (optional)'**
  String get telefonnummerOptional;

  /// No description provided for @groupDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Group \"{groupName}\" successfully deleted.'**
  String groupDeletedSuccess(Object groupName);

  /// No description provided for @groupDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting group: {error}'**
  String groupDeleteError(Object error);

  /// No description provided for @userInviteError.
  ///
  /// In en, this message translates to:
  /// **'Error inviting user: {error}'**
  String userInviteError(Object error);

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User with this ID not found.'**
  String get userNotFound;

  /// No description provided for @userAlreadyMember.
  ///
  /// In en, this message translates to:
  /// **'User is already a member of this group.'**
  String get userAlreadyMember;

  /// No description provided for @membersManagementComplete.
  ///
  /// In en, this message translates to:
  /// **'Members management completed.'**
  String get membersManagementComplete;

  /// No description provided for @groupAvatarUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error saving group avatar: {error}'**
  String groupAvatarUpdateError(Object error);

  /// No description provided for @groupAvatarUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Group avatar successfully updated!'**
  String get groupAvatarUpdateSuccess;

  /// No description provided for @debugAvatarChange.
  ///
  /// In en, this message translates to:
  /// **'DEBUG: _onAvatarChanged in GroupPage called with newAvatarUrl: {newAvatarUrl}'**
  String debugAvatarChange(Object newAvatarUrl);

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved!'**
  String get changesSaved;

  /// No description provided for @groupDataLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading group data or user ID: {error}'**
  String groupDataLoadError(Object error);

  /// No description provided for @groupLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error: Group could not be loaded or user ID is missing.'**
  String get groupLoadError;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @calendarEventsLoaded.
  ///
  /// In en, this message translates to:
  /// **'Calendar: Events for group {groupId} loaded: {count} events'**
  String calendarEventsLoaded(Object groupId, Object count);

  /// No description provided for @eventLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Error loading events: {error}'**
  String eventLoadingError(Object error);

  /// No description provided for @eventDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event successfully deleted.'**
  String get eventDeletedSuccess;

  /// No description provided for @eventDeleteTargetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Error: Event to be deleted not found.'**
  String get eventDeleteTargetNotFound;

  /// No description provided for @eventDeletionError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting event: {error}'**
  String eventDeletionError(Object error);

  /// No description provided for @placeholderViewText.
  ///
  /// In en, this message translates to:
  /// **'This could be another view.'**
  String get placeholderViewText;

  /// No description provided for @eventListLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading events...'**
  String get eventListLoading;

  /// No description provided for @eventListLoadingForGroup.
  ///
  /// In en, this message translates to:
  /// **'Loading events for group {groupId}'**
  String eventListLoadingForGroup(Object groupId);

  /// No description provided for @eventListLoadingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} events loaded'**
  String eventListLoadingCount(Object count);

  /// No description provided for @eventListLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Error loading events: {error}'**
  String eventListLoadingError(Object error);

  /// No description provided for @eventListNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No appointments found for this group.'**
  String get eventListNoEvents;

  /// No description provided for @eventListTodayHeader.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get eventListTodayHeader;

  /// No description provided for @eventListTomorrowHeader.
  ///
  /// In en, this message translates to:
  /// **'TOMORROW'**
  String get eventListTomorrowHeader;

  /// No description provided for @eventListDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Appointment'**
  String get eventListDeleteConfirmTitle;

  /// No description provided for @eventListDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete \"{eventName}\"?'**
  String eventListDeleteConfirmMessage(Object eventName);

  /// No description provided for @eventListCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get eventListCancelButton;

  /// No description provided for @eventListDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get eventListDeleteButton;

  /// No description provided for @eventListDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Appointment successfully deleted.'**
  String get eventListDeletedSuccess;

  /// No description provided for @eventListTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'{time}'**
  String eventListTimeFormat(Object time);

  /// No description provided for @oldEventsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Found {count} old events. Would you like to delete them to save storage space?'**
  String oldEventsFoundMessage(Object count);

  /// No description provided for @deleteOldEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Old Events'**
  String get deleteOldEventsTitle;

  /// No description provided for @deleteOldEventsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete {count} events that are older than 14 days? This action cannot be undone.'**
  String deleteOldEventsConfirmation(Object count);

  /// No description provided for @oldEventsDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} old events were successfully deleted.'**
  String oldEventsDeletedSuccess(Object count);

  /// No description provided for @oldEventsDeletionError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting old events: {error}'**
  String oldEventsDeletionError(Object error);

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @selectProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Select Profile Image'**
  String get selectProfileImage;

  /// No description provided for @selectGroupImage.
  ///
  /// In en, this message translates to:
  /// **'Select Group Image'**
  String get selectGroupImage;

  /// No description provided for @selectEventImage.
  ///
  /// In en, this message translates to:
  /// **'Select Event Image'**
  String get selectEventImage;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromStandard.
  ///
  /// In en, this message translates to:
  /// **'Or choose from standard images:'**
  String get chooseFromStandard;

  /// No description provided for @cancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelSelection;

  /// No description provided for @imageSelectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Image selection cancelled.'**
  String get imageSelectionCancelled;

  /// No description provided for @standardImageSet.
  ///
  /// In en, this message translates to:
  /// **'Image successfully set as standard image.'**
  String get standardImageSet;

  /// No description provided for @croppingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cropping cancelled.'**
  String get croppingCancelled;

  /// No description provided for @processingError.
  ///
  /// In en, this message translates to:
  /// **'Error in image processing for upload.'**
  String get processingError;

  /// No description provided for @noUserIdError.
  ///
  /// In en, this message translates to:
  /// **'Error: No user ID available. Please sign in.'**
  String get noUserIdError;

  /// No description provided for @firebaseUploadError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading to Firebase Storage: {error}'**
  String firebaseUploadError(Object error);

  /// No description provided for @unexpectedUploadError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error during image upload: {error}'**
  String unexpectedUploadError(Object error);

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected.'**
  String get noImageSelected;

  /// No description provided for @imagePickError.
  ///
  /// In en, this message translates to:
  /// **'Error in image selection or cropping: {error}'**
  String imagePickError(Object error);
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
