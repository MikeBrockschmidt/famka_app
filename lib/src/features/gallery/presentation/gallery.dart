import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/gallery1.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/font_theme.dart';
import 'package:famka_app/src/data/mock_database_repository.dart';
import 'package:famka_app/src/data/auth_repository.dart'; // NEU: Import AuthRepository
import 'package:famka_app/src/data/firebase_auth_repository.dart'; // NEU: Import FirebaseAuthRepository

void main() {
  final mockDb = MockDatabaseRepository();
  // NEU: Eine Instanz von AuthRepository erstellen.
  // Für eine reale App würden Sie hier FirebaseAuthRepository() verwenden.
  // Für Mock-Tests könnten Sie eine MockAuthRepository() erstellen, falls vorhanden.
  final authRepository = FirebaseAuthRepository(); // Oder MockAuthRepository()

  runApp(MainApp(mockDb, authRepository)); // NEU: authRepository übergeben
}

class MainApp extends StatelessWidget {
  final DatabaseRepository db;
  final AuthRepository auth; // NEU: AuthRepository als Attribut hinzugefügt

  const MainApp(this.db, this.auth, {super.key}); // NEU: auth im Konstruktor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Gallery(
        db,
        auth: auth,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
