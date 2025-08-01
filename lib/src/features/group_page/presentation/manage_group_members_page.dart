import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/image_utils.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';

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
      print('Fehler beim Laden der Benutzer: $e');
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
    setState(() {
      _currentGroupMembersEditable.remove(member);
      _hasChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final membersToRemove = widget.group.groupMembers.where(
          (originalMember) => !_currentGroupMembersEditable.any(
              (editedMember) =>
                  editedMember.profilId == originalMember.profilId));
      for (var member in membersToRemove) {
        await widget.db
            .removeUserFromGroup(member.profilId, widget.group.groupId);
      }

      for (var user in _selectedNewUsers) {
        UserRole assignedRole;
        if ((user.email == null || user.email!.isEmpty) &&
            (user.phoneNumber == null || user.phoneNumber!.isEmpty)) {
          assignedRole = UserRole.passiveMember;
        } else {
          assignedRole = UserRole.member;
        }
        await widget.db
            .addUserToGroup(user, widget.group.groupId, assignedRole);
      }

      final updatedGroupMembers =
          List<AppUser>.from(_currentGroupMembersEditable)
            ..addAll(_selectedNewUsers);

      final Map<String, UserRole> updatedUserRoles =
          Map.from(widget.group.userRoles);

      for (var user in _selectedNewUsers) {
        final UserRole assignedRole;
        if ((user.email == null || user.email!.isEmpty) &&
            (user.phoneNumber == null || user.phoneNumber!.isEmpty)) {
          assignedRole = UserRole.passiveMember;
        } else {
          assignedRole = UserRole.member;
        }
        updatedUserRoles[user.profilId] = assignedRole;
      }

      for (var member in membersToRemove) {
        updatedUserRoles.remove(member.profilId);
      }

      final updatedGroup = widget.group.copyWith(
        groupMembers: updatedGroupMembers,
        userRoles: updatedUserRoles,
      );
      await widget.db.updateGroup(updatedGroup);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gruppenmitglieder erfolgreich aktualisiert!'),
          backgroundColor: AppColors.famkaGreen,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Fehler beim Speichern der Änderungen: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $e'),
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
        title: const Text('Gruppenmitglieder verwalten'),
        backgroundColor: AppColors.famkaBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Aktuelle Mitglieder:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.famkaBlack,
                        ),
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
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
                            roleText = '(Admin)';
                            break;
                          case UserRole.member:
                            roleText = '(Mitglied)';
                            break;
                          case UserRole.passiveMember:
                            roleText = '(Passiv)';
                            break;
                        }
                      }

                      final bool isTrulyPassive =
                          (member.email == null || member.email!.isEmpty) &&
                              (member.phoneNumber == null ||
                                  member.phoneNumber!.isEmpty);

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
                            '${member.firstName ?? ''} ${member.lastName ?? ''} $roleText',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          subtitle: Text(
                            isTrulyPassive
                                ? 'Keine E-Mail / Telefonnummer'
                                : (member.email?.isNotEmpty ?? false
                                    ? member.email!
                                    : (member.phoneNumber?.isNotEmpty ?? false
                                        ? member.phoneNumber!
                                        : 'Keine E-Mail / Telefonnummer')),
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
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
                  child: Center(
                    child: Opacity(
                      opacity: _hasChanges && !_isLoading ? 1.0 : 0.5,
                      child: InkWell(
                        onTap: _hasChanges && !_isLoading ? _saveChanges : null,
                        child: SizedBox(
                          width: 200,
                          height: 50,
                          child: ButtonLinearGradient(
                            buttonText:
                                _isLoading ? 'Speichern...' : 'Speichern',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
