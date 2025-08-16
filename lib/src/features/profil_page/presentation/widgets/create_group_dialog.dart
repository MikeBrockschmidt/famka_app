import 'package:flutter/material.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

class CreateGroupDialog extends StatefulWidget {
  final DatabaseRepository db;
  final AppUser currentUser;
  final void Function(Group) onGroupCreated;

  const CreateGroupDialog({
    super.key,
    required this.db,
    required this.currentUser,
    required this.onGroupCreated,
  });

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _avatarUrl = 'assets/images/default_group_avatar.png';

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, TextTheme theme) {
    return InputDecoration(
      labelText: label,
      hintText: label,
      border: const OutlineInputBorder(),
      labelStyle: theme.bodyMedium?.copyWith(color: Colors.grey.shade600),
    );
  }

  Future<void> _handleCreate() async {
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text(
            l10n.enterGroupName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
      return;
    }

    final newGroupId = const Uuid().v4();
    final newGroup = Group(
      groupId: newGroupId,
      groupName: _nameController.text.trim(),
      groupLocation: _locationController.text.trim(),
      groupDescription: _descriptionController.text.trim(),
      groupAvatarUrl: _avatarUrl,
      creatorId: widget.currentUser.profilId,
      groupMembers: [widget.currentUser],
      userRoles: {widget.currentUser.profilId: UserRole.admin},
    );

    try {
      await widget.db.addGroup(newGroup);
      await widget.db
          .addUserToGroup(widget.currentUser, newGroup.groupId, UserRole.admin);

      widget.onGroupCreated(newGroup);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaGreen,
            content: Text(
              l10n.groupCreatedSuccess(newGroup.groupName),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text(
              l10n.createGroupError(e.toString()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: AppColors.famkaWhite,
      surfaceTintColor: Colors.transparent,
      title: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create Group',
              style: theme.labelMedium?.copyWith(color: AppColors.famkaBlack),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ProfilImage(
              widget.db,
              currentAvatarUrl: _avatarUrl,
              onAvatarSelected: (url) {
                setState(() {
                  _avatarUrl = url;
                });
              },
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
              decoration: _inputDecoration(l10n.groupNameLabel, theme),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
              decoration: _inputDecoration(l10n.locationLabel, theme),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
              decoration: _inputDecoration(l10n.descriptionLabel, theme),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _handleCreate,
              child: ButtonLinearGradient(
                buttonText: l10n.createButtonText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
