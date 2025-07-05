import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/login/presentation/login_screen.dart';

class OnboardingProgress3 extends StatelessWidget {
  // Atribute
  final DatabaseRepository db;
  final AuthRepository auth;

  // Konstruktor
  const OnboardingProgress3(this.db, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Sicherstellen, dass hier wieder VIER Felder sind
        _buildClickableIconBox(context, Icons.check, Colors.black),
        _buildClickableIconBox(context, Icons.check, Colors.black),
        _buildClickableIconBox(context, Icons.check, Colors.black),
        _buildClickableIconBox(context, Icons.check,
            Colors.white), // Das vierte Feld ist jetzt weiß
      ],
    );
  }

  Widget _buildClickableIconBox(
      BuildContext context, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () async {
          // Async machen, da signOut asynchron ist
          try {
            await auth.signOut(); // Hier wird der Logout durchgeführt
            // Nach dem Logout zum LoginScreen navigieren und alle vorherigen Routen entfernen
            if (context.mounted) {
              // Sicherstellen, dass der Widget-Baum noch aktiv ist
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(db, auth),
                ),
                (route) => false, // Entfernt alle Routen aus dem Stack
              );
            }
          } catch (e) {
            // Fehlerbehandlung, falls der Logout fehlschlägt
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fehler beim Abmelden: $e')),
              );
            }
          }
        },
        child: Container(
          width: 80,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
      ),
    );
  }
}
