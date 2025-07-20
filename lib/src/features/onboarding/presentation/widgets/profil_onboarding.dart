import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding2.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class ProfilOnboarding extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final String? initialEmail;
  final String? initialPassword;

  const ProfilOnboarding({
    super.key,
    required this.db,
    required this.auth,
    this.initialEmail,
    this.initialPassword,
  });

  @override
  State<ProfilOnboarding> createState() => _ProfilOnboardingState();
}

class _ProfilOnboardingState extends State<ProfilOnboarding> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
    if (widget.initialPassword != null) {
      _passwordController.text = widget.initialPassword!;
      _confirmPasswordController.text = widget.initialPassword!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte Passwort eingeben.';
    }
    if (value.length < 6) {
      return 'Passwort muss mindestens 6 Zeichen lang sein.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte Passwort wiederholen.';
    }
    if (value != _passwordController.text) {
      return 'Passwörter stimmen nicht überein.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte E-Mail-Adresse eingeben.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Bitte eine gültige E-Mail-Adresse eingeben.';
    }
    return null;
  }

  void _saveNewUserAndNavigate() async {
    setState(() {
      _isLoading = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bitte füllen Sie alle Felder korrekt aus.'),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bitte geben Sie eine E-Mail-Adresse ein.'),
            backgroundColor: AppColors.famkaCyan,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      print('[_saveNewUserAndNavigate] Starte Registrierung...');

      final fb_auth.UserCredential userCredential =
          await widget.auth.createUserWithEmailAndPassword(email, password);
      final String firebaseUid = userCredential.user!.uid;
      print(
          '[_saveNewUserAndNavigate] Firebase Auth Benutzer erstellt. UID: $firebaseUid');

      final newUser = AppUser(
        profilId: firebaseUid,
        firstName: '',
        lastName: '',
        email: email,
        phoneNumber: null,
        avatarUrl: 'assets/fotos/default.jpg',
        miscellaneous: null,
        password: '',
      );
      print('[_saveNewUserAndNavigate] AppUser Objekt erstellt.');

      await widget.db.createUser(newUser);
      print(
          '[_saveNewUserAndNavigate] Benutzerdaten in Firestore gespeichert.');

      widget.db.currentUser = newUser;

      if (mounted) {
        print('[_saveNewUserAndNavigate] Navigiere zu Onboarding2Screen...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Onboarding2Screen(
              db: widget.db,
              auth: widget.auth,
              user: newUser,
            ),
          ),
        );
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      print(
          '[_saveNewUserAndNavigate] FirebaseAuthException: ${e.code} - ${e.message}');
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Diese E-Mail-Adresse wird bereits verwendet.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Das Passwort ist zu schwach.';
      } else {
        errorMessage = 'Fehler bei der Registrierung: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
    } catch (e) {
      print(
          '[_saveNewUserAndNavigate] Allgemeiner Fehler beim Speichern des Profils: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein Fehler ist aufgetreten: $e'),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(32, 10, 32, 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 185),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'E-Mail-Adresse',
                                  hintText: 'Gib deine E-Mail-Adresse ein',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Passwort',
                                  hintText: 'Gib ein sicheres Passwort ein',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Passwort bestätigen',
                                  hintText: 'Passwort wiederholen',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateConfirmPassword,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: _isLoading ? null : _saveNewUserAndNavigate,
                            child: ButtonLinearGradient(
                              buttonText: _isLoading ? 'Lädt...' : 'Fortfahren',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                image: const DecorationImage(
                  image: AssetImage('assets/grafiken/mann-pink.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: ClipOval(
                child: Container(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
