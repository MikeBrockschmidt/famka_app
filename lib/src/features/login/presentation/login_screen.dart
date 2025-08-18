// lib/src/features/login/presentation/login_screen.dart
import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/color_row.dart';
import 'package:famka_app/src/features/login/presentation/widgets/login_window.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  final DatabaseRepository db;
  final AuthRepository auth;

  const LoginScreen(this.db, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 1,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Der bunte Hintergrund, der am unteren Rand fixiert ist
          Align(
            alignment: Alignment.bottomCenter,
            child: ColorRow(),
          ),

          // 2. Das gesamte scrollbare UI, das über dem Hintergrund liegt
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HeadlineK(
                  screenHead: 'famka',
                  showLanguageSwitch: true,
                ),
                Padding(
                  // Den oberen Abstand (Padding) reduzieren, um den Text höher zu setzen
                  padding: const EdgeInsets.only(left: 28, top: 60),
                  child: Text(
                    l10n.loginScreenTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Spacer, um das LoginWindow nach unten zu drücken
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                // Das LoginWindow mit seiner eigenen Höhenbeschränkung
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: LoginWindow(db, auth),
                ),

                // Ein Platzhalter, der sicherstellt, dass der Inhalt nicht
                // hinter der ColorRow verschwindet, wenn gescrollt wird.
                SizedBox(height: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
