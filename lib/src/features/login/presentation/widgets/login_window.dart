import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/menu/presentation/widgets/menu_screen.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/onboarding1_screen.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';

class LoginWindow extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;

  const LoginWindow(this.db, this.auth, {super.key});

  @override
  State<LoginWindow> createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordRepeatController = TextEditingController();

  bool _isObscured = true;

  Future<void> _handleLogin() async {
    final emailOrPhone = _emailOrPhoneController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await widget.db.loginAs(
          emailOrPhone,
          password,
          AppUser(
              profilId: '',
              firstName: '',
              lastName: '',
              birthDate: DateTime.now(),
              email: '',
              phoneNumber: '',
              avatarUrl: '',
              miscellaneous: '',
              password: password));

      final currentUserId = await widget.db.getCurrentUserId();
      final currentUser = widget.db.getUser(currentUserId);

      if (currentUser == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Benutzer nicht gefunden.")),
        );
        return;
      }

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => MenuScreen(
            widget.db,
            currentUser: currentUser,
          ),
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login fehlgeschlagen: $e")),
      );
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
                        labelText: "Telefonnummer oder E-Mail Adresse",
                        hintText: "Benutzername oder E-Mail Adresse eingeben",
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => validatePassword(
                            value,
                            _emailOrPhoneController.text,
                          ),
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
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordRepeatController,
                          obscureText: _isObscured,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return "Passwörter stimmen nicht überein";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Passwort Wiederholen",
                            hintText: "Passwort Wiederholung",
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
                        final emailError =
                            validateEmailOrPhone(_emailOrPhoneController.text);
                        final passwordError = validatePassword(
                          _passwordController.text,
                          _emailOrPhoneController.text,
                        );
                        final repeatError = _passwordRepeatController.text !=
                                _passwordController.text
                            ? "Passwörter stimmen nicht überein"
                            : null;

                        if (emailError == null &&
                            passwordError == null &&
                            repeatError == null) {
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
                      child: const ButtonLinearGradient(buttonText: 'Anmelden'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Onboarding1Screen(widget.db, widget.auth),
                          ),
                        );
                      },
                      child: const ButtonLinearGradient(
                          buttonText: 'Neu hier? Dann hier entlang'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateEmailOrPhone(String? input) {
    if (input == null || input.isEmpty) return "Eingabe darf nicht leer sein";
    if (input.contains(" ")) return "Keine Leerzeichen erlaubt";
    if (input.contains("@") && input.contains(".")) return null;
    if (RegExp(r'^\+?\d{7,15}$').hasMatch(input)) return null;
    return "Ungültige E-Mail oder Telefonnummer";
  }

  String? validatePassword(String? input, String usernameOrEmail) {
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
