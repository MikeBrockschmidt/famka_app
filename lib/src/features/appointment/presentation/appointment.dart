import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/appointment1.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/font_theme.dart';
import 'package:famka_app/src/data/mock_database_repository.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/firebase_auth_repository.dart';

void main() {
  final mockDb = MockDatabaseRepository();
  final authRepository = FirebaseAuthRepository();

  runApp(MainApp(mockDb, authRepository));
}

class MainApp extends StatelessWidget {
  final DatabaseRepository db;
  final AuthRepository auth;

  const MainApp(this.db, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Appointment(
        db,
        auth: auth,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
