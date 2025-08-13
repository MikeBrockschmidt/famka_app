// lib/src/features/onboarding/presentation/widgets/profil_onboarding.dart
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding2.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      return AppLocalizations.of(context)!.passwordInputHint;
    }
    if (value.length < 8) {
      return AppLocalizations.of(context)!.passwordValidationMinLength;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.passwordInputHint;
    }
    if (value != _passwordController.text) {
      return 'Passwörter stimmen nicht überein.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.emailValidationEmpty;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return AppLocalizations.of(context)!.emailValidationInvalid;
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
            content: Text(AppLocalizations.of(context)!.fillRequiredFields),
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
            content: Text(AppLocalizations.of(context)!.emailValidationEmpty),
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
      final fb_auth.UserCredential userCredential =
          await widget.auth.createUserWithEmailAndPassword(email, password);
      final String firebaseUid = userCredential.user!.uid;

      final newUser = AppUser(
        profilId: firebaseUid,
        firstName: '',
        lastName: '',
        email: email,
        phoneNumber: null,
        avatarUrl: AppLocalizations.of(context)!.defaultAvatarPath,
        miscellaneous: null,
        password: '',
      );

      await widget.db.createUser(newUser);
      widget.db.currentUser = newUser;

      // Explicitly set onboarding flag to false to ensure we don't skip steps
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingComplete', false);

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
        errorMessage =
            AppLocalizations.of(context)!.loginFailedGeneric(e.message ?? '');
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.unknownError),
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                padding: const EdgeInsets.fromLTRB(32, 110, 32, 28),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .emailInputLabel,
                                hintText: AppLocalizations.of(context)!
                                    .emailInputHint,
                                border: const OutlineInputBorder(),
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .passwordInputLabel,
                                hintText: AppLocalizations.of(context)!
                                    .passwordInputHint,
                                border: const OutlineInputBorder(),
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Passwort bestätigen',
                                hintText: AppLocalizations.of(context)!
                                    .passwordInputHint,
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
                            buttonText: _isLoading
                                ? AppLocalizations.of(context)!
                                    .manageMembersSavingButton
                                : AppLocalizations.of(context)!.fortfahren,
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
        Positioned(
          top: -60,
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
                  image: AssetImage('assets/grafiken/HI.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
