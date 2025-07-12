import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/common/profil_avatar_row.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/login/presentation/login_screen.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image3.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/add_or_join_group_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _phoneNumberController.text = widget.currentUser.phoneNumber ?? '';
    _emailController.text = widget.currentUser.email;
    _miscellaneousController.text = widget.currentUser.miscellaneous ?? '';
    _loadUserGroups();
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
        avatarUrl: widget.currentUser.avatarUrl,
        miscellaneous: _miscellaneousController.text.trim().isEmpty
            ? null
            : _miscellaneousController.text.trim(),
        password: widget.currentUser.password,
      );

      await widget.db.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profilinformationen gespeichert."),
            backgroundColor: AppColors.famkaCyan,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Bitte überprüfen Sie Ihre Eingaben."),
          backgroundColor: AppColors.famkaCyan,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const HeadlineK(screenHead: 'Profil'),
            const SizedBox(height: 20),
            Center(
              child: ProfilImage3(
                db: widget.db,
                avatarUrl:
                    widget.currentUser.avatarUrl ?? 'assets/fotos/default.jpg',
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
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: _saveUserData,
                              child: const SizedBox(
                                width: 150,
                                height: 50,
                                child: ButtonLinearGradient(
                                    buttonText: 'Speichern'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            InkWell(
                              onTap: _logout,
                              child: SizedBox(
                                width: 150,
                                height: 50,
                                child: ButtonLinearGradient(
                                  buttonText: 'Ausloggen',
                                ),
                              ),
                            ),
                          ],
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
      bottomNavigationBar: BottomNavigationThreeCalendar(
        widget.db,
        auth: widget.auth,
        currentUser: widget.currentUser,
        initialGroup: widget.db.currentGroup,
        initialIndex: 0,
      ),
    );
  }
}
