import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding1.dart';
import 'package:flutter/material.dart';

class Onboarding1Screen extends StatelessWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final String? initialEmail;
  final String? initialPassword;

  const Onboarding1Screen(this.db, this.auth,
      {super.key, this.initialEmail, this.initialPassword});

  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      db,
      auth,
      initialEmail: initialEmail,
      initialPassword: initialPassword,
    );
  }
}
