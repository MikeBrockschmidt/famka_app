import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/presentation/login_screen.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:famka_app/src/providers/locale_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/font_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

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
    _setupPushNotifications();

    widget.auth.authStateChanges().listen((firebaseUser) async {
      setState(() {
        _isLoadingUserData = true;
      });
      if (firebaseUser != null) {
        await _saveFCMToken(firebaseUser.uid);

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

  void _setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;

    final settings = await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }

  Future<void> _saveFCMToken(String userId) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await widget.db.saveUserFCMToken(userId, fcmToken);
        print('✅ FCM-Token für Benutzer $userId erfolgreich gespeichert.');
      }
    } catch (e) {
      print('❌ Fehler beim Speichern des FCM-Tokens: $e');
    }
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

        // Verwende LocaleProvider für die Spracheinstellung
        return Consumer<LocaleProvider>(
          builder: (context, localeProvider, child) {
            return MaterialApp(
              locale: localeProvider.locale, // Verwende die Locale vom Provider
              builder: DevicePreview.appBuilder,
              debugShowCheckedModeBanner: false,
              theme: appTheme,
              home: _getHomeScreen(snapshot.data),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('de', ''),
                Locale('en', ''),
              ],
            );
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
