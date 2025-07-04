import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/onboarding1_screen.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';

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

  bool _isObscured = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    super.dispose();
  }

  Future<String> _generateNewProfilId() async {
    final allUsers = await widget.db.getAllUsers();
    int maxId = 0;
    for (var user in allUsers) {
      if (user.profilId.startsWith('u')) {
        final idNum = int.tryParse(user.profilId.substring(1));
        if (idNum != null && idNum > maxId) {
          maxId = idNum;
        }
      }
    }
    return 'u${maxId + 1}';
  }

  String? _validateEmail(String? input) {
    if (input == null || input.trim().isEmpty) {
      return "E-Mail-Adresse darf nicht leer sein";
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input)) {
      return "Bitte eine gültige E-Mail-Adresse eingeben.";
    }
    return null;
  }

  String? _validatePassword(String? input) {
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

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
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
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final newProfilId = await _generateNewProfilId();

      final newUser = AppUser(
        profilId: newProfilId,
        firstName: '',
        lastName: '',
        birthDate: DateTime(2000, 1, 1),
        email: email,
        phoneNumber: '',
        avatarUrl: 'assets/fotos/default.jpg',
        miscellaneous: '',
        password: password,
      );

      await widget.db.createUser(newUser);
      widget.db.loginAs(newUser.profilId, newUser.password, newUser);

      // 🔐 Wichtig: Zuerst Registrierung bei Firebase
      await widget.auth.createUserWithEmailAndPassword(email, password);

      // ✅ Danach: Anmeldung
      await widget.auth.signInWithEmailAndPassword(email, password);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Onboarding1Screen(widget.db, widget.auth),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registrierung fehlgeschlagen: $e"),
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
                key: _formKey,
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
                        controller: _emailController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validateEmail,
                        decoration: InputDecoration(
                          labelText: "E-Mail-Adresse",
                          hintText: "E-Mail-Adresse eingeben",
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
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordRepeatController,
                            obscureText: _isObscured,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Bitte Passwort wiederholen.";
                              }
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
                        onTap: _handleRegister,
                        child: const ButtonLinearGradient(
                            buttonText: 'Registrieren'),
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
      ),
    );
  }
}
