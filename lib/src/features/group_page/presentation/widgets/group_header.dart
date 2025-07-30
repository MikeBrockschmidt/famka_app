import 'package:flutter/material.dart';
import 'package:famka_app/src/common/headline_g.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/group_avatar.dart'; // Import für GroupAvatar
import 'package:famka_app/src/data/database_repository.dart'; // Import für DatabaseRepository
import 'package:famka_app/src/features/group_page/domain/group.dart'; // Import für Group

class GroupHeader extends StatelessWidget {
  final TextEditingController groupNameController;
  final FocusNode groupNameFocusNode;
  final bool showDeleteButton;
  final VoidCallback onDeleteGroup;
  final String userRoleText;
  // NEUE PARAMETER FÜR GROUPAVATAR
  final DatabaseRepository db;
  final String
      groupAvatarUrl; // <--- HIER KORRIGIERT: Von 'String?' zu 'String'
  final Function(String) onAvatarChanged;
  final bool isUserAdmin;
  final Group currentGroup;

  const GroupHeader({
    super.key,
    required this.groupNameController,
    required this.groupNameFocusNode,
    required this.showDeleteButton,
    required this.onDeleteGroup,
    required this.userRoleText,
    // NEUE PARAMETER INITIALISIEREN
    required this.db,
    required this.groupAvatarUrl, // <--- Jetzt auch hier 'required' String
    required this.onAvatarChanged,
    required this.isUserAdmin,
    required this.currentGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HeadlineG(
          screenHead: 'Gruppe',
        ),
        // HIER STEHT JETZT DAS GRUPPENFOTO DIREKT UNTER DER HEADLINE
        GroupAvatar(
          db: db,
          groupAvatarUrl: groupAvatarUrl,
          onAvatarChanged: onAvatarChanged,
          isUserAdmin: isUserAdmin,
          currentGroup: currentGroup,
        ),
        const SizedBox(height: 20), // Abstand nach dem Gruppenfoto
        const Divider(
          thickness: 0.3,
          height: 0.1,
          color: AppColors.famkaBlack,
        ),
        const SizedBox(height: 20), // Abstand vor dem Gruppennamen/Rolle
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: groupNameController,
                        focusNode: groupNameFocusNode,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          groupNameFocusNode.unfocus();
                        },
                        style: Theme.of(context).textTheme.labelMedium,
                        decoration: const InputDecoration(
                          hintText: 'Gruppenname',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (showDeleteButton)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: AppColors.famkaBlack,
                        ),
                        onPressed: onDeleteGroup,
                        iconSize: 24,
                      ),
                  ],
                ),
                if (userRoleText.isNotEmpty)
                  Text(
                    userRoleText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.famkaGrey,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20), // Abstand vor der letzten Trennlinie
        const Divider(
          thickness: 0.3,
          height: 0.1,
          color: AppColors.famkaBlack,
        ),
      ],
    );
  }
}
