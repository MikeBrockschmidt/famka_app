import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/presentation/login_screen.dart';
import 'package:famka_app/src/features/menu/presentation/menu.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding2.dart';
import 'package:famka_app/src/features/register/presentation/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/font_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MainApp extends StatelessWidget {
  // Atribute
  final DatabaseRepository db;
  final AuthRepository auth;

  // Konstruktor
  const MainApp(this.db, this.auth, {super.key});

  // Methode
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        return MaterialApp(
          key: Key(snapshot.data?.uid ?? 'no_user'),
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          home: snapshot.hasData
              ? RegisterScreen(db, auth)
              : LoginScreen(db, auth),
          //     ? Menu(db, currentUser: db.currentUser)
          // ? Onboarding2Screen(
          //     db: db,
          //     auth: auth,
          //     user: db.currentUser,
          // )
          // : LoginScreen(db, auth),
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
}
