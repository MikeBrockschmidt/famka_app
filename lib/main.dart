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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Instanziieren der Repositories
  final AuthRepository auth = FirebaseAuthRepository();
  final DatabaseRepository db = FirestoreDatabaseRepository();

  // --- Start des Fixes für ungültige SharedPreferences-Benutzer-ID ---

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  const String userIdKey = 'last_logged_in_user_id';
  final String? storedUserId = prefs.getString(userIdKey);

  if (storedUserId != null && storedUserId.isNotEmpty) {
    print('ℹ️ Gefundene Benutzer-ID in SharedPreferences: $storedUserId');
    bool userStillExists = false;

    try {
      // 1. Prüfen über Firebase Authentication (aktuell angemeldeter Benutzer)
      // Dies ist die robusteste Prüfung auf Client-Seite.
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == storedUserId) {
        // Der Benutzer ist über Firebase Auth angemeldet und die ID stimmt überein.
        // Optional: 2. Zusätzliche Prüfung in Firestore, ob das Benutzerdokument existiert.
        // Dies ist wichtig, wenn Benutzer in Firestore gelöscht, aber nicht in Auth.
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
          // Wenn das Firestore-Dokument fehlt, betrachten wir den Benutzer als nicht existierend für die App.
        }
      } else {
        print(
            '❌ Gespeicherte ID $storedUserId stimmt nicht mit aktuellem Firebase-Benutzer überein oder kein Benutzer angemeldet.');
      }
    } catch (e) {
      print('❌ Fehler beim Überprüfen der Benutzer-ID in Firebase: $e');
      // Im Fehlerfall (z.B. Netzwerkprobleme) gehen wir davon aus, dass der Benutzer nicht valide ist.
      userStillExists = false;
    }

    // Wenn der Benutzer nach allen Prüfungen nicht mehr existiert,
    // den Eintrag aus SharedPreferences löschen.
    if (!userStillExists) {
      await prefs.remove(userIdKey);
      print(
          '🗑️ Ungültiger Benutzer $storedUserId aus SharedPreferences entfernt.');
      // Hier könnten Sie auch andere benutzerbezogene SharedPreferences-Daten löschen, falls vorhanden.
    }
  } else {
    print('ℹ️ Keine Benutzer-ID in SharedPreferences gefunden.');
  }

  // --- Ende des Fixes ---

  runApp(MainApp(db, auth));
}
