import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class RegisterWindow extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;

  const RegisterWindow({
    super.key,
    required this.db,
    required this.auth,
  });

  @override
  State<RegisterWindow> createState() => _RegisterWindowState();
}

class _RegisterWindowState extends State<RegisterWindow> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

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

  void _registerAndNavigate() async {
    setState(() {
      _isLoading = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte füllen Sie alle Felder korrekt aus.'),
            backgroundColor: Colors.red,
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

    try {
      final fb_auth.UserCredential userCredential =
          await widget.auth.createUserWithEmailAndPassword(email, password);
      final String firebaseUid = userCredential.user!.uid;

      final newUser = AppUser(
        profilId: firebaseUid,
        firstName: '',
        lastName: '',
        email: email,
        phoneNumber: '',
        avatarUrl: 'assets/fotos/default.jpg',
        miscellaneous: '',
        password: '',
      );

      await widget.db.createUser(newUser);

      if (mounted) {
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
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein Fehler ist aufgetreten: $e'),
            backgroundColor: Colors.red,
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-Mail-Adresse',
                  hintText: 'Gib deine E-Mail-Adresse ein',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : InkWell(
                      onTap: _registerAndNavigate,
                      child: const ButtonLinearGradient(
                        buttonText: 'Registrieren',
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
