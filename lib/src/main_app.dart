// lib/src/main_app.dart
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/presentation/login_screen.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding1.dart'; // Wird CustomScreen genannt
import 'package:famka_app/src/features/onboarding/presentation/onboarding3.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/onboarding1_screen.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/font_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_preview/device_preview.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart'; // Benötigt für Group in _getHomeScreen
import 'package:famka_app/src/features/login/domain/app_user.dart';

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
  bool? onboardingComplete;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getBool('onboardingComplete') ?? false;

    setState(() {
      onboardingComplete = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.auth.authStateChanges(),
      builder: (context, snapshot) {
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

  Widget _getHomeScreen(User? firebaseUser) {
    if (firebaseUser == null) {
      // Annahme: CustomScreen ist tatsächlich Onboarding1Screen oder ein ähnlicher Startbildschirm.
      // Wenn Onboarding3Screen hier wirklich der Start für nicht eingeloggte Nutzer ist,
      // dann ist der Name 'CustomScreen' vielleicht ein Überbleibsel.
      final AppUser emptyUser = AppUser(
        profilId: '',
        firstName: '',
        lastName: '',
        email: '',
        phoneNumber: null, // phoneNumber und miscellaneous können null sein
        avatarUrl: '',
        miscellaneous: null,
        password: '',
      );
      return Onboarding3Screen(
          db: widget.db, auth: widget.auth, user: emptyUser);
    } else {
      if (onboardingComplete!) {
        if (widget.db.currentUser == null) {
          // Dies sollte idealerweise nicht passieren, wenn ein Firebase-Benutzer angemeldet ist,
          // aber es ist eine Sicherheitsvorkehrung.
          return LoginScreen(widget.db, widget.auth);
        }

        // Der 'group'-Parameter wird aus dem ProfilPage-Konstruktor entfernt,
        // da ProfilPage die Gruppen jetzt selbst lädt.
        return ProfilPage(
          db: widget.db,
          currentUser: widget.db.currentUser!,
          auth: widget.auth,
        );
      } else {
        // Hier sollte 'Onboarding1' oder der tatsächliche erste Onboarding-Screen stehen.
        // Habe 'CustomScreen' beibehalten, wie in deinem Originalcode.
        return Onboarding1Screen(widget.db, widget.auth);
      }
    }
  }
}
