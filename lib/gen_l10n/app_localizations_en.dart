// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get addOrJoinGroupRequiredFieldError =>
      'Please fill out all required fields.';

  @override
  String get addOrJoinGroupTitle => 'Create Group';

  @override
  String get addOrJoinGroupCreateHint => 'Enter a group name';

  @override
  String get addOrJoinGroupGroupNameEmpty => 'Please enter a group name.';

  @override
  String get addOrJoinGroupDescriptionHint =>
      'A short description of your group';

  @override
  String get addOrJoinGroupLocationHint => 'Where is your group located?';

  @override
  String get addOrJoinGroupCreateButton => 'Create Group';

  @override
  String get addPassiveMemberTitle => 'Add Passive Member';

  @override
  String get addPassiveMemberFirstNameLabel => 'First Name';

  @override
  String get addPassiveMemberLastNameLabel => 'Last Name';

  @override
  String get addPassiveMemberLastNameError => 'Please enter a last name.';

  @override
  String get addPassiveMemberFirstNameError => 'Please enter a first name.';

  @override
  String get addPassiveMemberAddButton => 'Add';

  @override
  String get addPassiveMemberCancelButton => 'Cancel';

  @override
  String addPassiveMemberSuccess(String firstName) {
    return '$firstName has been successfully added.';
  }

  @override
  String addPassiveMemberError(String error) {
    return 'Failed to add member: $error';
  }

  @override
  String get enterLocationHint => 'Enter location';

  @override
  String get enterDescriptionHint => 'Enter description';

  @override
  String get groupPageRoleAdmin => 'Administrator';

  @override
  String get groupPageRoleMember => 'Member';

  @override
  String get shareGroupIdInstruction =>
      'Share this group ID with your friends!';

  @override
  String get groupIdCopied => 'Group ID copied!';

  @override
  String get menuTitle => 'Menü';

  @override
  String get newGroupTitle => 'Create New Group';

  @override
  String get enterGroupName => 'Please enter a group name.';

  @override
  String groupCreatedSuccess(String groupName) {
    return 'Group \"$groupName\" successfully created!';
  }

  @override
  String createGroupError(String error) {
    return 'Error creating group: $error';
  }

  @override
  String get noGroupSelectedError =>
      'Please create or join a group to use this feature.';

  @override
  String get groupNameLabel => 'Group Name';

  @override
  String get locationLabel => 'Location';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get createButtonText => 'Create';

  @override
  String get fillRequiredFields => 'Please fill in all required fields';

  @override
  String get groupName => 'Group Name';

  @override
  String get groupDescription => 'Group Description';

  @override
  String get appTitle => 'Famka';

  @override
  String get groupLocation => 'Location';

  @override
  String get inviteUserPrompt =>
      'Enter the profile ID of the user you want to invite';

  @override
  String get userProfileIdHint => 'Enter user profile ID';

  @override
  String get enterProfileIdError => 'Please enter a valid profile ID';

  @override
  String get addButtonText => 'Add';

  @override
  String get cancelButtonText => 'Cancel';

  @override
  String get noCurrentUserError =>
      'Error: No current user available. Please sign in.';

  @override
  String get noActiveGroupError =>
      'Could not load any groups or no active group to display.';

  @override
  String loadingGroupsError(String error) {
    return 'Error loading groups: $error';
  }

  @override
  String get groupsDeletedError =>
      'All groups have been deleted or could not be loaded.';

  @override
  String get unknownError => 'An unknown error occurred.';

  @override
  String get createGroupNotImplemented =>
      'Create group function not yet implemented.';

  @override
  String get createGroupButtonText => 'Create New Group';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get groupsTitle => 'Groups';

  @override
  String loadingErrorWithDetails(String error) {
    return 'Loading Error: $error';
  }

  @override
  String get noGroupsJoined => 'You haven\'t joined any groups yet.';

  @override
  String get imprintTitle => 'Imprint';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSettingTitle => 'Select Language';

  @override
  String get languageGerman => 'German';

  @override
  String get languageEnglish => 'English';

  @override
  String get loginScreenTitle => 'Login';

  @override
  String get emailInputLabel => 'Email Address';

  @override
  String get emailInputHint => 'Enter email address';

  @override
  String get passwordInputLabel => 'Password';

  @override
  String get passwordInputHint => 'Enter password';

  @override
  String get checkInputsError => 'Please check your inputs';

  @override
  String get loginButtonText => 'Login';

  @override
  String get newHereButtonText => 'New here? Follow me!';

  @override
  String get notRegisteredYetText => 'I\'m not registered yet!';

  @override
  String get firebaseUserNotFound => 'User not found in Firebase.';

  @override
  String get firestoreUserNotFound => 'User data not found in Firestore.';

  @override
  String loginFailedGeneric(String message) {
    return 'Login failed: $message';
  }

  @override
  String get loginFailedUserNotFound => 'No user found for this email.';

  @override
  String get loginFailedWrongPassword => 'Wrong password for this email.';

  @override
  String get googleLoginFailedNoUser =>
      'Google login failed: No Firebase user received.';

  @override
  String get googleLoginNewUserCreated => 'New Google user profile created.';

  @override
  String get googleLoginSuccess => 'Google user logged in successfully.';

  @override
  String googleLoginExistingUser(Object uid) {
    return 'Google user found in Firestore: $uid';
  }

  @override
  String get googleLoginFailedFirestoreLoad =>
      'Error: Could not load user data after creation.';

  @override
  String get googleLoginFailedDifferentCredential =>
      'An account already exists with this email but with a different sign-in method.';

  @override
  String get googleLoginAborted => 'Google login aborted by user.';

  @override
  String googleLoginUnexpectedError(String error) {
    return 'Unexpected Google login error: $error';
  }

  @override
  String get signInWithGoogleTooltip => 'Sign in with Google';

  @override
  String get signInWithAppleNotImplemented =>
      'Apple login not yet implemented.';

  @override
  String get signInWithAppleTooltip => 'Sign in with Apple';

  @override
  String get showPasswordTooltip => 'Show password';

  @override
  String get hidePasswordTooltip => 'Hide password';

  @override
  String get emailValidationEmpty => 'Email address cannot be empty';

  @override
  String get emailValidationInvalid => 'Please enter a valid email address.';

  @override
  String get passwordValidationMinLength => 'Min. 8 characters';

  @override
  String get passwordValidationMaxLength => 'Max. 50 characters';

  @override
  String get passwordValidationLowercase => 'Min. one lowercase letter';

  @override
  String get passwordValidationUppercase => 'Min. one uppercase letter';

  @override
  String get passwordValidationDigit => 'Min. one digit';

  @override
  String get passwordValidationSpecialChar => 'Min. one special character';

  @override
  String get appointmentTitle => 'Appointment';

  @override
  String get appointmentTitleLabel => 'Appointment Title';

  @override
  String get appointmentTitleHint => 'Appointment Title';

  @override
  String get dateLabel => 'Date';

  @override
  String get dateHint => 'YYYY-MM-DD';

  @override
  String get timeHint => 'HH:MM';

  @override
  String get allDayLabel => 'All Day';

  @override
  String get startTimeLabel => 'Start Time';

  @override
  String get endTimeLabel => 'End Time';

  @override
  String get locationHint => 'Appointment Location';

  @override
  String get descriptionHint => 'Details about the appointment (optional)';

  @override
  String createdByUser(String creator) {
    return 'Created by: $creator';
  }

  @override
  String forGroup(String groupName) {
    return 'For Group: $groupName';
  }

  @override
  String get validatorTitleEmpty => 'Please enter a title';

  @override
  String get validatorTitleLength => 'Maximum 80 characters allowed';

  @override
  String get validatorTitleEmojis => 'No emojis allowed';

  @override
  String get validatorLocationEmpty => 'Please enter a location';

  @override
  String get validatorLocationInvalidChars => 'Invalid characters in location';

  @override
  String get validatorDescriptionLength => 'Maximum 500 characters allowed';

  @override
  String get validatorRepeatCountEmpty => 'Please enter a number';

  @override
  String get validatorRepeatCountInvalid => 'Invalid number (must be > 0)';

  @override
  String get validatorRepeatCountMax => 'Max. 365 repetitions';

  @override
  String get snackbarFillAllFields => 'Please fill out all fields correctly.';

  @override
  String get snackbarAddImage => 'Please give your event a face.';

  @override
  String get snackbarSelectParticipants =>
      'For whom is the appointment? Please select at least one participant.';

  @override
  String get snackbarDateParseError => 'Error parsing date or time.';

  @override
  String get snackbarCreatorError =>
      'Error: Could not determine appointment creator.';

  @override
  String get snackbarRecurringEventSaved => 'Event series saved!';

  @override
  String get snackbarSingleEventSaved => 'Event saved!';

  @override
  String snackbarSaveError(String error) {
    return 'Error saving event: $error';
  }

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get repeatYearly => 'Yearly';

  @override
  String get reminderOneHour => '1 hour';

  @override
  String get reminderOneDay => '1 day';

  @override
  String get reminder30Minutes => '30 minutes';

  @override
  String get validateDateEmpty => 'Please select a date';

  @override
  String get validateDateInvalid => 'Invalid date';

  @override
  String get validateDateInPast => 'Date cannot be in the past';

  @override
  String get validateTimeEmpty => 'Please enter time';

  @override
  String get validateTimeInvalid => 'Invalid time';

  @override
  String get eventParticipantsTitle => 'For whom is the appointment?';

  @override
  String errorLoadingMembers(String error) {
    return 'Error: $error';
  }

  @override
  String get noMembersFound => 'No members found.';

  @override
  String get addImageTitle => 'Add photo or pictogram';

  @override
  String get addImageDescription =>
      'The selected image will replace the event\'s title in the calendar view.';

  @override
  String get repeatLabel => 'Repeat';

  @override
  String get repeatDropdownLabel => 'Repetition';

  @override
  String get numberOfRepeatsLabel => 'Number of repetitions';

  @override
  String get numberOfRepeatsHint => 'e.g., 5 (incl. this event)';

  @override
  String get reminderLabel => 'Reminder';

  @override
  String get reminderBeforeLabel => 'Reminder before';

  @override
  String get saveButtonText => 'Save';

  @override
  String groupAvatarLoadingError(String error) {
    return 'Error loading group avatar: $error';
  }

  @override
  String singleEventAvatarLoadingError(String error) {
    return 'Error loading avatar in SingleEventAvatar: $error';
  }

  @override
  String get errorCreatingGroup => 'Error creating group';

  @override
  String imageUploadSuccess(String downloadUrl) {
    return 'Image successfully uploaded: $downloadUrl';
  }

  @override
  String get imageDeletedSuccess => 'Image successfully deleted.';

  @override
  String imageDeleteError(String error) {
    return 'Error deleting image: $error';
  }

  @override
  String get imageUploadAborted => 'Image upload aborted or failed.';

  @override
  String imageUploadError(String error) {
    return 'Error during image upload: $error';
  }

  @override
  String get manageMembersUpdateSuccess => 'Members updated successfully.';

  @override
  String manageMembersUpdateError(String error) {
    return 'Failed to update members: $error';
  }

  @override
  String get manageMembersTitle => 'Manage Members';

  @override
  String get manageMembersCurrentTitle => 'Current Members';

  @override
  String get manageMembersRoleAdmin => '(Admin)';

  @override
  String get manageMembersRoleMember => '(Member)';

  @override
  String get manageMembersRolePassive => '(Passive)';

  @override
  String get manageMembersNoEmailPhone => 'No email/phone number';

  @override
  String get manageMembersSavingButton => 'Saving...';

  @override
  String get manageMembersSaveChangesButton => 'Save Changes';

  @override
  String get deleteAppointment => 'Delete Appointment';

  @override
  String confirmDeleteAppointment(Object eventName) {
    return 'Do you really want to delete \"$eventName\" permanently?';
  }

  @override
  String get editDescription => 'Edit Description';

  @override
  String get participants => 'Participants';

  @override
  String get menuLabel => 'Menu';

  @override
  String get calendarLabel => 'Calendar';

  @override
  String get appointmentLabel => 'Appointment';

  @override
  String get galleryLabel => 'Gallery';

  @override
  String get piktogrammeLabe => 'Pictograms';

  @override
  String get passwordShowTooltip => 'Show password';

  @override
  String get passwordHideTooltip => 'Hide password';

  @override
  String get noUserDataError => 'No user data available.';
}
