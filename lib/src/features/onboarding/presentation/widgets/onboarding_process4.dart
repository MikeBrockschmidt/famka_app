import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/login/presentation/login_screen.dart';

class OnboardingProgress4 extends StatelessWidget {
  // Atribute
  final DatabaseRepository db;
  final AuthRepository auth;

  // Konstruktor
  const OnboardingProgress4(this.db, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildClickableIconBox(context, Icons.check, Colors.black),
        _buildClickableIconBox(context, Icons.check, Colors.black),
        _buildClickableIconBox(context, Icons.check, Colors.black),
        _buildClickableIconBox(context, Icons.check, Colors.black),
      ],
    );
  }

  Widget _buildClickableIconBox(
      BuildContext context, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(db, auth),
            ),
          );
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
