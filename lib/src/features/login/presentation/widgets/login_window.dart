import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:famka_app/src/features/register/presentation/register_screen.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailOrPhoneController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await widget.auth.signInWithEmailAndPassword(email, password);

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.firebaseUserNotFound)),
          );
        }
        return;
      }

      final currentUser = await widget.db.getUserAsync(firebaseUser.uid);
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.firestoreUserNotFound)),
          );
        }
        await widget.auth.signOut();
        return;
      }

      widget.db.currentUser = currentUser;
      try {
        List<Group> userGroups =
            await widget.db.getGroupsForUser(firebaseUser.uid);
        widget.db.currentGroup =
            userGroups.isNotEmpty ? userGroups.first : null;
      } catch (e) {
        debugPrint(l10n.loadingGroupsError(e.toString()));
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
        message = l10n.loginFailedUserNotFound;
      } else if (e.code == 'wrong-password') {
        message = l10n.loginFailedWrongPassword;
      } else {
        message = l10n.loginFailedGeneric(e.message ?? e.code);
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
            content: Text(l10n.loginFailedGeneric(e.toString())),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                        IconButton(
                          icon: Image.asset(
                            'assets/grafiken/google.png',
                            height: 24,
                            width: 24,
                          ),
                          onPressed: () async {
                            try {
                              UserCredential userCredential =
                                  await widget.auth.signInWithGoogle();

                              final firebaseUser = userCredential.user;
                              if (firebaseUser == null) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text(l10n.googleLoginFailedNoUser)),
                                  );
                                }
                                return;
                              }

                              AppUser? currentUser = await widget.db
                                  .getUserAsync(firebaseUser.uid);

                              if (currentUser == null) {
                                debugPrint(
                                    'Neuer Google-Nutzer: Erstelle Firestore-Eintrag für UID: ${firebaseUser.uid}');
                                await widget.db.createUserFromGoogleSignIn(
                                  uid: firebaseUser.uid,
                                  email: firebaseUser.email,
                                  displayName: firebaseUser.displayName,
                                  photoUrl: firebaseUser.photoURL,
                                );
                                currentUser = await widget.db
                                    .getUserAsync(firebaseUser.uid);

                                if (currentUser == null) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(l10n
                                              .googleLoginFailedFirestoreLoad)),
                                    );
                                  }
                                  await widget.auth.signOut();
                                  return;
                                }

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            l10n.googleLoginNewUserCreated)),
                                  );
                                }
                              } else {
                                debugPrint(
                                    'Bestehender Google-Nutzer gefunden in Firestore: ${firebaseUser.uid}');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(l10n.googleLoginSuccess)),
                                  );
                                }
                              }

                              widget.db.currentUser = currentUser;

                              try {
                                List<Group> userGroups = await widget.db
                                    .getGroupsForUser(firebaseUser.uid);
                                widget.db.currentGroup = userGroups.isNotEmpty
                                    ? userGroups.first
                                    : null;
                              } catch (e) {
                                debugPrint(
                                    l10n.loadingGroupsError(e.toString()));
                                widget.db.currentGroup = null;
                              }

                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilPage(
                                      db: widget.db,
                                      currentUser: currentUser!,
                                      auth: widget.auth,
                                    ),
                                  ),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              String message;
                              if (e.code ==
                                  'account-exists-with-different-credential') {
                                message =
                                    l10n.googleLoginFailedDifferentCredential;
                              } else if (e.code == 'ABORTED_BY_USER') {
                                message = l10n.googleLoginAborted;
                              } else {
                                message = l10n.googleLoginUnexpectedError(
                                    e.message ?? e.code);
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
                                    content: Text(
                                        l10n.googleLoginUnexpectedError(
                                            e.toString())),
                                    backgroundColor: AppColors.famkaRed,
                                  ),
                                );
                              }
                              debugPrint(l10n
                                  .googleLoginUnexpectedError(e.toString()));
                            }
                          },
                          tooltip: l10n.signInWithGoogleTooltip,
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
                          onPressed: () async {
                            try {
                              UserCredential userCredential =
                                  await widget.auth.signInWithApple();

                              final firebaseUser = userCredential.user;
                              if (firebaseUser == null) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text(l10n.googleLoginFailedNoUser)),
                                  );
                                }
                                return;
                              }

                              AppUser? currentUser = await widget.db
                                  .getUserAsync(firebaseUser.uid);

                              if (currentUser == null) {
                                debugPrint(
                                    'Neuer Apple-Nutzer: Erstelle Firestore-Eintrag für UID: ${firebaseUser.uid}');
                                await widget.db.createUserFromGoogleSignIn(
                                  uid: firebaseUser.uid,
                                  email: firebaseUser.email,
                                  displayName: firebaseUser.displayName,
                                  photoUrl: firebaseUser.photoURL,
                                );
                                currentUser = await widget.db
                                    .getUserAsync(firebaseUser.uid);

                                if (currentUser == null) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(l10n
                                              .googleLoginFailedFirestoreLoad)),
                                    );
                                  }
                                  await widget.auth.signOut();
                                  return;
                                }

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            l10n.appleLoginNewUserCreated)),
                                  );
                                }

                                // Setze Onboarding als abgeschlossen für neue Apple-Nutzer
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('onboardingComplete', true);
                              } else {
                                debugPrint(
                                    'Bestehender Apple-Nutzer gefunden in Firestore: ${firebaseUser.uid}');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(l10n.appleLoginSuccess)),
                                  );
                                }

                                // Setze Onboarding als abgeschlossen für bestehende Apple-Nutzer
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('onboardingComplete', true);
                              }

                              widget.db.currentUser = currentUser;

                              try {
                                List<Group> userGroups = await widget.db
                                    .getGroupsForUser(firebaseUser.uid);
                                widget.db.currentGroup = userGroups.isNotEmpty
                                    ? userGroups.first
                                    : null;
                              } catch (e) {
                                debugPrint(
                                    l10n.loadingGroupsError(e.toString()));
                                widget.db.currentGroup = null;
                              }

                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilPage(
                                      db: widget.db,
                                      currentUser: currentUser!,
                                      auth: widget.auth,
                                    ),
                                  ),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              String message;
                              debugPrint(
                                  'Apple Sign-In FirebaseAuthException: ${e.code} - ${e.message}');

                              if (e.code ==
                                  'account-exists-with-different-credential') {
                                message =
                                    l10n.googleLoginFailedDifferentCredential;
                              } else if (e.code == 'unsupported_platform') {
                                message = l10n.appleLoginUnsupportedPlatform;
                              } else if (e.code == 'canceled' ||
                                  e.code == 'ABORTED_BY_USER') {
                                message = l10n.appleLoginAborted;
                              } else if (e.code == 'missing-identity-token') {
                                message =
                                    'Apple Sign-In Fehler: Kein Identity Token empfangen. Bitte versuchen Sie es erneut.';
                              } else if (e.code == 'apple-signin-error') {
                                message = 'Apple Sign-In Fehler: ${e.message}';
                              } else if (e.code == 'invalid-credential') {
                                message =
                                    'Apple Sign-In Fehler: Ungültige Anmeldedaten. Möglicherweise ein Konfigurationsproblem.';
                              } else {
                                message =
                                    'Apple Sign-In Fehler: ${e.message ?? e.code}';
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: AppColors.famkaRed,
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('Apple Sign-In Unexpected Error: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Unerwarteter Fehler bei der Apple-Anmeldung: $e'),
                                    backgroundColor: AppColors.famkaRed,
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          },
                          tooltip: l10n.signInWithAppleTooltip,
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
    if (input == null || input.length < 8)
      return l10n.passwordValidationMinLength;
    if (input.length > 50) return l10n.passwordValidationMaxLength;
    if (!RegExp(r'[a-z]').hasMatch(input))
      return l10n.passwordValidationLowercase;
    if (!RegExp(r'[A-Z]').hasMatch(input))
      return l10n.passwordValidationUppercase;
    if (!RegExp(r'\d').hasMatch(input)) return l10n.passwordValidationDigit;
    if (!RegExp(r'[!@#\$&*~\-+=_.,;:<>?/|]').hasMatch(input)) {
      return l10n.passwordValidationSpecialChar;
    }
    return null;
  }
}
