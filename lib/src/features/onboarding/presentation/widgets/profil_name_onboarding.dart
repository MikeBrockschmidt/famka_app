import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding3.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famka_app/src/common/image_selection_context.dart'; // <--- IMPORT WICHTIG

class ProfilNameOnboarding extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final AppUser user;

  const ProfilNameOnboarding({
    super.key,
    required this.db,
    required this.auth,
    required this.user,
  });

  @override
  State<ProfilNameOnboarding> createState() => _ProfilNameOnboardingState();
}

class _ProfilNameOnboardingState extends State<ProfilNameOnboarding> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _currentAvatarUrl;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.firstName ?? '';
    _lastNameController.text = widget.user.lastName ?? '';
    _emailController.text = widget.user.email ?? '';
    _phoneNumberController.text = widget.user.phoneNumber ?? '';
    _currentAvatarUrl = widget.user.avatarUrl;

    print('Initial avatarUrl in ProfilNameOnboarding: $_currentAvatarUrl');
    print(
        'Initial AppUser ID in ProfilNameOnboarding: ${widget.user.profilId}');
    print(
        'FirebaseAuth currentUser UID in ProfilNameOnboarding initState: ${FirebaseAuth.instance.currentUser?.uid}');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _handleAvatarSelected(String newUrl) {
    setState(() {
      _currentAvatarUrl = newUrl;
    });
    print(
        'Avatar URL nach Auswahl (in _handleAvatarSelected): $_currentAvatarUrl');
    print(
        'FirebaseAuth currentUser UID nach Auswahl: ${FirebaseAuth.instance.currentUser?.uid}');
    print(
        'DB Current User ID nach Auswahl: ${widget.db.currentUser?.profilId}');
  }

  String? _validateEmail(String? input) {
    if (input == null || input.isEmpty) return null;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(input)) {
      return 'Ungültige E-Mail Adresse';
    }
    return null;
  }

  String? _validatePhoneNumber(String? input) {
    if (input == null || input.isEmpty) return null;
    final phoneRegex = RegExp(r'^\+?\d{8,}$');
    if (!phoneRegex.hasMatch(input)) {
      return 'Ungültige Telefonnummer (min. 8 Ziffern, nur Zahlen)';
    }
    return null;
  }

  void _saveUserDataAndNavigate() async {
    print(
        'FirebaseAuth User UID beim Speichern (vor Validation): ${FirebaseAuth.instance.currentUser?.uid}');
    print(
        'DB Current User ID beim Speichern (vor Validation): ${widget.db.currentUser?.profilId}');

    if (_formKey.currentState?.validate() ?? false) {
      final updatedUser = AppUser(
        profilId: widget.user.profilId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty
            ? null
            : _phoneNumberController.text.trim(),
        avatarUrl: _currentAvatarUrl,
        miscellaneous: widget.user.miscellaneous,
        password: widget.user.password,
      );

      if (updatedUser.profilId == null ||
          FirebaseAuth.instance.currentUser?.uid == null) {
        print(
            'FEHLER: Profil-ID (${updatedUser.profilId}) oder FirebaseAuth UID (${FirebaseAuth.instance.currentUser?.uid}) ist NULL vor dem Speichern!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  "Fehler: Keine Benutzer-ID verfügbar. Bitte melden Sie sich an."),
              backgroundColor: AppColors.famkaRed,
            ),
          );
        }
        return;
      }

      try {
        await widget.db.updateUser(updatedUser);
        widget.db.currentUser = updatedUser;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Profilinformationen gespeichert."),
              backgroundColor: AppColors.famkaCyan,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Onboarding3Screen(
                db: widget.db,
                auth: widget.auth,
                user: updatedUser,
              ),
            ),
          );
        }
      } catch (e) {
        print('Fehler beim Speichern der Benutzerdaten: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Speichern der Benutzerdaten: $e'),
              backgroundColor: AppColors.famkaRed,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Bitte überprüfen Sie Ihre Eingaben."),
            backgroundColor: AppColors.famkaCyan,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: ProfilImage(
                        widget.db,
                        currentAvatarUrl: _currentAvatarUrl,
                        onAvatarSelected: _handleAvatarSelected,
                        contextType: ImageSelectionContext
                            .profile, // <--- HIER IST DIE WICHTIGE ANPASSUNG
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: "Vorname",
                            hintText: "Vorname eingeben",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Vorname eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: "Nachname",
                            hintText: "Nachname eingeben",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Nachname eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          decoration: const InputDecoration(
                            labelText: "E-Mail Adresse",
                            hintText: "E-Mail Adresse eingeben",
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          contextMenuBuilder: (context, editableTextState) {
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          validator: _validatePhoneNumber,
                          decoration: const InputDecoration(
                            labelText: "Telefonnummer (optional)",
                            hintText: "Telefonnummer eingeben",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _saveUserDataAndNavigate,
                        child: const ButtonLinearGradient(
                            buttonText: 'Fortfahren'),
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
