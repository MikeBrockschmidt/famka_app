import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/common/headline_g.dart';
import 'package:famka_app/src/features/group_page/presentation/manage_group_members_page.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:flutter/services.dart';

import 'package:famka_app/src/features/login/domain/user_role.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/group_id_dialog.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/invite_user_dialog.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/confirm_delete_group_dialog.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/add_passive_member_dialog.dart';

import 'package:famka_app/src/features/group_page/presentation/widgets/group_avatar.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/group_header.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/group_details.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/group_members_section.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/save_button.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/debug_tool.dart';

class GroupPage extends StatefulWidget {
  final DatabaseRepository db;
  final Group group;
  final AppUser currentUser;
  final AuthRepository auth;

  const GroupPage({
    super.key,
    required this.db,
    required this.group,
    required this.currentUser,
    required this.auth,
  });

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  Group? _currentGroup;
  late TextEditingController _groupNameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  late FocusNode _groupNameFocusNode;
  late FocusNode _locationFocusNode;
  late FocusNode _descriptionFocusNode;

  bool _hasChanges = false;
  bool _isLoading = true;
  String? _currentUserId;
  bool _isUserAdmin = false;

  _GroupPageState() {
    _groupNameController = TextEditingController();
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
    _groupNameFocusNode = FocusNode();
    _locationFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
  }

  @override
  void initState() {
    super.initState();
    _loadGroupAndUserData();
  }

