import 'package:famka_app/src/common/profil_avatar_row.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image3.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/common/color_row2.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/onboarding_process4.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import für SharedPreferences

/// Der vierte und letzte Bildschirm des Onboarding-Prozesses.
/// Hier kann der Benutzer zusätzliche Profilinformationen speichern
/// und das Onboarding als abgeschlossen markieren.
class Onboarding4 extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final AppUser user;
  final Group
      group; // Die Gruppe, die im vorherigen Schritt erstellt/ausgewählt wurde

  const Onboarding4({
    super.key,
    required this.db,
    required this.auth,
    required this.user,
    required this.group,
  });

  @override
  State<Onboarding4> createState() => _Onboarding4ScreenState();
}

class _Onboarding4ScreenState extends State<Onboarding4> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _miscellaneousController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialisiert die Textfelder mit den vorhandenen Benutzerdaten
    _phoneNumberController.text = widget.user.phoneNumber;
    _emailController.text = widget.user.email;
    _miscellaneousController.text = widget.user.miscellaneous;
  }

  @override
  void dispose() {
    // Entsorgt die Controller, um Speicherlecks zu vermeiden
    _phoneNumberController.dispose();
    _emailController.dispose();
    _miscellaneousController.dispose();
    super.dispose();
  }

  /// Validiert die E-Mail-Adresse.
  /// Erlaubt leere Eingaben, prüft aber das Format, wenn etwas eingegeben wird.
  String? _validateEmail(String? input) {
    if (input == null || input.isEmpty) {
      return null; // E-Mail ist optional
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(input)) {
      return 'Ungültige E-Mail Adresse';
    }
    return null;
  }

  /// Validiert die Telefonnummer.
  /// Erlaubt leere Eingaben, prüft aber das Format, wenn etwas eingegeben wird.
  String? _validatePhoneNumber(String? input) {
    if (input == null || input.isEmpty) {
      return null; // Telefonnummer ist optional
    }
    final phoneRegex =
        RegExp(r'^\+?\d{8,}$'); // Erlaubt optionales '+' und min. 8 Ziffern
    if (!phoneRegex.hasMatch(input)) {
      return 'Ungültige Telefonnummer (min. 8 Ziffern, nur Zahlen)';
    }
    return null;
  }

  /// Speichert die aktualisierten Benutzerdaten und markiert das Onboarding als abgeschlossen.
  /// Navigiert anschließend zum Hauptbildschirm (ProfilPage).
  void _saveUserData() async {
    // Validiert das Formular
    if (_formKey.currentState?.validate() ?? false) {
      // Erstellt ein aktualisiertes AppUser-Objekt mit den neuen Daten
      final updatedUser = AppUser(
        profilId: widget.user.profilId,
        firstName: widget.user.firstName, // Vorname bleibt unverändert
        lastName: widget.user.lastName, // Nachname bleibt unverändert
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        birthDate: DateTime(2000, 1, 1), // Geburtsdatum bleibt unverändert
        avatarUrl: widget.user.avatarUrl, // Avatar-URL bleibt unverändert
        miscellaneous: _miscellaneousController.text.trim(),
        password: widget.user.password, // Passwort bleibt unverändert
      );

      // Aktualisiert den Benutzer in der Datenbank
      await widget.db.updateUser(updatedUser);

      // --- WICHTIG: Markiert das Onboarding als abgeschlossen ---
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingComplete', true);
      // --------------------------------------------------------

      if (mounted) {
        // Zeigt eine Bestätigungs-Snackbar an
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                "Daten wurden gespeichert und Onboarding abgeschlossen."),
            backgroundColor: AppColors.famkaCyan,
          ),
        );

        // Navigiert zum Hauptbildschirm (ProfilPage) und entfernt alle
        // vorherigen Routen aus dem Navigations-Stack.
        Navigator.of(
          context,
          rootNavigator: true, // Navigiert zum obersten Navigator
        ).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfilPage(
              db: widget.db,
              currentUser: updatedUser,
              group: widget.group,
              auth: widget.auth,
            ),
          ),
        );
      }
    } else {
      // Zeigt eine Fehlermeldung an, wenn die Validierung fehlschlägt
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Bitte überprüfen Sie Ihre Eingaben."),
          backgroundColor: AppColors.famkaCyan,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group; // Die Gruppe aus den Widget-Eigenschaften

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Passt den Bildschirm an die Tastatur an
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const HeadlineK(screenHead: 'Profil'), // Überschrift
                  const SizedBox(height: 20),
                  // Profilbild-Anzeige
                  Center(
                    child: ProfilImage3(
                      db: widget.db,
                      avatarUrl: widget.user.avatarUrl,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                      thickness: 0.3, height: 0.1, color: Colors.black),
                  const SizedBox(height: 20),
                  // Anzeige des vollständigen Namens des Benutzers
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${widget.user.firstName} ${widget.user.lastName}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                      thickness: 0.3, height: 0.1, color: Colors.black),
                  const SizedBox(height: 10),
                  // Scrollbarer Bereich für die Eingabefelder
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Form(
                        key: _formKey, // Formularschlüssel für Validierung
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Telefonnummer-Eingabefeld
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneNumberController,
                                      keyboardType: TextInputType.phone,
                                      validator: _validatePhoneNumber,
                                      decoration: const InputDecoration(
                                        hintText: 'Telefonnummer eingeben',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ),
                                ],
                              ),
                              // E-Mail-Eingabefeld
                              Row(
                                children: [
                                  const Icon(Icons.email, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: _validateEmail,
                                      decoration: const InputDecoration(
                                        hintText: 'E-Mail Adresse eingeben',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ),
                                ],
                              ),
                              // Zusätzliche Infos-Eingabefeld
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _miscellaneousController,
                                      maxLines:
                                          null, // Ermöglicht mehrere Zeilen
                                      decoration: const InputDecoration(
                                        hintText: 'Zusätzliche Infos',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Divider(
                                  thickness: 0.3,
                                  height: 1,
                                  color: Colors.black),
                              const SizedBox(height: 20),
                              // Zeile für Profil-Avatare (falls relevant für diese Seite)
                              ProfilAvatarRow(
                                widget.db,
                                group: group,
                                currentUser: widget.user,
                                auth: widget
                                    .auth, // KORREKTUR: auth-Parameter übergeben
                              ),
                              const SizedBox(height: 20),
                              // "Speichern"-Button
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap:
                                      _saveUserData, // Ruft die Speicherlogik auf
                                  child: const SizedBox(
                                    width: 150,
                                    height: 50,
                                    child: ButtonLinearGradient(
                                        buttonText: 'Speichern'),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Untere Farbreihe und Onboarding-Fortschrittsanzeige
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ColorRow2(),
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: OnboardingProgress4(widget.db, widget.auth),
          ),
        ],
      ),
    );
  }
}
