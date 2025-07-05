import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/presentation/login_screen.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding1.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding3.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/font_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_preview/device_preview.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/data/app_user.dart';

class MainApp extends StatefulWidget {
  // Attribute
  final DatabaseRepository db;
  final AuthRepository auth;

  // Konstruktor
  const MainApp(this.db, this.auth, {super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // Status, ob der Onboarding-Prozess abgeschlossen ist.
  // Null bedeutet, dass der Status noch nicht aus SharedPreferences geladen wurde.
  bool? onboardingComplete;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus(); // Onboarding-Status beim Start laden
  }

  /// Lädt den Onboarding-Status aus SharedPreferences.
  /// Setzt 'onboardingComplete' auf true, wenn der Schlüssel gefunden wird, sonst auf false.
  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getBool('onboardingComplete') ?? false;

    // Aktualisiert den Zustand und löst einen Neuaufbau des Widgets aus.
    setState(() {
      onboardingComplete = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Lauscht auf Änderungen im Firebase Authentifizierungsstatus.
      stream: widget.auth.authStateChanges(),
      builder: (context, snapshot) {
        // Zeigt einen Ladeindikator an, solange:
        // 1. Der Onboarding-Status noch nicht geladen wurde (onboardingComplete ist null).
        // 2. Der Firebase Auth-Stream noch auf seine ersten Daten wartet.
        if (onboardingComplete == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
                body: Center(child: CircularProgressIndicator())),
            theme: appTheme,
          );
        }

        return MaterialApp(
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          home: _getHomeScreen(snapshot.data),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('de', ''),
            Locale('en', ''),
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            return const Locale('de', '');
          },
        );
      },
    );
  }

  /// Bestimmt den Startbildschirm basierend auf dem Firebase-Benutzerstatus
  /// und dem Abschluss des Onboarding-Prozesses.
  Widget _getHomeScreen(User? firebaseUser) {
    if (firebaseUser == null) {
      // Wenn kein Benutzer bei Firebase angemeldet ist,
      // wird der Login-Bildschirm (Onboarding3Screen) angezeigt.
      // Da Onboarding3Screen einen 'user' Parameter erfordert,
      // erstellen wir einen leeren AppUser als Platzhalter.
      final AppUser emptyUser = AppUser(
        profilId: '', // Eine leere ID oder eine temporäre ID
        firstName: '',
        lastName: '',
        email: '',
        phoneNumber: '',
        birthDate: DateTime(2000, 1, 1), // Standard-Geburtsdatum
        avatarUrl: '',
        miscellaneous: '',
        password: '',
      );
      return Onboarding3Screen(
          db: widget.db, auth: widget.auth, user: emptyUser);
    } else {
      // Wenn ein Benutzer bei Firebase angemeldet ist,
      // wird der Onboarding-Status überprüft.
      if (onboardingComplete!) {
        // Wenn das Onboarding abgeschlossen ist,
        // wird der Hauptbildschirm (ProfilPage) angezeigt.
        // Sicherstellen, dass currentUser nicht null ist, bevor es verwendet wird.
        // Wenn db.currentUser null sein könnte, müssen Sie hier eine Fallback-Logik oder einen Ladebildschirm einbauen.
        if (widget.db.currentUser == null) {
          // Dies sollte nicht passieren, wenn der Benutzer angemeldet ist und das Onboarding abgeschlossen ist.
          // Aber zur Sicherheit: Wenn currentUser null ist, gehen wir zurück zum Login.
          // Oder Sie könnten hier einen spezifischen Lade-/Fehlerbildschirm anzeigen.
          return LoginScreen(widget.db, widget.auth);
        }

        // Die Group wird von db.currentGroup geholt. Falls diese null ist (z.B. bei einem neuen Login ohne Gruppe),
        // wird eine Standard-Gruppe erstellt. Dies sollte in der ProfilPage behandelt werden,
        // da die Gruppe dort dynamisch geladen oder zugewiesen werden könnte.
        final Group groupToPass = widget.db.currentGroup ??
            Group(
              groupId: '',
              groupName: 'Standardgruppe',
              groupLocation: '',
              groupDescription: '',
              groupAvatarUrl: '',
              creatorId: '',
              groupMembers: [],
              userRoles: {},
            );

        return ProfilPage(
          db: widget.db,
          currentUser: widget.db.currentUser!,
          group: groupToPass,
          auth: widget.auth, // Korrektur: Zugriff über widget.auth
        );
      } else {
        // Wenn das Onboarding NICHT abgeschlossen ist,
        // wird der erste Onboarding-Bildschirm (CustomScreen/Onboarding1Screen) angezeigt.
        return CustomScreen(widget.db, widget.auth);
      }
    }
  }
}
