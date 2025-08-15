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
  List<AppUser> _allAvailableUsers = [];
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
      final allUsersInDatabase = await widget.db.getAllUsers();
      if (!mounted) return;

      setState(() {
        _allAvailableUsers = allUsersInDatabase
            .where((user) => !widget.group.groupMembers
                .any((member) => member.profilId == user.profilId))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleNewUserSelection(AppUser user) {
    setState(() {
      if (_selectedNewUsers.contains(user)) {
        _selectedNewUsers.remove(user);
      } else {
        _selectedNewUsers.add(user);
      }
      _hasChanges = true;
    });
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
      print('🔵 SPEICHERE ÄNDERUNGEN:');
      print(
          '🔵 Originale Mitglieder: ${widget.group.groupMembers.map((m) => "${m.firstName} ${m.lastName} (${m.profilId})").toList()}');
      print(
          '🔵 Bearbeitete Mitglieder: ${_currentGroupMembersEditable.map((m) => "${m.firstName} ${m.lastName} (${m.profilId})").toList()}');
      print(
          '🔵 Neue Mitglieder: ${_selectedNewUsers.map((m) => "${m.firstName} ${m.lastName} (${m.profilId})").toList()}');

      // Mitglieder identifizieren, die entfernt wurden
      final membersToRemove = widget.group.groupMembers.where(
          (originalMember) => !_currentGroupMembersEditable.any(
              (editedMember) =>
                  editedMember.profilId == originalMember.profilId));

      print(
          '🔵 Zu entfernende Mitglieder: ${membersToRemove.map((m) => "${m.firstName} ${m.lastName} (${m.profilId})").toList()}');

      // Mitglieder nacheinander entfernen
      for (var member in membersToRemove) {
        print(
            '🔵 Entferne Mitglied: ${member.firstName} ${member.lastName} (${member.profilId})');
        await widget.db
            .removeUserFromGroup(member.profilId, widget.group.groupId);

        // Kurze Pause um sicherzustellen, dass die Änderung durchgeführt wurde
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Neue Gruppe abrufen nach dem Entfernen der Mitglieder
      final updatedGroupAfterRemove =
          await widget.db.getGroupAsync(widget.group.groupId);
      if (updatedGroupAfterRemove != null) {
        print(
            '🔵 Gruppenmitglieder nach dem Entfernen: ${updatedGroupAfterRemove.groupMembers.map((m) => "${m.firstName} ${m.lastName} (${m.profilId})").toList()}');
      }

      // Neue Mitglieder hinzufügen
      for (var user in _selectedNewUsers) {
        UserRole assignedRole;
        if (user.email.isEmpty && (user.phoneNumber?.isEmpty ?? true)) {
          assignedRole = UserRole.passiveMember;
          print(
              '🔵 Füge passives Mitglied hinzu: ${user.firstName} ${user.lastName} (${user.profilId})');
        } else {
          assignedRole = UserRole.member;
          print(
              '🔵 Füge aktives Mitglied hinzu: ${user.firstName} ${user.lastName} (${user.profilId})');
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

      print('🔵 Speichere neue Mitglieder-Reihenfolge: $newMemberOrder');
      await widget.db
          .updateGroupMemberOrder(widget.group.groupId, newMemberOrder);

      // Überprüfen ob wir die Gruppe nochmals aktualisieren müssen
      final Group? updatedGroupFromDB =
          await widget.db.getGroupAsync(widget.group.groupId);
      if (updatedGroupFromDB != null) {
        print('🔵 GRUPPE NACH ALLEN ÄNDERUNGEN:');
        print(
            '🔵 - Mitglieder IDs: ${updatedGroupFromDB.groupMembers.map((m) => m.profilId).toList()}');
        print(
            '🔵 - Passive Mitglieder Daten: ${updatedGroupFromDB.passiveMembersData.keys.toList()}');

        // Sicherstellen, dass entfernte Mitglieder nicht mehr in den passiveMembersData sind
        for (var member in membersToRemove) {
          if (updatedGroupFromDB.passiveMembersData
              .containsKey(member.profilId)) {
            print(
                '🔵 WARNUNG: Entferntes Mitglied ${member.profilId} ist immer noch in passiveMembersData!');
          }
        }
      }

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
      print('❌ Fehler beim Speichern der Änderungen: $e');
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