  @override
  void didUpdateWidget(covariant GroupPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.group.groupId != oldWidget.group.groupId) {
      _loadGroupAndUserData();
    }
  }

  @override
  void dispose() {
    _groupNameController.removeListener(_checkIfHasChanges);
    _groupNameController.dispose();
    _locationController.removeListener(_checkIfHasChanges);
    _locationController.dispose();
    _descriptionController.removeListener(_checkIfHasChanges);
    _descriptionController.dispose();

    _groupNameFocusNode.dispose();
    _locationFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();
  }

  Future<void> _loadGroupAndUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUserId = await widget.db.getCurrentUserId();
      final Group? fetchedGroup =
          await widget.db.getGroupAsync(widget.group.groupId);

      if (fetchedGroup != null && _currentUserId != null) {
        setState(() {
          _currentGroup = fetchedGroup;
          _groupNameController.text = _currentGroup!.groupName;
          _locationController.text = _currentGroup!.groupLocation ?? '';
          _descriptionController.text = _currentGroup!.groupDescription;
          _hasChanges = false;
          _isUserAdmin = _isCurrentUserGroupAdminCheck();
        });
      } else {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.famkaCyan,
                content: Text(
                  AppLocalizations.of(context)!.groupLoadError,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
            Navigator.of(context).pop();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaCyan,
            content: Text(
              'Fehler beim Laden der Gruppendaten oder Benutzer-ID: $e',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _groupNameController.removeListener(_checkIfHasChanges);
        _locationController.removeListener(_checkIfHasChanges);
        _descriptionController.removeListener(_checkIfHasChanges);

        _groupNameController.addListener(_checkIfHasChanges);
        _locationController.addListener(_checkIfHasChanges);
        _descriptionController.addListener(_checkIfHasChanges);

        _checkIfHasChanges();
      }
    }
  }

  void _checkIfHasChanges() {
    if (_currentGroup == null) return;

    final bool newHasChanges =
        _groupNameController.text != _currentGroup!.groupName ||
            _locationController.text != (_currentGroup!.groupLocation ?? '') ||
            _descriptionController.text != _currentGroup!.groupDescription;

    if (_hasChanges != newHasChanges) {
      setState(() {
        _hasChanges = newHasChanges;
      });
    }
  }

  Future<void> _saveGroupChanges() async {
    if (_currentGroup == null) return;

    final updatedGroup = _currentGroup!.copyWith(
      groupName: _groupNameController.text,
      groupLocation: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      groupDescription: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    await widget.db.updateGroup(updatedGroup);

    setState(() {
      _currentGroup = updatedGroup;
      _hasChanges = false;
    });
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaCyan,
          content: Text(
            l10n.changesSaved,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
  }

  void _onAvatarChanged(String newAvatarUrl) async {
    print(
        'DEBUG: _onAvatarChanged in GroupPage aufgerufen mit newAvatarUrl: $newAvatarUrl');

    if (_currentGroup == null) {
      print('DEBUG: _currentGroup ist null in _onAvatarChanged.');
      return;
    }

    final updatedGroup = _currentGroup!.copyWith(groupAvatarUrl: newAvatarUrl);

    setState(() {
      _currentGroup = updatedGroup;
    });

    try {
      await widget.db.updateGroup(updatedGroup);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaCyan,
            content: Text(
              'Gruppenbild erfolgreich aktualisiert!',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
        setState(() {
          _hasChanges = false;
        });
      }
    } catch (e) {
      print(
          'DEBUG: Fehler beim Speichern des Gruppenbilds in _onAvatarChanged: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text(
              'Fehler beim Speichern des Gruppenbilds: $e',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
    }
  }

  Future<void> _manageGroupMembers() async {
    if (_currentGroup == null) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ManageGroupMembersPage(
          db: widget.db,
          group: _currentGroup!,
          currentUser: widget.currentUser,
          isCurrentUserAdmin: _isUserAdmin,
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
      await _loadGroupAndUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaCyan,
          content: Text(
            'Mitgliederverwaltung abgeschlossen.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
  }

  bool _isCurrentUserGroupCreator() {
    if (_currentGroup == null || _currentUserId == null) {
      return false;
    }
    return _currentGroup!.creatorId == _currentUserId;
  }

  bool _isCurrentUserGroupAdminCheck() {
    if (_currentGroup == null || _currentUserId == null) {
      return false;
    }

    // Der Ersteller der Gruppe ist IMMER Admin
    final bool isCreator = _currentGroup!.creatorId == _currentUserId;

    // Zusätzlich prüfen wir, ob der Benutzer in der userRoles Map als Admin eingetragen ist
    final bool isRoleAdmin =
        _currentGroup!.userRoles[_currentUserId] == UserRole.admin;

    // Ausführliche Debug-Ausgabe
    debugPrint('ADMIN CHECK DETAILS:');
    debugPrint('- Current User ID: $_currentUserId');
    debugPrint('- Group Creator ID: ${_currentGroup!.creatorId}');
    debugPrint('- Is Creator: $isCreator');
    debugPrint(
        '- User Role from Map: ${_currentGroup!.userRoles[_currentUserId]}');
    debugPrint('- Is Role Admin: $isRoleAdmin');
    debugPrint('- Final result: ${isCreator || isRoleAdmin}');

    // Der Benutzer ist Admin, wenn er entweder der Ersteller ist ODER in der userRoles Map als Admin eingetragen ist
    return isCreator || isRoleAdmin;
  }

  void _showGroupIdDialog() {
    if (_currentGroup == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GroupIdDialog(
          groupName: _currentGroup!.groupName,
          groupId: _currentGroup!.groupId,
        );
      },
    );
  }

  // Debug-Tool zum direkten Entfernen von Mitgliedern
  void _showDebugTool() {
    if (_currentGroup == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DebugTool(groupId: _currentGroup!.groupId);
      },
    );
  }

  void _showInviteDialog() {
    if (_currentGroup == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InviteUserDialog(
          onInvite: _inviteUserToGroup,
        );
      },
    );
  }

  void _showAddPassiveMemberDialog() {
    if (_currentGroup == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddPassiveMemberDialog(
          db: widget.db,
          group: _currentGroup!,
          onMemberAdded: () {
            _loadGroupAndUserData();
          },
        );
      },
    );
  }

  Future<void> _inviteUserToGroup(String inviteeProfileId) async {
    if (_currentGroup == null) return;

    if (_currentGroup!.groupMembers
        .any((member) => member.profilId == inviteeProfileId)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaCyan,
            content: Text(
              'Benutzer ist bereits Mitglied dieser Gruppe.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
      return;
    }

    try {
      final AppUser? inviteeUser =
          await widget.db.getUserAsync(inviteeProfileId);

      if (inviteeUser != null) {
        debugPrint('Invited user ID: \\${inviteeUser.profilId}');
        debugPrint('Invited user First Name: \\${inviteeUser.firstName}');
        debugPrint('Invited user Last Name: \\${inviteeUser.lastName}');

        try {
          await widget.db.addUserToGroup(
              inviteeUser, _currentGroup!.groupId, UserRole.member);
        } catch (e) {
          // Suppress 'permission-denied' error if user was actually added
          final alreadyMember = _currentGroup!.groupMembers
              .any((member) => member.profilId == inviteeUser.profilId);
          if (e.toString().contains('permission-denied') && alreadyMember) {
            debugPrint('Suppressed permission-denied error: user was added.');
          } else {
            rethrow;
          }
        }

        await _loadGroupAndUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.famkaCyan,
              content: Text(
                '\\${inviteeUser.firstName} erfolgreich eingeladen!',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.famkaRed,
              content: Text(
                'Benutzer mit dieser ID nicht gefunden.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          );

          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Suppress permission-denied error message if it occurs
      if (e.toString().contains('permission-denied')) {
        debugPrint('Suppressed permission-denied error after invite attempt.');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text(
              'Fehler beim Einladen des Benutzers: $e',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteGroup() async {
    if (_currentGroup == null) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDeleteGroupDialog(
          groupName: _currentGroup!.groupName,
        );
      },
    );

    if (confirm == true) {
      await _deleteGroup();
    }
  }

  Future<void> _deleteGroup() async {
    if (_currentGroup == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.db.deleteGroup(_currentGroup!.groupId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaCyan,
            content: Text(
              'Gruppe "${_currentGroup!.groupName}" erfolgreich gelöscht.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
        _currentGroup = null;
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text(
              'Fehler beim Löschen der Gruppe: $e',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentGroup == null || _currentUserId == null) {
      return const Scaffold(
        backgroundColor: AppColors.famkaWhite,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.famkaCyan,
          ),
        ),
      );
    }

    final bool showDeleteButton = _isCurrentUserGroupCreator();
    final bool isUserAdmin = _isUserAdmin;

    final l10n = AppLocalizations.of(context)!;
    String userRoleText = '';
    if (_currentGroup!.userRoles.containsKey(_currentUserId)) {
      final UserRole userRole = _currentGroup!.userRoles[_currentUserId]!;
      if (userRole == UserRole.admin) {
        userRoleText = l10n.groupPageRoleAdmin;
      } else if (userRole == UserRole.member) {
        userRoleText = l10n.groupPageRoleMember;
      }
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          if (_currentGroup == null) {
            return;
          }
          if (_hasChanges) {
            await _saveGroupChanges();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.famkaWhite,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              GroupHeader(
                groupNameController: _groupNameController,
                groupNameFocusNode: _groupNameFocusNode,
                showDeleteButton: showDeleteButton,
                onDeleteGroup: _confirmDeleteGroup,
                userRoleText: userRoleText,
                db: widget.db,
                groupAvatarUrl: _currentGroup!.groupAvatarUrl,
                onAvatarChanged: _onAvatarChanged,
                isUserAdmin: isUserAdmin,
                currentGroup: _currentGroup!,
                currentUserId: _currentUserId,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GroupDetails(
                          locationController: _locationController,
                          locationFocusNode: _locationFocusNode,
                          descriptionController: _descriptionController,
                          descriptionFocusNode: _descriptionFocusNode,
                        ),
                        const SizedBox(height: 20),
                        GroupMembersSection(
                          onShowGroupIdDialog: _showGroupIdDialog,
                          onShowAddPassiveMemberDialog:
                              _showAddPassiveMemberDialog,
                          onShowInviteDialog: _showInviteDialog,
                          onManageGroupMembers: _manageGroupMembers,
                          db: widget.db,
                          auth: widget.auth,
                          currentUser: widget.currentUser,
                          members: _currentGroup!.groupMembers,
                        ),
                        const SizedBox(height: 8),
                        SaveButton(
                          hasChanges: _hasChanges,
                          onSave: _saveGroupChanges,
                        ),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationThreeCalendar(
          widget.db,
          currentUser: widget.currentUser,
          initialGroup: _currentGroup,
          initialIndex: 0,
          auth: widget.auth,
        ),
      ),
    );
  }
}
