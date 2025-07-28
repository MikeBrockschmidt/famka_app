// lib/src/features/group_page/presentation/group_page.dart
import 'package:famka_app/src/common/headline_g.dart';
import 'package:famka_app/src/features/group_page/presentation/manage_group_members_page.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image3.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:flutter/services.dart';

import 'package:famka_app/src/features/login/domain/user_role.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/group_id_dialog.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/invite_user_dialog.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/confirm_delete_group_dialog.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/group_members_list.dart';
import 'package:famka_app/src/features/group_page/presentation/widgets/add_passive_member_dialog.dart';

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

  // Füge FocusNodes für jedes TextFormField hinzu
  late FocusNode _groupNameFocusNode;
  late FocusNode _locationFocusNode;
  late FocusNode _descriptionFocusNode;

  String? _initialGroupAvatarUrl;
  bool _hasChanges = false;
  bool _isLoading = true;
  String? _currentUserId;
  bool _isUserAdmin = false;

  _GroupPageState() {
    _groupNameController = TextEditingController();
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
    // Initialisiere FocusNodes im Konstruktor
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

    // Entsorge die FocusNodes
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
          _descriptionController.text = _currentGroup!.groupDescription ?? '';
          _initialGroupAvatarUrl = _currentGroup!.groupAvatarUrl;
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
                  'Fehler: Gruppe konnte nicht geladen werden oder Benutzer-ID fehlt.',
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
            _descriptionController.text !=
                (_currentGroup!.groupDescription ?? '') ||
            _currentGroup!.groupAvatarUrl != _initialGroupAvatarUrl;

    if (_hasChanges != newHasChanges) {
      setState(() {
        _hasChanges = newHasChanges;
      });
    }
  }

  Future<void> _saveGroupChanges() async {
    if (_currentGroup == null) return;

    final String currentAvatarUrl = _currentGroup!.groupAvatarUrl;

    final updatedGroup = _currentGroup!.copyWith(
      groupName: _groupNameController.text,
      groupLocation: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      groupDescription: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      groupAvatarUrl: currentAvatarUrl,
    );

    await widget.db.updateGroup(updatedGroup);

    setState(() {
      _currentGroup = updatedGroup;
      _initialGroupAvatarUrl = _currentGroup!.groupAvatarUrl;
      _hasChanges = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaCyan,
          content: Text(
            'Änderungen gespeichert!',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
  }

  void _onAvatarChanged(String newAvatarUrl) {
    if (_currentGroup == null) return;
    setState(() {
      _currentGroup = _currentGroup!.copyWith(groupAvatarUrl: newAvatarUrl);
      _checkIfHasChanges();
    });
  }

  Future<void> _manageGroupMembers() async {
    if (_currentGroup == null) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ManageGroupMembersPage(
          db: widget.db,
          group: _currentGroup!,
          currentUser:
              widget.currentUser, // HINZUGEFÜGT für Berechtigungsprüfung
          isCurrentUserAdmin:
              _isUserAdmin, // HINZUGEFÜGT für Berechtigungsprüfung
        ),
      ),
    );

    if (mounted) {
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
    final bool isAdmin =
        _currentGroup!.userRoles[_currentUserId] == UserRole.admin;
    debugPrint('Is current user admin for this group (inside check): $isAdmin');
    return isAdmin;
  }

  bool _isCurrentUserGroupAdmin() {
    return _isUserAdmin;
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
        debugPrint('Invited user ID: ${inviteeUser.profilId}');
        debugPrint('Invited user First Name: ${inviteeUser.firstName}');
        debugPrint('Invited user Last Name: ${inviteeUser.lastName}');

        await widget.db.addUserToGroup(
            inviteeUser, _currentGroup!.groupId, UserRole.member);

        await _loadGroupAndUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.famkaCyan,
              content: Text(
                '${inviteeUser.firstName ?? 'Benutzer'} erfolgreich eingeladen!',
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
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text(
              'Fehler beim Einladen des Benutzers: $e',
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
    final bool isUserAdmin =
        _isUserAdmin; // Diese Variable wird nun in der Navigation verwendet

    // Bestimme die Rolle des aktuellen Benutzers
    String userRoleText = '';
    if (_currentGroup!.userRoles.containsKey(_currentUserId)) {
      final UserRole userRole = _currentGroup!.userRoles[_currentUserId]!;
      if (userRole == UserRole.admin) {
        userRoleText = 'Rolle: Admin';
      } else if (userRole == UserRole.member) {
        userRoleText = 'Rolle: Mitglied';
      }
      // Der "passive"-Fall wird entfernt, da er nicht im Enum existiert.
      // Alle Nicht-Admins werden somit als "Mitglied" angezeigt.
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
        resizeToAvoidBottomInset: true, // Stelle sicher, dass dies auf true ist
        body: SafeArea(
          child: Column(
            children: [
              const HeadlineG(
                screenHead: 'Gruppe',
              ),
              const SizedBox(height: 20),
              Center(
                child: ProfilImage3(
                  db: widget.db,
                  avatarUrl: _currentGroup!.groupAvatarUrl,
                  onAvatarChanged: _onAvatarChanged,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 0.3,
                height: 0.1,
                color: AppColors.famkaBlack,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    // ÄNDERUNG: Column statt Row, um Text untereinander zu legen
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Links ausgerichtet
                    children: [
                      Row(
                        // Ursprüngliche Row für Gruppennamen und Löschen-Button
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _groupNameController,
                              focusNode:
                                  _groupNameFocusNode, // FocusNode zugewiesen
                              textInputAction:
                                  TextInputAction.done, // Hinzugefügt
                              onSubmitted: (value) {
                                // onSubmitted für TextField ist korrekt
                                _groupNameFocusNode
                                    .unfocus(); // Tastatur schließen
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
                              onPressed: _confirmDeleteGroup,
                              iconSize: 24,
                            ),
                        ],
                      ),
                      // NEUE ANZEIGE DER ROLLE HIER
                      if (userRoleText.isNotEmpty)
                        Text(
                          userRoleText,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.famkaGrey,
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 0.3,
                height: 0.1,
                color: AppColors.famkaBlack,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  // GestureDetector hinzugefügt, um die Tastatur bei Tippen außerhalb zu schließen
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 20, color: AppColors.famkaBlack),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _locationController,
                                      focusNode:
                                          _locationFocusNode, // FocusNode zugewiesen
                                      textInputAction:
                                          TextInputAction.done, // Hinzugefügt
                                      onSubmitted: (value) {
                                        // onSubmitted für TextField ist korrekt
                                        _locationFocusNode
                                            .unfocus(); // Tastatur schließen
                                      },
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                      decoration: const InputDecoration(
                                        hintText: 'Ort eingeben',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.description,
                                    size: 20,
                                    color: AppColors.famkaBlack,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _descriptionController,
                                      focusNode:
                                          _descriptionFocusNode, // FocusNode zugewiesen
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      textInputAction:
                                          TextInputAction.done, // Hinzugefügt
                                      onSubmitted: (value) {
                                        // onSubmitted für TextField ist korrekt
                                        _descriptionFocusNode
                                            .unfocus(); // Tastatur schließen
                                      },
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                      decoration: const InputDecoration(
                                        hintText: 'Beschreibung eingeben',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mitglieder:',
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Icons sind jetzt IMMER sichtbar
                                      InkWell(
                                        onTap: _showGroupIdDialog,
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
                                        onTap: _showAddPassiveMemberDialog,
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
                                        onTap: _showInviteDialog,
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
                                        onTap: _manageGroupMembers,
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
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        GroupMembersList(
                          db: widget.db,
                          auth: widget.auth,
                          currentUser: widget.currentUser,
                          members: _currentGroup!.groupMembers,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 10.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: _hasChanges ? 1.0 : 0.5,
                              child: InkWell(
                                onTap: _hasChanges ? _saveGroupChanges : null,
                                child: const SizedBox(
                                  width: 150,
                                  height: 50,
                                  child: ButtonLinearGradient(
                                    buttonText: 'Speichern',
                                  ),
                                ),
                              ),
                            ),
                          ),
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
