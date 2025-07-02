import 'package:famka_app/src/common/profil_avatar_row.dart';
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

class Onboarding4 extends StatefulWidget {
  final DatabaseRepository db;
  final AppUser user;
  final Group group;

  const Onboarding4({
    super.key,
    required this.db,
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
    _phoneNumberController.text = widget.user.phoneNumber;
    _emailController.text = widget.user.email;

    _miscellaneousController.text = widget.user.miscellaneous;
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
        profilId: widget.user.profilId,
        firstName: widget.user.firstName,
        lastName: widget.user.lastName,
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        birthDate: DateTime(2000, 1, 1),
        avatarUrl: widget.user.avatarUrl,
        miscellaneous: _miscellaneousController.text.trim(),
        password: widget.user.password,
      );

      await widget.db.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Daten wurden gespeichert."),
            backgroundColor: AppColors.famkaCyan,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilPage(
              db: widget.db,
              currentUser: updatedUser,
              group: widget.group,
            ),
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

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const HeadlineK(screenHead: 'Profil'),
                  const SizedBox(height: 20),
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
                              ProfilAvatarRow(
                                widget.db,
                                group: group,
                                currentUser: widget.user,
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: _saveUserData,
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
            child: OnboardingProgress4(widget.db),
          ),
        ],
      ),
    );
  }
}
