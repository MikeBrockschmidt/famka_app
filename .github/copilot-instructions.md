## What this project is
- Flutter 3.x family calendar/chat app backed by Firebase (Auth, Firestore, Storage, Messaging). Primary entry `lib/main.dart`, app shell `lib/src/main_app.dart`.
- Localization via `gen_l10n` with `LocaleProvider` (`lib/src/providers/locale_provider.dart`); persisted key `language_code`. Supported locales: de/en.

## Architecture & Data
- Data layer defined by `AuthRepository` + `DatabaseRepository` interfaces (`lib/src/data`). Firestore implementation lives in `FirestoreDatabaseRepository` (`firestore_repository.dart`); mock impl in `mock_database_repository.dart` for offline/demo.
- Key models: `AppUser`, `Group`, `SingleEvent` (domain folders under `lib/src/features/*/domain`). `Group.userRoles` maps userId→`UserRole` with `passiveMember` support; passive members also stored in `passiveMembersData`.
- Events stored in Firestore `events` collection; `SingleEvent` supports date ranges (`selectedDateRange`), color (`selectedRangeColorValue`), reminder flags/offset strings.
- Groups stored in `groups` collection; members tracked via `groupMemberIds`, roles, and passive member blobs.

## App flow (happy path)
- `main.dart` initializes Firebase (uses generated `firebase_options.dart`), registers FCM background handler, then injects `DatabaseRepository` + `AuthRepository` into `MainApp`.
- `MainApp` listens to `authStateChanges`; fetches user via `db.getUserAsync`; saves FCM token via `db.saveUserFCMToken` once logged in.
- Home selection: unauthenticated → `LoginScreen`; authenticated → onboarding check (`SharedPreferences` key `onboardingComplete`; also first/last name presence) then `ProfilPage`; calendar/menu screens are passed the same `db`/`auth` instances.

## UI patterns
- No global routing; screens receive `db`/`auth` and current models via constructors. Keep this injection style when adding screens.
- Groups and events are fetched per screen (e.g., `Menu` uses `db.getGroupsForUser`, `CalendarScreen` uses `db.getEventsForGroup`). Sort events client-side by date.
- Avoid storing new state in `DatabaseRepository.currentUser/currentGroup` unless you mirror existing usage (some screens rely on it when navigating back).

## Notifications
- FCM tokens stored on user doc (`fcmToken` field). `_saveFCMToken` in `MainApp` handles token write; reuse it when changing auth flows.
- Cloud Functions (`functions/index.js`): `scheduleReminder` triggers on event creation, schedules Cloud Task to call `sendPushNotification`. Reminder timing comes from `SingleEvent.reminderOffset`; keep offsets aligned with switch-case strings ("10 Sekunden", "30 Minuten", "1 Stunde", "1 Tag", "1 Woche").

## Auth specifics
- Google Sign-In: mobile uses `signInWithProvider`; web uses popup with detailed error mapping (see `firebase_auth_repository.dart`).
- Apple Sign-In only for iOS (`Platform.isIOS` guard); unsupported on web/Android.

## Localization & theming
- Use `AppLocalizations.of(context)` for user-facing text; add keys to `lib/l10n/*.arb` and regenerate via `flutter gen-l10n` (Flutter build already configured).
- Theme definitions in `lib/src/theme/color_theme.dart` and `font_theme.dart`; keep colors from `AppColors`.

## Dev & build workflow
- Standard: `flutter pub get`, `flutter run -d <device>`. Debug entry is `lib/main.dart` (there is a `main_debug.dart` but main.dart is canonical).
- Tests: `flutter test` (no custom runners). Widgets under `test/`.
- Cloud Functions: Node 18; deploy with `npm install` in `functions/` then `firebase deploy --only functions`. Emulator script: `npm run serve`.

## Gotchas
- `SharedPreferences` keys in use: `language_code`, `onboardingComplete`, `last_logged_in_user_id`; preserve when modifying onboarding/auth flows.
- `FirestoreDatabaseRepository` prints verbose logs; keep messages or update consistently if refactoring.
- `DatabaseRepository.updateGroupMemberOrder` updates `groupMemberIds` only; ensure `userRoles/passiveMembersData` stay consistent when reordering/removing members.
- Assets declared in `pubspec.yaml` (details/grafiken/hintergruende/fotos); keep new asset paths in sync.

## When adding features
- Prefer extending repositories over direct Firestore calls so mocks stay viable. Update interfaces if new operations are needed.
- Thread `db` and `auth` through constructors; avoid global singletons beyond existing providers.
- For reminders, ensure `hasReminder` and `reminderOffset` are set so the Cloud Function schedules tasks; keep offset strings consistent with the function switch.