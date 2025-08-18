import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/onboarding_process2.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_name_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/color_row.dart';

class Onboarding2Screen extends StatelessWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final AppUser user;

  const Onboarding2Screen({
    super.key,
    required this.db,
    required this.auth,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ColorRow(),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeadlineK(screenHead: 'Profil'),
                  const SizedBox(height: 1),
                  ProfilNameOnboarding(db: db, auth: auth, user: user),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: OnboardingProgress2(db, auth),
          ),
        ],
      ),
    );
  }
}
