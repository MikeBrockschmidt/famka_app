import 'package:flutter/material.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/image_utils.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/remove_member_dialog.dart';

class ManageGroupMembersPage extends StatefulWidget {
  final DatabaseRepository db;
  final Group group;
  final AppUser currentUser;
  final bool isCurrentUserAdmin;

  const ManageGroupMembersPage({
    super.key,
    required this.db,
    required this.group,
    required this.currentUser,
    required this.isCurrentUserAdmin,
  });

  @override
  State<ManageGroupMembersPage> createState() => _ManageGroupMembersPageState();
}

class _ManageGroupMembersPageState extends State<ManageGroupMembersPage> {
  late List<AppUser> _currentGroupMembersEditable;
  final List<AppUser> _selectedNewUsers = [];

  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentGroupMembersEditable =
        List<AppUser>.from(widget.group.groupMembers);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      await widget.db.getAllUsers();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeMember(AppUser member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RemoveMemberDialog(
          member: member,
          onConfirm: () {
            setState(() {
              _currentGroupMembersEditable.remove(member);
              _hasChanges = true;
            });
          },
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ...existing code...
      // Mitglieder identifizieren, die entfernt wurden
      final membersToRemove = widget.group.groupMembers.where(
          (originalMember) => !_currentGroupMembersEditable.any(
              (editedMember) =>
                  editedMember.profilId == originalMember.profilId));

      // Mitglieder nacheinander entfernen
      for (var member in membersToRemove) {
        await widget.db
            .removeUserFromGroup(member.profilId, widget.group.groupId);

        // Kurze Pause um sicherzustellen, dass die Änderung durchgeführt wurde
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Neue Gruppe abrufen nach dem Entfernen der Mitglieder
      await widget.db.getGroupAsync(widget.group.groupId);

      // Neue Mitglieder hinzufügen
      for (var user in _selectedNewUsers) {
        UserRole assignedRole;
        if (user.email.isEmpty && (user.phoneNumber?.isEmpty ?? true)) {
          assignedRole = UserRole.passiveMember;
        } else {
          assignedRole = UserRole.member;
        }
        await widget.db
            .addUserToGroup(user, widget.group.groupId, assignedRole);
      }

      // Reihenfolge speichern - wichtig!
      final newMemberOrder = _currentGroupMembersEditable
          .map((member) => member.profilId)
          .toList();
      // Neue Mitglieder hinzufügen zur Reihenfolge
      for (var user in _selectedNewUsers) {
        newMemberOrder.add(user.profilId);
      }
      await widget.db
          .updateGroupMemberOrder(widget.group.groupId, newMemberOrder);

      // Überprüfen ob wir die Gruppe nochmals aktualisieren müssen
      await widget.db.getGroupAsync(widget.group.groupId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.manageMembersUpdateSuccess),
          backgroundColor: AppColors.famkaGreen,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .manageMembersUpdateError(e.toString())),
          backgroundColor: AppColors.famkaRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageMembersTitle),
        backgroundColor: AppColors.famkaBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '${AppLocalizations.of(context)!.manageMembersCurrentTitle}:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.famkaBlack,
                          ),
                    ),
                  ),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _currentGroupMembersEditable.length,
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final AppUser member =
                            _currentGroupMembersEditable.removeAt(oldIndex);
                        _currentGroupMembersEditable.insert(newIndex, member);
                        _hasChanges = true;
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final member = _currentGroupMembersEditable[index];
                      final UserRole? memberRole =
                          widget.group.userRoles[member.profilId];
                      String roleText = '';
                      if (memberRole != null) {
                        switch (memberRole) {
                          case UserRole.admin:
                            roleText = AppLocalizations.of(context)!
                                .manageMembersRoleAdmin;
                            break;
                          case UserRole.member:
                            roleText = AppLocalizations.of(context)!
                                .manageMembersRoleMember;
                            break;
                          case UserRole.passiveMember:
                            roleText = AppLocalizations.of(context)!
                                .manageMembersRolePassive;
                            break;
                        }
                      }

                      final bool isTrulyPassive = member.email.isEmpty &&
                          (member.phoneNumber?.isEmpty ?? true);

                      final bool canRemoveMember = widget.isCurrentUserAdmin &&
                          member.profilId != widget.currentUser.profilId;

                      return Card(
                        key: ValueKey(member.profilId),
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16.0),
                        color: AppColors.famkaWhite,
                        child: ListTile(
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: ClipOval(
                              child: Image(
                                image:
                                    getDynamicImageProvider(member.avatarUrl) ??
                                        const AssetImage(
                                            'assets/grafiken/famka-kreis.png'),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person,
                                        size: 40, color: AppColors.famkaGrey),
                              ),
                            ),
                          ),
                          title: Text(
                            '${member.firstName} ${member.lastName} $roleText',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          subtitle: Text(
                            isTrulyPassive
                                ? AppLocalizations.of(context)!
                                    .manageMembersNoEmailPhone
                                : (member.email.isNotEmpty
                                    ? member.email
                                    : (member.phoneNumber?.isNotEmpty ?? false
                                        ? member.phoneNumber!
                                        : AppLocalizations.of(context)!
                                            .manageMembersNoEmailPhone)),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.drag_handle,
                                color: AppColors.famkaGrey,
                              ),
                              const SizedBox(width: 8),
                              if (canRemoveMember)
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline,
                                      color: AppColors.famkaRed),
                                  onPressed: () => _removeMember(member),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
                    child: Center(
                      child: Opacity(
                        opacity: _hasChanges && !_isLoading ? 1.0 : 0.5,
                        child: InkWell(
                          onTap:
                              _hasChanges && !_isLoading ? _saveChanges : null,
                          child: SizedBox(
                            width: 200,
                            height: 50,
                            child: ButtonLinearGradient(
                              buttonText: _isLoading
                                  ? AppLocalizations.of(context)!
                                      .manageMembersSavingButton
                                  : AppLocalizations.of(context)!
                                      .manageMembersSaveChangesButton,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
