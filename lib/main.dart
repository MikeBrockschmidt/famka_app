import 'package:famka_app/firebase_options.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/mock_database_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/main_app.dart';

Future<void> main() async {
  final DatabaseRepository db = MockDatabaseRepository();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MainApp(db));
}
