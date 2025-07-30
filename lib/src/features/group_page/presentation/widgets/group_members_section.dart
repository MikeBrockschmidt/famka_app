import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/group_members_list.dart'; // Import für GroupMembersList

class GroupMembersSection extends StatelessWidget {
  final VoidCallback onShowGroupIdDialog;
  final VoidCallback onShowAddPassiveMemberDialog;
  final VoidCallback onShowInviteDialog;
  final VoidCallback onManageGroupMembers;
  final DatabaseRepository db;
  final AuthRepository auth;
  final AppUser currentUser;
  final List<AppUser> members;

  const GroupMembersSection({
    super.key,
    required this.onShowGroupIdDialog,
    required this.onShowAddPassiveMemberDialog,
    required this.onShowInviteDialog,
    required this.onManageGroupMembers,
    required this.db,
    required this.auth,
    required this.currentUser,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mitglieder:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onShowGroupIdDialog,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.info_outline,
                        color: AppColors.famkaBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: onShowAddPassiveMemberDialog,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.person_add_alt_1,
                        color: AppColors.famkaBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: onShowInviteDialog,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.event_available,
                        color: AppColors.famkaBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: onManageGroupMembers,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.edit,
                        color: AppColors.famkaBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GroupMembersList(
          db: db,
          auth: auth,
          currentUser: currentUser,
          members: members,
        ),
      ],
    );
  }
}
