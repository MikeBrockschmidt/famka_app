import 'dart:async';
import 'package:famka_app/firebase_options.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/firebase_auth_repository.dart';
import 'package:famka_app/src/data/firestore_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/main_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'src/providers/locale_provider.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("✅ Firebase initialized successfully");
    } catch (e) {
      print("❌ Firebase initialization failed: $e");
      throw e;
    }

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };
    
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final AuthRepository auth = FirebaseAuthRepository();
    final DatabaseRepository db = FirestoreDatabaseRepository();

    runApp(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MainApp(db, auth),
      ),
    );
  }, (error, stack) {
    print("💥 FATAL ERROR: $error");
    print("📍 Stack trace: $stack");
    throw error;
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
