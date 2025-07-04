import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/onboarding_process1.dart';
import 'package:famka_app/src/common/color_row.dart';

class CustomScreen extends StatelessWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final Group? currentGroup;

  const CustomScreen(this.db, this.auth, {super.key, this.currentGroup});

  @override
  Widget build(BuildContext context) {
    const double bottomReservedSpace = 120.0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ColorRow(),
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: OnboardingProgress1(db, auth),
          ),
          Positioned.fill(
            bottom: bottomReservedSpace,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeadlineK(screenHead: 'Profil'),
                  const SizedBox(height: 40),
                  const SizedBox(height: 10),
                  ProfilOnboarding(db: db, auth: auth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
