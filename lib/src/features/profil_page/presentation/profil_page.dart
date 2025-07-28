import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/common/bottom_navigation.dart';
import 'package:famka_app/src/common/headline_p.dart';
import 'package:famka_app/src/common/profil_avatar_row.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/login/presentation/login_screen.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/add_or_join_group_screen.dart';
import 'package:flutter/services.dart';
import 'package:famka_app/src/common/legal_info_page.dart';

class ProfilPage extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final AppUser currentUser;

  const ProfilPage({
    super.key,
    required this.db,
    required this.auth,
    required this.currentUser,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // Neue Controller für Vor- und Nachname
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _miscellaneousController =
      TextEditingController();

  // Neue FocusNodes für Vor- und Nachname
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _miscellaneousFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  late Future<List<Group>> _userGroupsFuture;
  late String _currentProfileAvatarUrl;

  bool _hasChanges = false;
  // Initialwerte für die neuen Felder
  String? _initialFirstName;
  String? _initialLastName;
  String? _initialPhoneNumber;
  String? _initialEmail;
  String? _initialMiscellaneous;
  String? _initialAvatarUrl;

  @override
  void initState() {
    super.initState();
    // Controller mit den aktuellen Benutzerdaten initialisieren
    _firstNameController.text = widget.currentUser.firstName ?? '';
    _lastNameController.text = widget.currentUser.lastName ?? '';
    _phoneNumberController.text = widget.currentUser.phoneNumber ?? '';
    _emailController.text = widget.currentUser.email ?? '';
    _miscellaneousController.text = widget.currentUser.miscellaneous ?? '';
    _currentProfileAvatarUrl =
        widget.currentUser.avatarUrl ?? 'assets/fotos/default.jpg';

    // Initialwerte speichern, um Änderungen zu verfolgen
    _initialFirstName = widget.currentUser.firstName;
    _initialLastName = widget.currentUser.lastName;
    _initialPhoneNumber = widget.currentUser.phoneNumber;
    _initialEmail = widget.currentUser.email;
    _initialMiscellaneous = widget.currentUser.miscellaneous;
    _initialAvatarUrl = widget.currentUser.avatarUrl;

    _loadUserGroups();

    // Listener für die neuen Controller hinzufügen
    _firstNameController.addListener(_checkIfHasChanges);
    _lastNameController.addListener(_checkIfHasChanges);
    _phoneNumberController.addListener(_checkIfHasChanges);
    _emailController.addListener(_checkIfHasChanges);
    _miscellaneousController.addListener(_checkIfHasChanges);

    _checkIfHasChanges();
  }

  @override
  void dispose() {
    // Listener für die neuen Controller entfernen
    _firstNameController.removeListener(_checkIfHasChanges);
    _lastNameController.removeListener(_checkIfHasChanges);
    _phoneNumberController.removeListener(_checkIfHasChanges);
    _emailController.removeListener(_checkIfHasChanges);
    _miscellaneousController.removeListener(_checkIfHasChanges);

    // Controller für die neuen Felder entsorgen
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _miscellaneousController.dispose();
    _phoneNumberController
        .dispose(); // Sicherstellen, dass dies auch entsorgt wird

    // FocusNodes für die neuen Felder entsorgen
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _emailFocusNode.dispose();
    _miscellaneousFocusNode.dispose();

    super.dispose();
  }

  void _checkIfHasChanges() {
    final bool newHasChanges =
        _firstNameController.text != (_initialFirstName ?? '') ||
            _lastNameController.text != (_initialLastName ?? '') ||
            _phoneNumberController.text != (_initialPhoneNumber ?? '') ||
            _emailController.text != (_initialEmail ?? '') ||
            _miscellaneousController.text != (_initialMiscellaneous ?? '') ||
            _currentProfileAvatarUrl !=
                (_initialAvatarUrl ?? 'assets/fotos/default.jpg');

    if (_hasChanges != newHasChanges) {
      setState(() {
        _hasChanges = newHasChanges;
      });
    }
  }

  // Optional: Validierung für Vor- und Nachname (kann leer bleiben, wenn gewünscht)
  String? _validateName(String? input) {
    if (input == null || input.trim().isEmpty) {
      // return 'Name darf nicht leer sein'; // Wenn der Name zwingend ist
      return null; // Wenn der Name optional ist
    }
    return null;
  }

  String? _validateEmail(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(input)) {
      return 'Ungültige E-Mail Adresse';
    }
    return null;
  }

  String? _validatePhoneNumber(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    final phoneRegex = RegExp(r'^\+?\d{8,}$');
    if (!phoneRegex.hasMatch(input)) {
      return 'Ungültige Telefonnummer (min. 8 Ziffern, nur Zahlen)';
    }
    return null;
  }

  void _loadUserGroups() {
    setState(() {
      _userGroupsFuture = widget.db.getGroupsOfUser();
    });
  }

  void _handleProfileAvatarSelected(String newUrl) async {
    setState(() {
      _currentProfileAvatarUrl = newUrl;
      _checkIfHasChanges();
    });

    final updatedUser = widget.currentUser.copyWith(
      avatarUrl: newUrl.isEmpty ? null : newUrl,
    );

    try {
      await widget.db.updateUser(updatedUser);
      _initialAvatarUrl = updatedUser.avatarUrl;
      _checkIfHasChanges();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profilbild aktualisiert."),
            backgroundColor: AppColors.famkaCyan,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fehler beim Aktualisieren des Profilbilds: $e"),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
    }
  }

  void _saveUserData() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedUser = AppUser(
        profilId: widget.currentUser.profilId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty
            ? null
            : _phoneNumberController.text.trim(),
        avatarUrl: _currentProfileAvatarUrl,
        miscellaneous: _miscellaneousController.text.trim().isEmpty
            ? null
            : _miscellaneousController.text.trim(),
        password: widget.currentUser.password,
        canCreateGroups: widget.currentUser.canCreateGroups,
      );

      try {
        await widget.db.updateUser(updatedUser);

        setState(() {
          _initialFirstName = updatedUser.firstName;
          _initialLastName = updatedUser.lastName;
          _initialPhoneNumber = updatedUser.phoneNumber;
          _initialEmail = updatedUser.email;
          _initialMiscellaneous = updatedUser.miscellaneous;
          _initialAvatarUrl = updatedUser.avatarUrl;
        });
        _checkIfHasChanges();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profilinformationen gespeichert."),
              backgroundColor: AppColors.famkaCyan,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Fehler beim Speichern der Profilinformationen: $e'),
              backgroundColor: AppColors.famkaRed,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Bitte überprüfen Sie Ihre Eingaben."),
          backgroundColor: AppColors.famkaRed,
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await widget.auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingComplete', false);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => LoginScreen(widget.db, widget.auth)),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Abmelden: $e'),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
    }
  }

  void _navigateToAddGroupScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrJoinGroupScreen(
          db: widget.db,
          auth: widget.auth,
          currentUser: widget.currentUser,
        ),
      ),
    );
    _loadUserGroups();
  }

  void _showProfileIdDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Deine Profil-ID',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.famkaBlack,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dies ist deine persönliche ID. Du kannst sie mit anderen teilen, damit sie dich zu Gruppen einladen können.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              SelectableText(
                widget.currentUser.profilId,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.famkaCyan,
                    ),
              ),
            ],
          ),
          actions: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.currentUser.profilId));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil-ID kopiert!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const ButtonLinearGradient(buttonText: 'Kopieren'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Schließen',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToLegalInfoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LegalInfoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          if (_hasChanges) {
            await Future.sync(_saveUserData);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              HeadlineP(
                screenHead: 'Profil',
                rightActionWidgets: [
                  InkWell(
                    onTap: _navigateToLegalInfoPage,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.gavel_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: _showProfileIdDialog,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: ProfilImage(
                  widget.db,
                  currentAvatarUrl: _currentProfileAvatarUrl,
                  onAvatarSelected: _handleProfileAvatarSelected,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 0.3, height: 0.1, color: Colors.black),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      focusNode: _firstNameFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_lastNameFocusNode);
                      },
                      validator: _validateName,
                      decoration: const InputDecoration(
                        hintText: 'Vorname eingeben',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      focusNode: _lastNameFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(_phoneNumberFocusNode);
                      },
                      validator: _validateName,
                      decoration: const InputDecoration(
                        hintText: 'Nachname eingeben',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 0.3, height: 0.1, color: Colors.black),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    // Entfernt das horizontale Padding von diesem Form-Wrapper
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        // Column hier beibehalten, aber Padding innen für Textfelder
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Padding hier für die Textfelder beibehalten
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _phoneNumberController,
                                        focusNode: _phoneNumberFocusNode,
                                        keyboardType: TextInputType.phone,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (value) {
                                          FocusScope.of(context)
                                              .requestFocus(_emailFocusNode);
                                        },
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
                                Row(
                                  children: [
                                    const Icon(Icons.email, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (value) {
                                          FocusScope.of(context).requestFocus(
                                              _miscellaneousFocusNode);
                                        },
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
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _miscellaneousController,
                                        focusNode: _miscellaneousFocusNode,
                                        maxLines: null,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (value) {
                                          _miscellaneousFocusNode.unfocus();
                                          _saveUserData();
                                        },
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
                              ],
                            ),
                          ), // Ende des Padding für Textfelder

                          const SizedBox(height: 4),
                          const Divider(
                              thickness: 0.3, height: 1, color: Colors.black),
                          const SizedBox(height: 20),
                          // HIER BEGINNT DIE ÄNDERUNG FÜR DIE GRUPPEN-LEISTE
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Manueller linker Abstand für die Gruppen-Leiste
                                const SizedBox(width: 30),
                                if (widget.currentUser.canCreateGroups)
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _navigateToAddGroupScreen(context);
                                        },
                                        child: Container(
                                          width: 69,
                                          height: 69,
                                          decoration: BoxDecoration(
                                            color: AppColors.famkaGreen,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.group_add,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Gruppe hinzufügen',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                const SizedBox(width: 20),
                                FutureBuilder<List<Group>>(
                                  future: _userGroupsFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Fehler: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                          child:
                                              Text('Keine Gruppen gefunden.'));
                                    } else {
                                      return Row(
                                        children: snapshot.data!
                                            .map(
                                              (group) => Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 20),
                                                child: ProfilAvatarRow(
                                                  widget.db,
                                                  group: group,
                                                  currentUser:
                                                      widget.currentUser,
                                                  auth: widget.auth,
                                                  onGroupModified:
                                                      _loadUserGroups,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          // HIER ENDET DIE ÄNDERUNG FÜR DIE GRUPPEN-LEISTE
                          const SizedBox(height: 20),
                          Center(
                            child: Opacity(
                              opacity: _hasChanges ? 1.0 : 0.5,
                              child: InkWell(
                                onTap: _hasChanges ? _saveUserData : null,
                                child: const SizedBox(
                                  width: 150,
                                  height: 50,
                                  child: ButtonLinearGradient(
                                      buttonText: 'Speichern'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: InkWell(
                              onTap: _logout,
                              child: Text(
                                'Ausloggen',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: AppColors.famkaGrey,
                                        decoration: TextDecoration.none),
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
        bottomNavigationBar: FutureBuilder<List<Group>>(
          future: _userGroupsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 90,
                color: AppColors.famkaYellow,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.famkaCyan,
                    strokeWidth: 2,
                  ),
                ),
              );
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return BottomNavigation(
                widget.db,
                auth: widget.auth,
                currentUser: widget.currentUser,
                initialGroup: null,
                initialIndex: 0,
              );
            } else {
              return BottomNavigationThreeCalendar(
                widget.db,
                auth: widget.auth,
                currentUser: widget.currentUser,
                initialGroup: widget.db.currentGroup ?? snapshot.data!.first,
                initialIndex: 0,
              );
            }
          },
        ),
      ),
    );
  }
}
