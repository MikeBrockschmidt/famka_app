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
  String get groupPageRoleAdmin => 'Role: Admin';

  @override
  String get groupPageRoleMember => 'Role: Member';

  @override
  String get shareGroupIdInstruction =>
      'Share this Group ID with others so they can join the group:';

  @override
  String get groupIdCopied => 'Group ID copied!';

  @override
  String get copyButton => 'Copy';

  @override
  String get menuTitle => 'Menu';

  @override
  String get newGroupTitle => 'Group';

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
  String get languageTitle => 'Setup';

  @override
  String get languageSettingTitle => 'Select Language';

  @override
  String get languageGerman => 'German';

  @override
  String get languageEnglish => 'English';

  @override
  String get closeButton => 'Close';

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
  String get checkInputsError => 'Please check your inputs.';

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
  String get appleLoginNewUserCreated => 'New Apple user profile created.';

  @override
  String get appleLoginSuccess => 'Apple user logged in successfully.';

  @override
  String appleLoginExistingUser(Object uid) {
    return 'Apple user found in Firestore: $uid';
  }

  @override
  String get appleLoginFailedFirestoreLoad =>
      'Error: Could not load user data after creation.';

  @override
  String get appleLoginFailedDifferentCredential =>
      'An account already exists with this email but with a different sign-in method.';

  @override
  String get appleLoginAborted => 'Apple login aborted by user.';

  @override
  String appleLoginUnexpectedError(String error) {
    return 'Unexpected Apple login error: $error';
  }

  @override
  String get appleLoginUnsupportedPlatform =>
      'Apple Sign-In is only supported on iOS devices.';

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
    return 'Image successfully uploaded and updated.';
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
  String get manageMembersRemoveTitle => 'Remove Member';

  @override
  String manageMembersRemoveConfirmation(String memberName) {
    return 'Do you really want to remove $memberName from the group?';
  }

  @override
  String get manageMembersRemoveCancel => 'Cancel';

  @override
  String get manageMembersRemoveConfirm => 'Remove';

  @override
  String get deleteGroup => 'Delete Group';

  @override
  String confirmDeleteGroup(Object eventName) {
    return 'Do you really want to delete \"$eventName\" permanently?';
  }

  @override
  String get deleteAppointment => 'Delete Appointment';

  @override
  String confirmDeleteAppointment(Object eventName) {
    return 'Do you really want to delete \"$eventName\" permanently?';
  }

  @override
  String get editDescription => 'Edit Description';

  @override
  String participants(Object names) {
    return 'Participants: $names';
  }

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
  String get gallerySourceCamera => 'Camera';

  @override
  String get gallerySourceGallery => 'Gallery';

  @override
  String get timeAllDay => 'Time: All-day';

  @override
  String timeAt(Object time) {
    return 'Time: $time';
  }

  @override
  String location(Object location) {
    return 'Location: $location';
  }

  @override
  String description(Object description) {
    return 'Description: $description';
  }

  @override
  String get noDescription => 'No description';

  @override
  String appointmentsFor(Object name) {
    return 'Appointments for $name';
  }

  @override
  String get saveButton => 'Save';

  @override
  String get noChangesToSave => 'No changes to save.';

  @override
  String get descriptionUpdateSuccess => 'Description successfully updated.';

  @override
  String descriptionUpdateError(Object error) {
    return 'Error updating description: $error';
  }

  @override
  String get imageLoadError => 'Image could not be loaded';

  @override
  String get deleteImageTitle => 'Delete Image?';

  @override
  String get deleteImageDescription =>
      'Do you really want to remove this image from the gallery? This action cannot be undone.';

  @override
  String get deleteImageButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get imageUploadSuccessSelectNow =>
      'Image successfully uploaded. Please select it.';

  @override
  String get passwordShowTooltip => 'Show password';

  @override
  String get passwordHideTooltip => 'Hide password';

  @override
  String get noUserDataError => 'No user data available.';

  @override
  String get dateFormat => 'yyyy-MM-dd';

  @override
  String get localeGerman => 'de';

  @override
  String errorLoadingAvatar(Object avatarUrl, Object exception) {
    return 'Error loading avatar from $avatarUrl: $exception';
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
    return 'Error loading group avatar in ProfilAvatarRow: $exception';
  }

  @override
  String get cropImageTitle => 'Crop Image';

  @override
  String compressedImageName(Object timestamp) {
    return 'compressed_$timestamp.jpg';
  }

  @override
  String get compressionFailed => '❌ Compression failed.';

  @override
  String uploadSuccess(Object downloadUrl) {
    return '✅ Image successfully uploaded to Firebase Storage: $downloadUrl';
  }

  @override
  String uploadError(Object state) {
    return '❌ Error uploading image: $state';
  }

  @override
  String errorLoadingActiveGroup(Object error) {
    return 'Error loading active group: $error';
  }

  @override
  String get menuScreenRoute => '/menuScreen';

  @override
  String get calendarScreenRoute => '/calendarScreen';

  @override
  String get appointmentScreenRoute => '/appointmentScreen';

  @override
  String get logoutButton => 'Logout';

  @override
  String get addGroupButton => 'Add Group';

  @override
  String get invalidEmailError => 'Invalid email address';

  @override
  String get invalidPhoneNumberError =>
      'Invalid phone number (min. 8 digits, numbers only)';

  @override
  String get profilePictureUpdated => 'Profile picture updated.';

  @override
  String get profilePictureUpdateError => 'Error updating profile picture:';

  @override
  String get profileInfoSaved => 'Profile information saved.';

  @override
  String get profileInfoSaveError => 'Error saving profile information:';

  @override
  String get logoutError => 'Error logging out:';

  @override
  String get profileIdTitle => 'Your Profile ID';

  @override
  String get profileIdDescription =>
      'This is your personal ID. You can share it with others so they can invite you to groups.';

  @override
  String get profileIdCopied => 'Profile ID copied!';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get additionalInfo => 'Additional info';

  @override
  String get enterEmailAddress => 'Enter email address';

  @override
  String get onboardingComplete =>
      'Data has been saved and onboarding completed.';

  @override
  String get telefonnummerEingeben => 'Enter phone number';

  @override
  String get emailAdresseEingeben => 'Enter email address';

  @override
  String get zusaetzlicheInfos => 'Additional info';

  @override
  String get keineGruppenGefunden => 'No groups found.';

  @override
  String get ungueltigeTelefonnummer => 'Invalid phone number';

  @override
  String get profilGesichtGeben => 'Give your profile a face';

  @override
  String get fortfahren => 'Continue';

  @override
  String get ungueltigeEmail => 'Invalid email address';

  @override
  String get vorname => 'First Name';

  @override
  String get bitteVornameEingeben => 'Please enter first name';

  @override
  String get nachname => 'Last Name';

  @override
  String get nachnameEingeben => 'Enter last name';

  @override
  String get bitteNachnameEingeben => 'Please enter last name';

  @override
  String get emailAdresse => 'Email Address';

  @override
  String get telefonnummerOptional => 'Phone Number (optional)';

  @override
  String groupDeletedSuccess(Object groupName) {
    return 'Group \"$groupName\" successfully deleted.';
  }

  @override
  String groupDeleteError(Object error) {
    return 'Error deleting group: $error';
  }

  @override
  String userInviteError(Object error) {
    return 'Error inviting user: $error';
  }

  @override
  String get userNotFound => 'User with this ID not found.';

  @override
  String get userAlreadyMember => 'User is already a member of this group.';

  @override
  String get membersManagementComplete => 'Members management completed.';

  @override
  String groupAvatarUpdateError(Object error) {
    return 'Error saving group avatar: $error';
  }

  @override
  String get groupAvatarUpdateSuccess => 'Group avatar successfully updated!';

  @override
  String debugAvatarChange(Object newAvatarUrl) {
    return 'DEBUG: _onAvatarChanged in GroupPage called with newAvatarUrl: $newAvatarUrl';
  }

  @override
  String get changesSaved => 'Changes saved!';

  @override
  String groupDataLoadError(Object error) {
    return 'Error loading group data or user ID: $error';
  }

  @override
  String get groupLoadError =>
      'Error: Group could not be loaded or user ID is missing.';

  @override
  String get members => 'Members';

  @override
  String calendarEventsLoaded(Object groupId, Object count) {
    return 'Calendar: Events for group $groupId loaded: $count events';
  }

  @override
  String eventLoadingError(Object error) {
    return 'Error loading events: $error';
  }

  @override
  String get eventDeletedSuccess => 'Event successfully deleted.';

  @override
  String get eventDeleteTargetNotFound =>
      'Error: Event to be deleted not found.';

  @override
  String eventDeletionError(Object error) {
    return 'Error deleting event: $error';
  }

  @override
  String get placeholderViewText => 'This could be another view.';

  @override
  String get eventListLoading => 'Loading events...';

  @override
  String eventListLoadingForGroup(Object groupId) {
    return 'Loading events for group $groupId';
  }

  @override
  String eventListLoadingCount(Object count) {
    return '$count events loaded';
  }

  @override
  String eventListLoadingError(Object error) {
    return 'Error loading events: $error';
  }

  @override
  String get eventListNoEvents => 'No appointments found for this group.';

  @override
  String get eventListTodayHeader => 'TODAY';

  @override
  String get eventListTomorrowHeader => 'TOMORROW';

  @override
  String get eventListDeleteConfirmTitle => 'Delete Appointment';

  @override
  String eventListDeleteConfirmMessage(Object eventName) {
    return 'Do you really want to delete \"$eventName\"?';
  }

  @override
  String get eventListCancelButton => 'Cancel';

  @override
  String get eventListDeleteButton => 'Delete';

  @override
  String get eventListDeletedSuccess => 'Appointment successfully deleted.';

  @override
  String eventListTimeFormat(Object time) {
    return '$time';
  }

  @override
  String oldEventsFoundMessage(Object count) {
    return 'Found $count old events. Would you like to delete them to save storage space?';
  }

  @override
  String get deleteOldEventsTitle => 'Delete Old Events';

  @override
  String deleteOldEventsConfirmation(Object count) {
    return 'Do you want to delete $count events that are older than 14 days? This action cannot be undone.';
  }

  @override
  String oldEventsDeletedSuccess(Object count) {
    return '$count old events were successfully deleted.';
  }

  @override
  String oldEventsDeletionError(Object error) {
    return 'Error deleting old events: $error';
  }

  @override
  String get selectImage => 'Select Image';

  @override
  String get selectProfileImage => 'Select Profile Image';

  @override
  String get selectGroupImage => 'Select Group Image';

  @override
  String get selectEventImage => 'Select Event Image';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromStandard => 'Or choose from standard images:';

  @override
  String get cancelSelection => 'Cancel';

  @override
  String get imageSelectionCancelled => 'Image selection cancelled.';

  @override
  String get standardImageSet => 'Image successfully set as standard image.';

  @override
  String get croppingCancelled => 'Cropping cancelled.';

  @override
  String get processingError => 'Error in image processing for upload.';

  @override
  String get noUserIdError => 'Error: No user ID available. Please sign in.';

  @override
  String firebaseUploadError(Object error) {
    return 'Error uploading to Firebase Storage: $error';
  }

  @override
  String unexpectedUploadError(Object error) {
    return 'Unexpected error during image upload: $error';
  }

  @override
  String get noImageSelected => 'No image selected.';

  @override
  String imagePickError(Object error) {
    return 'Error in image selection or cropping: $error';
  }
}
