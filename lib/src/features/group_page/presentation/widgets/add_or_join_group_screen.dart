import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image.dart';
import 'package:famka_app/src/common/image_selection_context.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';

class AddOrJoinGroupScreen extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final AppUser currentUser;

  const AddOrJoinGroupScreen({
    super.key,
    required this.db,
    required this.auth,
    required this.currentUser,
  });

  @override
  State<AddOrJoinGroupScreen> createState() => _AddOrJoinGroupScreenState();
}

class _AddOrJoinGroupScreenState extends State<AddOrJoinGroupScreen> {
  final TextEditingController _newGroupNameController = TextEditingController();
  final TextEditingController _newGroupDescriptionController =
      TextEditingController();
  final TextEditingController _newGroupLocationController =
      TextEditingController();
  final GlobalKey<FormState> _createGroupFormKey = GlobalKey<FormState>();

  final Uuid _uuid = const Uuid();

  late String _groupAvatarUrl;

  @override
  void initState() {
    super.initState();
    _groupAvatarUrl = 'assets/fotos/default.jpg';
  }

  @override
  void dispose() {
    _newGroupNameController.dispose();
    _newGroupDescriptionController.dispose();
    _newGroupLocationController.dispose();
    super.dispose();
  }

  void _handleGroupAvatarSelected(String newUrl) {
    setState(() {
      _groupAvatarUrl = newUrl;
    });
  }

  Future<void> _createGroup() async {
    if (!(_createGroupFormKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fillRequiredFields),
          backgroundColor: AppColors.famkaRed,
        ),
      );
      return;
    }

    final String groupId = _uuid.v4();
    final String groupName = _newGroupNameController.text.trim();
    final String groupDescription = _newGroupDescriptionController.text.trim();
    final String groupLocation = _newGroupLocationController.text.trim();

    final String finalGroupAvatarUrl = _groupAvatarUrl;

    final Map<String, UserRole> userRoles = {
      widget.currentUser.profilId: UserRole.admin,
    };

    final List<AppUser> groupMembers = [
      widget.currentUser,
    ];

    final Group newGroup = Group(
      groupId: groupId,
      groupName: groupName,
      groupLocation: groupLocation,
      groupDescription: groupDescription,
      groupAvatarUrl: finalGroupAvatarUrl,
      creatorId: widget.currentUser.profilId,
      groupMembers: groupMembers,
      userRoles: userRoles,
    );

    try {
      await widget.db.addGroup(newGroup);
      widget.db.currentGroup = newGroup;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.groupCreatedSuccess(groupName)),
            backgroundColor: AppColors.famkaCyan,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.errorCreatingGroup}: ${e.toString()}'),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider groupImageProvider;
    if (_groupAvatarUrl.startsWith('http')) {
      groupImageProvider = NetworkImage(_groupAvatarUrl);
    } else if (_groupAvatarUrl.startsWith('assets/')) {
      groupImageProvider = AssetImage(_groupAvatarUrl);
    } else {
      try {
        final file = File(_groupAvatarUrl);
        if (file.existsSync()) {
          groupImageProvider = FileImage(file);
        } else {
          debugPrint(
              'Warnung: Lokales Bild konnte nicht geladen werden: ${_groupAvatarUrl}. Verwende Default.jpg');
          groupImageProvider = const AssetImage('assets/fotos/default.jpg');
        }
      } catch (e) {
        debugPrint(
            'Fehler beim Laden des lokalen Bildes: $e. Verwende Default.jpg');
        groupImageProvider = const AssetImage('assets/fotos/default.jpg');
      }
    }

    const double verticalTitleDividerSpacing = 0.2;

    return Scaffold(
      backgroundColor: AppColors.famkaWhite,
      appBar: AppBar(
        backgroundColor: AppColors.famkaWhite,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: kToolbarHeight + 50 + verticalTitleDividerSpacing,
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilPage(
                              db: widget.db,
                              auth: widget.auth,
                              currentUser: widget.currentUser,
                              isOwnProfile: true,
                            ),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(14.0),
                        child:
                            Icon(Icons.arrow_back, color: AppColors.famkaBlack),
                      ),
                    ),
                    Text(
                      'Gruppe',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                SizedBox(height: verticalTitleDividerSpacing),
                const Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: AppColors.famkaBlack,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _createGroupFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ProfilImage(
                  widget.db,
                  currentAvatarUrl: _groupAvatarUrl,
                  onAvatarSelected: _handleGroupAvatarSelected,
                  contextType: ImageSelectionContext.group,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _newGroupNameController,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.groupName,
                  hintText:
                      AppLocalizations.of(context)!.addOrJoinGroupCreateHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!
                        .addOrJoinGroupGroupNameEmpty;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newGroupDescriptionController,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.groupDescription,
                  hintText: AppLocalizations.of(context)!
                      .addOrJoinGroupDescriptionHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newGroupLocationController,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.groupLocation,
                  hintText:
                      AppLocalizations.of(context)!.addOrJoinGroupLocationHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              InkWell(
                onTap: _createGroup,
                child: ButtonLinearGradient(
                  buttonText:
                      AppLocalizations.of(context)!.addOrJoinGroupCreateButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
