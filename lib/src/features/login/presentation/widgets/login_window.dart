import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:famka_app/src/features/register/presentation/register_screen.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/onboarding1_screen.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';

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

  Future<void> _persistLastLoggedInUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_logged_in_user_id', userId);
  }

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

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.firebaseUserNotFound)),
        );
        return;
      }

      await _persistLastLoggedInUserId(firebaseUser.uid);

      final currentUser = await widget.db.getUserAsync(firebaseUser.uid);
      if (!mounted) return;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.firestoreUserNotFound)),
        );
        await widget.auth.signOut();
        return;
      }

      widget.db.currentUser = currentUser;
      try {
        List<Group> userGroups = await widget.db.getGroupsForUser(firebaseUser.uid);
        widget.db.currentGroup = userGroups.isNotEmpty ? userGroups.first : null;
      } catch (e) {
        if (mounted) {
          debugPrint(l10n.loadingGroupsError(e.toString()));
          widget.db.currentGroup = null;
        }
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
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.loginFailedGeneric(e.toString())),
          backgroundColor: AppColors.famkaRed,
        ),
      );
    }
  }

  Future<void> _completeLoginAfterSocial(User firebaseUser,
      {bool markOnboardingComplete = true}) async {
    final l10n = AppLocalizations.of(context)!;

    await _persistLastLoggedInUserId(firebaseUser.uid);

    AppUser? currentUser = await widget.db.getUserAsync(firebaseUser.uid);
    if (!mounted) return;
    if (currentUser == null) {
      await widget.db.createUserFromGoogleSignIn(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
      );
      currentUser = await widget.db.getUserAsync(firebaseUser.uid);
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.googleLoginFailedFirestoreLoad)),
        );
        await widget.auth.signOut();
        return;
      }
    }

    if (markOnboardingComplete) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingComplete', true);
    }

    widget.db.currentUser = currentUser;
    try {
      List<Group> userGroups = await widget.db.getGroupsForUser(firebaseUser.uid);
      widget.db.currentGroup = userGroups.isNotEmpty ? userGroups.first : null;
    } catch (e) {
      debugPrint(l10n.loadingGroupsError(e.toString()));
      widget.db.currentGroup = null;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilPage(
          db: widget.db,
          currentUser: currentUser!,
                    isOwnProfile: true,
          auth: widget.auth,
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final userCredential = await widget.auth.signInWithGoogle();
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.googleLoginFailedNoUser)),
        );
        return;
      }
      await _completeLoginAfterSocial(firebaseUser);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.googleLoginSuccess)),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      if (e.code == 'account-exists-with-different-credential') {
        message = l10n.googleLoginFailedDifferentCredential;
      } else if (e.code == 'ABORTED_BY_USER' || e.code == 'canceled') {
        message = l10n.googleLoginAborted;
      } else {
        message = l10n.googleLoginUnexpectedError(e.message ?? e.code);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.famkaRed),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.googleLoginUnexpectedError(e.toString())),
            backgroundColor: AppColors.famkaRed),
      );
      debugPrint(l10n.googleLoginUnexpectedError(e.toString()));
    }
  }

  Future<void> _handleAppleSignIn() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final userCredential = await widget.auth.signInWithApple();
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.googleLoginFailedNoUser)),
        );
        return;
      }
      await _completeLoginAfterSocial(firebaseUser);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appleLoginSuccess)),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      if (e.code == 'account-exists-with-different-credential') {
        message = l10n.googleLoginFailedDifferentCredential;
      } else if (e.code == 'unsupported_platform') {
        message = l10n.appleLoginUnsupportedPlatform;
      } else if (e.code == 'canceled' || e.code == 'ABORTED_BY_USER') {
        message = l10n.appleLoginAborted;
      } else if (e.code == 'missing-identity-token') {
        message = 'Apple Sign-In Fehler: Kein Identity Token empfangen. Bitte versuchen Sie es erneut.';
      } else if (e.code == 'apple-signin-error') {
        message = 'Apple Sign-In Fehler: ${e.message}';
      } else if (e.code == 'invalid-credential') {
        message = 'Apple Sign-In Fehler: Ungültige Anmeldedaten.';
      } else {
        message = 'Apple Sign-In Fehler: ${e.message ?? e.code}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.famkaRed),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Unerwarteter Fehler bei der Apple-Anmeldung: $e'),
            backgroundColor: AppColors.famkaRed),
      );
      debugPrint('Apple Sign-In Unexpected Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleSmall;
    final l10n = AppLocalizations.of(context)!;

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
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        onTapOutside: (_) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            FocusScope.of(context).unfocus();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: l10n.emailInputLabel,
                          hintText: l10n.emailInputHint,
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
                            validator: (value) => validatePassword(value),
                            onTapOutside: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                FocusScope.of(context).unfocus();
                              });
                            },
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isObscured = !_isObscured;
                                  });
                                },
                                icon: Icon(
                                  _isObscured ? Icons.visibility : Icons.visibility_off,
                                ),
                                tooltip: _isObscured
                                    ? l10n.passwordShowTooltip
                                    : l10n.passwordHideTooltip,
                              ),
                              labelText: l10n.passwordInputLabel,
                              hintText: l10n.passwordInputHint,
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l10n.checkInputsError),
                                    const SizedBox(
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
                        child: ButtonLinearGradient(
                            buttonText: l10n.loginButtonText),
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
                                  Onboarding1Screen(widget.db, widget.auth),
                            ),
                          );
                        },
                        child: ButtonLinearGradient(
                            buttonText: l10n.newHereButtonText),
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
                        l10n.notRegisteredYetText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.famkaWhite,
                            ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google Sign-In Button
                        Opacity(
                          opacity: kIsWeb ? 0.3 : 1.0,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: kIsWeb
                                  ? () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Google Sign-In is not available on web.'),
                                          backgroundColor: AppColors.famkaBlue,
                                        ),
                                      );
                                    }
                                  : _handleGoogleSignIn,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.famkaWhite.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/grafiken/google.png',
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Apple Sign-In Button
                        Opacity(
                          opacity: kIsWeb ? 0.3 : 1.0,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: kIsWeb
                                  ? () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Apple Sign-In is not available on web.'),
                                          backgroundColor: AppColors.famkaBlue,
                                        ),
                                      );
                                    }
                                  : _handleAppleSignIn,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.famkaWhite.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.apple,
                                  size: 28,
                                  color: AppColors.famkaWhite,
                                ),
                              ),
                            ),
                          ),
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
    final l10n = AppLocalizations.of(context)!;
    if (input == null || input.trim().isEmpty) {
      return l10n.emailValidationEmpty;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input)) {
      return l10n.emailValidationInvalid;
    }
    return null;
  }

  String? validatePassword(String? input) {
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
}
