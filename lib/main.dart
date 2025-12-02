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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      print("Starting Firebase initialization...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase initialized successfully");

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
      };
      
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      print("Creating repositories...");
      final AuthRepository auth = FirebaseAuthRepository();
      final DatabaseRepository db = FirestoreDatabaseRepository(auth);

      // Only clear corrupted data if there's actually a problem
      print("Checking for potentially corrupted user data...");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Check if we had a previous startup failure
      final bool hadStartupError = prefs.getBool('firebase_startup_error') ?? false;
      
      if (hadStartupError) {
        print("Previous startup error detected - clearing Firebase user data...");
        
        // Only clear specific Firebase-related keys that might be corrupted
        final keysToRemove = [
          'firebase_user_id',
          'firebase_user_email', 
          'firebase_user_display_name',
          'user_validation_cache',
          'firestore_user_doc',
          'firebase_startup_error', // Clear the error flag too
        ];
        
        for (String key in keysToRemove) {
          await prefs.remove(key);
        }
        print("Cleared Firebase user data keys: ${keysToRemove.join(', ')}");
      } else {
        print("No previous startup errors - preserving all user data");
      }
      
      // Debug: Show preserved user data
      _debugUserPreferences(prefs);
      
      // Force sign out to ensure clean state
      try {
        await FirebaseAuth.instance.signOut();
        print("Signed out any existing user");
      } catch (e) {
        print("Sign out error (ignored): $e");
      }
      
      print("Starting app with clean state...");
      
      // Clear any startup error flag since we're starting successfully
      await prefs.setBool('firebase_startup_error', false);
      
      runApp(
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
          child: MainApp(db, auth),
        ),
      );
    } catch (e) {
      print("Critical error during app initialization: $e");
      
      // Mark startup error for next app launch
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('firebase_startup_error', true);
        print("Marked startup error for next launch cleanup");
      } catch (prefsError) {
        print("Could not save startup error flag: $prefsError");
      }
      
      // Fallback: start app anyway
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Initialization Error'),
                  Text('$e'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Restart app
                      main();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }, (error, stack) {
    print("App error: $error");
    print("Stack trace: $stack");
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

// Debug helper function
Future<void> _debugUserPreferences(SharedPreferences prefs) async {
  final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
  final languageCode = prefs.getString('language_code') ?? 'not set';
  final uploadedImages = prefs.getStringList('uploadedImagePaths')?.length ?? 0;
  
  print("=== User Preferences Debug ===");
  print("Onboarding Complete: $onboardingComplete");
  print("Language Code: $languageCode");
  print("Uploaded Images Count: $uploadedImages");
  print("=============================");
}
