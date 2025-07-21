import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/presentation/login_screen.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/font_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';

class MainApp extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;

  const MainApp(this.db, this.auth, {super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  AppUser? _currentUserData;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    widget.auth.authStateChanges().listen((firebaseUser) async {
      setState(() {
        _isLoadingUserData = true;
      });
      if (firebaseUser != null) {
        final userFromFirestore =
            await widget.db.getUserAsync(firebaseUser.uid);
        setState(() {
          _currentUserData = userFromFirestore;
          widget.db.currentUser = _currentUserData;
          _isLoadingUserData = false;
        });
      } else {
        setState(() {
          _currentUserData = null;
          widget.db.currentUser = null;
          _isLoadingUserData = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            _isLoadingUserData) {
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
      return LoginScreen(widget.db, widget.auth);
    } else {
      if (_currentUserData == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return ProfilPage(
        db: widget.db,
        currentUser: _currentUserData!,
        auth: widget.auth,
      );
    }
  }
}
