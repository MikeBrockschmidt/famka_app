import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding2.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image.dart';
import 'package:famka_app/src/theme/color_theme.dart';

class ProfilOnboarding extends StatefulWidget {
  final DatabaseRepository db;

  const ProfilOnboarding(this.db, {super.key});

  @override
  State<ProfilOnboarding> createState() => _ProfilOnboardingState();
}

class _ProfilOnboardingState extends State<ProfilOnboarding> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String _selectedAvatarUrl = 'assets/fotos/default.jpg';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  void _saveNewUserAndNavigate() async {
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bitte geben Sie einen Vornamen ein.'),
          backgroundColor: AppColors.famkaCyan,
        ),
      );
      return;
    }

    final newProfilId = await _generateNewProfilId();

    final newUser = AppUser(
      profilId: newProfilId,
      firstName: firstName,
      lastName: lastName,
      birthDate: DateTime(2000, 1, 1),
      email: '',
      phoneNumber: '',
      avatarUrl: _selectedAvatarUrl,
      miscellaneous: '',
      password: '',
    );

    await widget.db.createUser(newUser);
    widget.db.loginAs(newUser.profilId, newUser.password);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Onboarding2Screen(
            db: widget.db,
            user: newUser,
          ),
        ),
      );
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 180),
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
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Vorname',
                                hintText: 'Gib einen Profilnamen ein',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nachname',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 38),
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
