import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding1.dart';
import 'package:flutter/material.dart';

class Onboarding1Screen extends StatelessWidget {
  // Attribute
  final DatabaseRepository db;
  final AuthRepository auth;

  // Konstruktor
  const Onboarding1Screen(this.db, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScreen(db, auth);
  }
}
