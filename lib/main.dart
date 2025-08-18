import 'dart:async';
import 'package:famka_app/firebase_options.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/firebase_auth_repository.dart';
import 'package:famka_app/src/data/firestore_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/main_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'src/providers/locale_provider.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // ignore: avoid_print
    print('FlutterError: ' + details.exceptionAsString());
    if (details.stack != null) print(details.stack);
  };
  runZonedGuarded(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final AuthRepository auth = FirebaseAuthRepository();
    final DatabaseRepository db = FirestoreDatabaseRepository();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const String userIdKey = 'last_logged_in_user_id';
    final String? storedUserId = prefs.getString(userIdKey);

    if (storedUserId != null && storedUserId.isNotEmpty) {
      print('ℹ️ Gefundene Benutzer-ID in SharedPreferences: $storedUserId');
      bool userStillExists = false;

      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.uid == storedUserId) {
          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(storedUserId)
              .get();
          if (userDoc.exists) {
            userStillExists = true;
            print(
                '✅ Benutzer $storedUserId in Firebase Auth und Firestore gefunden.');
          } else {
            print(
                '⚠️ Benutzer $storedUserId in Firebase Auth gefunden, aber Firestore-Dokument fehlt.');
          }
        } else {
          print(
              '❌ Gespeicherte ID $storedUserId stimmt nicht mit aktuellem Firebase-Benutzer überein oder kein Benutzer angemeldet.');
        }
      } catch (e, stack) {
        print('❌ Fehler beim Überprüfen der Benutzer-ID in Firebase: $e');
        print(stack);
        userStillExists = false;
      }

      if (!userStillExists) {
        await prefs.remove(userIdKey);
        print(
            '🗑️ Ungültiger Benutzer $storedUserId aus SharedPreferences entfernt.');
      }
    } else {
      print('ℹ️ Keine Benutzer-ID in SharedPreferences gefunden.');
    }

    runApp(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MainApp(db, auth),
      ),
    );
  }, (error, stack) {
    print('Uncaught Dart error: $error');
    print(stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
