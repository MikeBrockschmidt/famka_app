import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/login/presentation/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterWindow extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;

  const RegisterWindow(this.db, this.auth, {super.key});

  @override
  State<RegisterWindow> createState() => _RegisterWindowState();
}

class _RegisterWindowState extends State<RegisterWindow> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isObscured = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? input) {
    final l10n = AppLocalizations.of(context)!;
    if (input == null || input.trim().isEmpty) {
      return l10n.emailValidationEmpty;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input)) {
      return l10n.emailValidationInvalid;
    }
    return null;
  }

  String? _validatePassword(String? input) {
    final l10n = AppLocalizations.of(context)!;
    if (input == null || input.length < 8) {
      return l10n.passwordValidationMinLength;
    }
    if (input.length > 50) {
      return l10n.passwordValidationMaxLength;
    }
    if (!RegExp(r'[a-z]').hasMatch(input)) {
      return l10n.passwordValidationLowercase;
    }
    if (!RegExp(r'[A-Z]').hasMatch(input)) {
      return l10n.passwordValidationUppercase;
    }
    if (!RegExp(r'\d').hasMatch(input)) {
      return l10n.passwordValidationDigit;
    }
    if (!RegExp(r'[!@#\$&*~\-+=_.,;:<>?/|]').hasMatch(input)) {
      return l10n.passwordValidationSpecialChar;
    }
    return null;
  }

  String? _validatePasswordRepeat(String? input) {
    final l10n = AppLocalizations.of(context)!;
    if (input == null || input.isEmpty) {
      return l10n
          .passwordValidationMinLength; // Use a more specific message if available
    }
    if (input != _passwordController.text) {
      return "Passwörter stimmen nicht überein";
    }
    return null;
  }

  String? _validateName(String? input) {
    if (input == null || input.trim().isEmpty) {
      return "Darf nicht leer sein";
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.famkaCyan,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    try {
      final UserCredential userCredential =
          await widget.auth.createUserWithEmailAndPassword(
        email,
        password,
      );

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final newUser = AppUser(
          profilId: firebaseUser.uid,
          firstName: firstName,
          lastName: lastName,
          email: firebaseUser.email ?? '',
          avatarUrl: 'assets/grafiken/famka-kreis.png',
          phoneNumber: null,
          miscellaneous: null,
          password: null,
          canCreateGroups: true,
        );

        await widget.db.createUser(newUser);
        // Benutzer erfolgreich in Firestore erstellt nach Registrierung.

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registrierung erfolgreich!")),
          );

          widget.db.currentUser = newUser;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilPage(
                db: widget.db,
                currentUser: newUser,
                auth: widget.auth,
                isOwnProfile: true,
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'Das Passwort ist zu schwach.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Ein Konto mit dieser E-Mail existiert bereits.';
      } else {
        message = 'Registrierung fehlgeschlagen: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ein unerwarteter Fehler ist aufgetreten: $e"),
            backgroundColor: Colors.red,
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            autofillHints: const [AutofillHints.givenName],
                            onTapOutside: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                FocusScope.of(context).unfocus();
                              });
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: _validateName,
                            decoration: InputDecoration(
                              labelText: "Vorname",
                              hintText: "Dein Vorname",
                              border: const OutlineInputBorder(),
                              hintStyle: textStyle,
                              labelStyle: textStyle,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lastNameController,
                            autofillHints: const [AutofillHints.familyName],
                            onTapOutside: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                FocusScope.of(context).unfocus();
                              });
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: _validateName,
                            decoration: InputDecoration(
                              labelText: "Nachname",
                              hintText: "Dein Nachname",
                              border: const OutlineInputBorder(),
                              hintStyle: textStyle,
                              labelStyle: textStyle,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            autofillHints: const [AutofillHints.email],
                            onTapOutside: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                FocusScope.of(context).unfocus();
                              });
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: _validateEmail,
                            decoration: InputDecoration(
                              labelText: "E-Mail-Adresse",
                              hintText: "Deine E-Mail-Adresse",
                              border: const OutlineInputBorder(),
                              hintStyle: textStyle,
                              labelStyle: textStyle,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            autofillHints: const [AutofillHints.newPassword],
                            onTapOutside: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                FocusScope.of(context).unfocus();
                              });
                            },
                            obscureText: _isObscured,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: _validatePassword,
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
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordRepeatController,
                            autofillHints: const [AutofillHints.newPassword],
                            onTapOutside: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                FocusScope.of(context).unfocus();
                              });
                            },
                            obscureText: _isObscured,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: _validatePasswordRepeat,
                            decoration: InputDecoration(
                              labelText: "Passwort Wiederholen",
                              hintText: "Passwort Wiederholung",
                              border: const OutlineInputBorder(),
                              hintStyle: textStyle,
                              labelStyle: textStyle,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _handleRegister,
                        child: const ButtonLinearGradient(
                            buttonText: 'Registrieren'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(widget.db, widget.auth),
                          ),
                        );
                      },
                      child: Text(
                        'Ich bin schon registriert!',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.famkaWhite),
                      ),
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
}
