import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding2.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image.dart';
import 'package:famka_app/src/theme/color_theme.dart';

class ProfilOnboarding extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;

  const ProfilOnboarding({
    super.key,
    required this.db,
    required this.auth,
  });

  @override
  State<ProfilOnboarding> createState() => _ProfilOnboardingState();
}

class _ProfilOnboardingState extends State<ProfilOnboarding> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _selectedAvatarUrl = 'assets/fotos/default.jpg';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  void _handleAvatarSelected(String newUrl) {
    setState(() {
      _selectedAvatarUrl = newUrl;
    });
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

  Future<void> _onSubmit(String email, String pw) async {
    await widget.auth.signInWithEmailAndPassword(email, pw);
  }

  void _saveNewUserAndNavigate() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bitte füllen Sie alle Felder korrekt aus.'),
          backgroundColor: AppColors.famkaRed,
        ),
      );
      return;
    }

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bitte geben Sie eine E-Mail-Adresse ein.'),
          backgroundColor: AppColors.famkaCyan,
        ),
      );
      return;
    }

    final newProfilId = await _generateNewProfilId();

    final newUser = AppUser(
      profilId: newProfilId,
      firstName: '',
      lastName: '',
      birthDate: DateTime(2000, 1, 1),
      email: email,
      phoneNumber: '',
      avatarUrl: _selectedAvatarUrl,
      miscellaneous: '',
      password: password,
    );

    try {
      await widget.db.createUser(newUser);
      widget.db.loginAs(newUser.profilId, newUser.password, newUser);
      await widget.auth.createUserWithEmailAndPassword(email, password);

      await _onSubmit(email, password);

      if (mounted) {
        Navigator.push(
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern des Profils: $e'),
            backgroundColor: AppColors.famkaRed,
          ),
        );
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
                              Text(
                                'Gebe deinem Profil ein Gesicht',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
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
                            onTap: _saveNewUserAndNavigate,
                            child: const ButtonLinearGradient(
                              buttonText: 'Fortfahren',
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
            child: ProfilImage(
              widget.db,
              currentAvatarUrl: _selectedAvatarUrl,
              onAvatarSelected: _handleAvatarSelected,
            ),
          ),
        ),
      ],
    );
  }
}
