import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:famka_app/src/features/register/presentation/register_screen.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding1.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';

class LoginWindow extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;

  const LoginWindow(this.db, this.auth, {super.key});

  @override
  State<LoginWindow> createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailOrPhoneController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await widget.auth.signInWithEmailAndPassword(email, password);

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Benutzer nicht in Firebase gefunden.")),
          );
        }
        return;
      }

      final currentUser = await widget.db.getUserAsync(firebaseUser.uid);
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Benutzerdaten nicht in Firestore gefunden.")),
          );
        }
        await widget.auth.signOut();
        return;
      }

      widget.db.currentUser = currentUser;
      try {
        List<Group> userGroups =
            await widget.db.getGroupsForUser(firebaseUser.uid);
        if (userGroups.isNotEmpty) {
          widget.db.currentGroup = userGroups.first;
        } else {
          widget.db.currentGroup = null;
        }
      } catch (e) {
        debugPrint(
            'Fehler beim Laden der Gruppen für den Benutzer (nicht kritisch für Login-Flow): $e');
        widget.db.currentGroup = null;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilPage(
              db: widget.db,
              currentUser: currentUser,
              auth: widget.auth,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Kein Benutzer für diese E-Mail gefunden.';
      } else if (e.code == 'wrong-password') {
        message = 'Falsches Passwort für diese E-Mail.';
      } else {
        message = 'Login fehlgeschlagen: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login fehlgeschlagen: $e"),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleSmall;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _emailOrPhoneController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: validateEmailOrPhone,
                        decoration: InputDecoration(
                          labelText: "E-Mail Adresse",
                          hintText: "E-Mail Adresse eingeben",
                          border: const OutlineInputBorder(),
                          hintStyle: textStyle,
                          labelStyle: textStyle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _isObscured,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) => validatePassword(value),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isObscured = !_isObscured;
                                  });
                                },
                                icon: Icon(
                                  _isObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                              labelText: "Passwort",
                              hintText: "Passwort eingeben",
                              border: const OutlineInputBorder(),
                              hintStyle: textStyle,
                              labelStyle: textStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          final emailError = validateEmailOrPhone(
                              _emailOrPhoneController.text);
                          final passwordError =
                              validatePassword(_passwordController.text);

                          if (emailError == null && passwordError == null) {
                            _handleLogin();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 3),
                                backgroundColor: AppColors.famkaCyan,
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text("Bitte überprüfe deine Eingaben"),
                                    SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                        child:
                            const ButtonLinearGradient(buttonText: 'Anmelden'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CustomScreen(widget.db, widget.auth),
                            ),
                          );
                        },
                        child: const ButtonLinearGradient(
                            buttonText: 'Neu hier? Dann hier entlang'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RegisterScreen(widget.db, widget.auth),
                          ),
                        );
                      },
                      child: Text(
                        'Ich bin noch nicht registriert!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.famkaWhite,
                            ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/grafiken/google.png',
                            height: 24,
                            width: 24,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Google Login noch nicht implementiert.")),
                            );
                          },
                          tooltip: 'Mit Google anmelden',
                        ),
                        const SizedBox(width: 12),
                        Image.asset(
                          'assets/grafiken/strich.png',
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.apple,
                              size: 32, color: AppColors.famkaWhite),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Apple Login noch nicht implementiert."),
                              ),
                            );
                          },
                          tooltip: 'Mit Apple anmelden',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateEmailOrPhone(String? input) {
    if (input == null || input.trim().isEmpty) {
      return "E-Mail-Adresse darf nicht leer sein";
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input)) {
      return "Bitte eine gültige E-Mail-Adresse eingeben.";
    }
    return null;
  }

  String? validatePassword(String? input) {
    if (input == null || input.length < 8) return "Mind. 8 Zeichen";
    if (input.length > 50) return "Max. 50 Zeichen";
    if (!RegExp(r'[a-z]').hasMatch(input)) return "Mind. ein Kleinbuchstabe";
    if (!RegExp(r'[A-Z]').hasMatch(input)) return "Mind. ein Großbuchstabe";
    if (!RegExp(r'\d').hasMatch(input)) return "Mind. eine Zahl";
    if (!RegExp(r'[!@#\$&*~\-+=_.,;:<>?/|]').hasMatch(input)) {
      return "Mind. ein Sonderzeichen";
    }
    return null;
  }
}
