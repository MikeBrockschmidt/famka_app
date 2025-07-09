import 'package:flutter/material.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/user_role.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image.dart';
import 'package:famka_app/src/theme/color_theme.dart';

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

  void _handleCreate() async {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gruppenname darf nicht leer sein.'),
          backgroundColor: AppColors.famkaRed,
        ),
      );
      return;
    }

    final newGroup = Group(
      groupId: widget.db.generateNewGroupId(),
      groupName: name,
      groupLocation: location,
      groupDescription: description,
      groupAvatarUrl: _avatarUrl,
      creatorId: widget.currentUser.profilId,
      groupMembers: [widget.currentUser],
      userRoles: {widget.currentUser.profilId: UserRole.admin},
    );

    try {
      await widget.db.addGroup(newGroup);

      if (!mounted) return;

      widget.onGroupCreated(newGroup);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Erstellen der Gruppe: $e'),
          backgroundColor: AppColors.famkaRed,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label, TextTheme theme) {
    return InputDecoration(
      labelText: label,
      labelStyle: theme.bodySmall,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.famkaGrey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.famkaGrey, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: AppColors.famkaWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(
          color: AppColors.famkaYellow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Neue Gruppe erstellen',
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
              decoration: _inputDecoration('Gruppenname', theme),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: _inputDecoration('Ort', theme),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: _inputDecoration('Beschreibung', theme),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _handleCreate,
              child: const ButtonLinearGradient(
                buttonText: 'Erstellen',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
