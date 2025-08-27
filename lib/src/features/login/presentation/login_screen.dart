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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(color: Colors.white),
            const Align(
              alignment: Alignment.bottomCenter,
              child: ColorRow(),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: const HeadlineK(
                  screenHead: 'famka',
                ),
                centerTitle: true,
                toolbarHeight: null,
                titleSpacing: 0,
              ),
              body: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Colors.black,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 80),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 28, top: 60),
                                child: Text(
                                  l10n.loginScreenTitle,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 600),
                                child: LoginWindow(db, auth),
                              ),
                              const SizedBox(height: 100),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
