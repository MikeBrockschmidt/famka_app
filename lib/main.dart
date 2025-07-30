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
    } catch (e) {
      print('❌ Fehler beim Überprüfen der Benutzer-ID in Firebase: $e');
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

  runApp(MainApp(db, auth));
}
