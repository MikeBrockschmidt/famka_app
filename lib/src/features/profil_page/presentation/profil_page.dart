import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/common/bottom_navigation.dart'; // NEU: Importieren Sie BottomNavigation
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
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _miscellaneousController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late Future<List<Group>> _userGroupsFuture;
  late String _currentProfileAvatarUrl;

  @override
  void initState() {
    super.initState();
    _phoneNumberController.text = widget.currentUser.phoneNumber ?? '';
    _emailController.text = widget.currentUser.email ?? '';
    _miscellaneousController.text = widget.currentUser.miscellaneous ?? '';
    _currentProfileAvatarUrl =
        widget.currentUser.avatarUrl ?? 'assets/fotos/default.jpg';
    _loadUserGroups(); // Initial lädt die Gruppen
  }

  void _loadUserGroups() {
    setState(() {
      _userGroupsFuture = widget.db.getGroupsOfUser();
    });
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _emailController.dispose();
    _miscellaneousController.dispose();
    super.dispose();
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

  void _handleProfileAvatarSelected(String newUrl) async {
    setState(() {
      _currentProfileAvatarUrl = newUrl;
    });

    final updatedUser = widget.currentUser.copyWith(
      avatarUrl: newUrl.isEmpty ? null : newUrl,
    );

    try {
      await widget.db.updateUser(updatedUser);
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
        firstName: widget.currentUser.firstName,
        lastName: widget.currentUser.lastName,
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty
            ? null
            : _phoneNumberController.text.trim(),
        avatarUrl: _currentProfileAvatarUrl,
        miscellaneous: _miscellaneousController.text.trim().isEmpty
            ? null
            : _miscellaneousController.text.trim(),
        password: widget.currentUser.password,
      );

      await widget.db.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profilinformationen gespeichert."),
            backgroundColor: AppColors.famkaCyan,
          ),
        );
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
    _loadUserGroups(); // Gruppenliste nach Rückkehr neu laden
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            HeadlineP(
              screenHead: 'Profil',
              rightActionWidget: InkWell(
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
              padding: const EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.currentUser.firstName ?? ''} ${widget.currentUser.lastName ?? ''}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 0.3, height: 0.1, color: Colors.black),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Padding(
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
                                keyboardType: TextInputType.phone,
                                validator: _validatePhoneNumber,
                                decoration: const InputDecoration(
                                  hintText: 'Telefonnummer eingeben',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: Theme.of(context).textTheme.labelSmall,
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
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                                decoration: const InputDecoration(
                                  hintText: 'E-Mail Adresse eingeben',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: Theme.of(context).textTheme.labelSmall,
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
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: 'Zusätzliche Infos',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Divider(
                            thickness: 0.3, height: 1, color: Colors.black),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
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
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
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
                                        child:
                                            Text('Fehler: ${snapshot.error}'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text('Keine Gruppen gefunden.'));
                                  } else {
                                    // Zeigen Sie die Gruppen-Avatare nur an, wenn Gruppen vorhanden sind
                                    return Row(
                                      children: snapshot.data!
                                          .map(
                                            (group) => Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20),
                                              child: ProfilAvatarRow(
                                                widget.db,
                                                group: group,
                                                currentUser: widget.currentUser,
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
                        const SizedBox(height: 20),
                        Center(
                          child: InkWell(
                            onTap: _saveUserData,
                            child: const SizedBox(
                              width: 150,
                              height: 50,
                              child:
                                  ButtonLinearGradient(buttonText: 'Speichern'),
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
      // Der BottomNavigationBar hängt jetzt vom FutureBuilder ab
      bottomNavigationBar: FutureBuilder<List<Group>>(
        future: _userGroupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Zeigen Sie einen Ladeindikator oder eine Standard-Navigationsleiste
            // während die Gruppen geladen werden.
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
            // Wenn keine Gruppen vorhanden sind oder ein Fehler auftritt,
            // verwenden Sie BottomNavigation (nur Menü).
            return BottomNavigation(
              widget.db,
              auth: widget.auth,
              currentUser: widget.currentUser,
              initialGroup: null, // Keine Gruppe, da keine vorhanden
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
    );
  }
}
