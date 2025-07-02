import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/appointment1.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/font_theme.dart';
import 'package:famka_app/src/data/mock_database_repository.dart';

void main() {
  final mockDb = MockDatabaseRepository();
  runApp(MainApp(mockDb));
}

class MainApp extends StatelessWidget {
  final DatabaseRepository db;

  const MainApp(this.db, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Appointment(db),
      debugShowCheckedModeBanner: false,
    );
  }
}
