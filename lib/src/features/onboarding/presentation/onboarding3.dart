import 'package:famka_app/src/common/color_row.dart';
import 'package:famka_app/src/common/color_row1.dart';
import 'package:famka_app/src/common/color_row2.dart';
import 'package:famka_app/src/common/color_row3.dart';
import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding4.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/onboarding_process3.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image.dart';
import 'package:famka_app/src/common/image_selection_context.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

class Onboarding3Screen extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final AppUser user;

  const Onboarding3Screen({
    super.key,
    required this.db,
    required this.auth,
    required this.user,
  });

  @override
  State<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends State<Onboarding3Screen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupLocationController =
      TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  String? _groupAvatarUrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupLocationController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  void _handleGroupAvatarSelected(String newUrl) {
    setState(() {
      _groupAvatarUrl = newUrl;
    });
  }

  void _createGroupAndNavigate() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final String newGroupId = widget.db.generateNewGroupId();

        final Group newGroup = Group(
          groupId: newGroupId,
          groupName: _groupNameController.text.trim(),
          groupLocation: _groupLocationController.text.trim(),
          groupDescription: _groupDescriptionController.text.trim(),
          groupAvatarUrl: _groupAvatarUrl ?? '',
          creatorId: widget.user.profilId,
          groupMembers: [widget.user],
          userRoles: {widget.user.profilId: UserRole.admin},
        );

        await widget.db.addGroup(newGroup);
        widget.db.currentGroup = newGroup;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .groupCreatedSuccess(newGroup.groupName)),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Onboarding4(
                db: widget.db,
                auth: widget.auth,
                user: widget.user,
                group: newGroup,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .createGroupError(e.toString()))),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.addOrJoinGroupRequiredFieldError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ColorRow(),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  HeadlineK(
                      screenHead: AppLocalizations.of(context)!.newGroupTitle),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                          bottom: 100, left: 16, right: 16),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Center(
                              child: GestureDetector(
                                onTap: () => _handleGroupAvatarSelected(""),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      width: 150,
                                      child: ProfilImage(
                                        widget.db,
                                        currentAvatarUrl: _groupAvatarUrl,
                                        onAvatarSelected:
                                            _handleGroupAvatarSelected,
                                        contextType:
                                            ImageSelectionContext.group,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.camera_alt,
                                      size: 48,
                                      color: Colors.white30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 58),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _groupNameController,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!
                                            .addOrJoinGroupTitle,
                                        hintText: AppLocalizations.of(context)!
                                            .addOrJoinGroupCreateHint,
                                        border: const OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return AppLocalizations.of(context)!
                                              .addOrJoinGroupGroupNameEmpty;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _groupLocationController,
                                      decoration: InputDecoration(
                                        labelText:
                                            "${AppLocalizations.of(context)!.groupLocation} (optional)",
                                        hintText: AppLocalizations.of(context)!
                                            .addOrJoinGroupLocationHint,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _groupDescriptionController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        labelText:
                                            "${AppLocalizations.of(context)!.groupDescription} (optional)",
                                        hintText: AppLocalizations.of(context)!
                                            .addOrJoinGroupDescriptionHint,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 26),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: _createGroupAndNavigate,
                                  child: ButtonLinearGradient(
                                      buttonText: AppLocalizations.of(context)!
                                          .addOrJoinGroupCreateButton),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: OnboardingProgress3(widget.db, widget.auth),
          ),
        ],
      ),
    );
  }
}
