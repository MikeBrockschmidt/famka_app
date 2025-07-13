import 'package:famka_app/src/common/headline_g.dart';
import 'package:famka_app/src/features/group_page/presentation/manage_group_members_page.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/common/headline_k.dart'; // Ist importiert, aber nicht direkt verwendet. Falls nicht benötigt, kann es entfernt werden.
import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';

import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image3.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:flutter/services.dart'; // WICHTIG: Für Clipboard

// Import für UserRole hinzufügen, da es in der Group-Klasse verwendet wird
import 'package:famka_app/src/features/login/domain/user_role.dart';

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
  late TextEditingController
      _inviteeIdController; // NEU: Controller für die Einladungs-ID

  String? _initialGroupAvatarUrl;
  bool _hasChanges = false;
  bool _isLoading = true;
  String? _currentUserId;

  _GroupPageState() {
    _groupNameController = TextEditingController();
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
    _inviteeIdController = TextEditingController(); // NEU: Initialisierung
  }

  @override
  void initState() {
    super.initState();
    _loadGroupData();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      _currentUserId = await widget.db.getCurrentUserId();
      setState(() {});
    } catch (e) {
      debugPrint('Fehler beim Abrufen der aktuellen Benutzer-ID: $e');
    }
  }

  Future<void> _loadGroupData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Group? fetchedGroup =
          await widget.db.getGroupAsync(widget.group.groupId);

      if (fetchedGroup != null) {
        setState(() {
          _currentGroup = fetchedGroup;
          _groupNameController.text = _currentGroup!.groupName;
          _locationController.text = _currentGroup!.groupLocation ?? '';
          _descriptionController.text = _currentGroup!.groupDescription ?? '';
          _initialGroupAvatarUrl = _currentGroup!.groupAvatarUrl;
          _hasChanges = false;
        });
      } else {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.famkaCyan,
                content: Text(
                  'Fehler: Gruppe konnte nicht geladen werden. Sie existiert möglicherweise nicht mehr.',
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
              'Fehler beim Laden der Gruppendaten: $e',
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

  @override
  void didUpdateWidget(covariant GroupPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.group.groupId != oldWidget.group.groupId) {
      _loadGroupData();
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
    _inviteeIdController.dispose(); // NEU: Dispose des inviteeIdControllers
    super.dispose();
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

    final Group? updatedGroup = await Navigator.push<Group>(
      context,
      MaterialPageRoute(
        builder: (context) => ManageGroupMembersPage(
          db: widget.db,
          group: _currentGroup!,
        ),
      ),
    );

    if (updatedGroup != null) {
      setState(() {
        _currentGroup = updatedGroup;
        _groupNameController.text = _currentGroup!.groupName;
        _locationController.text = _currentGroup!.groupLocation ?? '';
        _descriptionController.text = _currentGroup!.groupDescription ?? '';
        _initialGroupAvatarUrl = _currentGroup!.groupAvatarUrl;
        _checkIfHasChanges();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaCyan,
            content: Text(
              'Mitgliederverwaltung abgebrochen oder Änderungen verworfen.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
    }
  }

  bool _isCurrentUserGroupCreator() {
    if (_currentGroup == null || _currentUserId == null) {
      return false;
    }
    return _currentGroup!.creatorId == _currentUserId;
  }

  // Methode zum Überprüfen, ob der aktuelle Benutzer Admin ist
  bool _isCurrentUserGroupAdmin() {
    if (_currentGroup == null || _currentUserId == null) {
      return false;
    }
    final bool isAdmin =
        _currentGroup!.userRoles[_currentUserId] == UserRole.admin;
    print(
        'Is current user admin for this group: $isAdmin'); // Hinzugefügt für Debugging
    return isAdmin;
  }

  // Methode zum Anzeigen des Dialogs mit der Gruppen-ID im gewünschten Stil
  void _showGroupIdDialog() {
    if (_currentGroup == null) return; // Sicherheitscheck

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentGroup!
                    .groupName, // Zeigt den Gruppennamen im Titelbereich
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.famkaBlack, // Farbe anpassen
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Teilen Sie diese ID, um andere zur Gruppe einzuladen:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16), // Etwas mehr Platz zur ID
              SelectableText(
                _currentGroup!.groupId, // Die eigentliche Gruppen-ID
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      // Größerer, auffälligerer Stil
                      fontWeight: FontWeight.bold,
                      color: AppColors.famkaCyan, // Hervorhebungsfarbe
                    ),
              ),
            ],
          ),
          actions: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: _currentGroup!.groupId));
                      Navigator.of(context).pop(); // Dialog schließen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gruppen-ID kopiert!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const ButtonLinearGradient(buttonText: 'Kopieren'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(), // Dialog schließen
                    child: Text(
                      'Schließen', // Passender Text für Abbrechen/Schließen
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // NEU: Methode zum Anzeigen des Einladungsdialogs
  void _showInviteDialog() {
    if (_currentGroup == null) return;

    _inviteeIdController.clear(); // Sicherstellen, dass das Feld leer ist

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Benutzer zur Gruppe einladen',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.famkaBlack,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Geben Sie die Profil-ID des Benutzers ein, den Sie einladen möchten:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _inviteeIdController,
                decoration: InputDecoration(
                  hintText: 'Profil-ID des Benutzers',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge, // Angepasster Textstil
              ),
            ],
          ),
          actions: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final String inviteeProfileId =
                          _inviteeIdController.text.trim();
                      if (inviteeProfileId.isNotEmpty) {
                        await _inviteUserToGroup(inviteeProfileId);
                        Navigator.of(context).pop(); // Dialog schließen
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.famkaRed,
                            content: Text(
                              'Bitte geben Sie eine Profil-ID ein.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        );
                      }
                    },
                    child: const ButtonLinearGradient(buttonText: 'Einladen'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(), // Dialog schließen
                    child: Text(
                      'Abbrechen',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Methode zum Hinzufügen eines Benutzers zur Gruppe (Logik)
  Future<void> _inviteUserToGroup(String inviteeProfileId) async {
    if (_currentGroup == null) return;

    // Prüfen, ob der Benutzer bereits Mitglied ist
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
      // Zuerst den Benutzer abrufen, um sicherzustellen, dass er existiert und seine Profil-Info zu bekommen
      final AppUser? inviteeUser =
          await widget.db.getUserAsync(inviteeProfileId);

      if (inviteeUser != null) {
        // KORRIGIERT: Reihenfolge der Parameter und Übergabe des AppUser-Objekts
        await widget.db.addUserToGroup(inviteeUser, _currentGroup!.groupId);

        // Aktualisiere die lokale _currentGroup, um die neue Mitgliederliste zu reflektieren
        await _loadGroupData(); // Am einfachsten ist es, die Daten neu zu laden

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
      }
    }
  }

  Future<void> _confirmDeleteGroup() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentGroup!.groupName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.famkaBlack,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Möchtest du diese Gruppe wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: const ButtonLinearGradient(
                      buttonText: 'Löschen',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Abbrechen',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteGroup();
    } else {}
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
        Navigator.of(context).pop(null);
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
    final bool isUserAdmin = _isCurrentUserGroupAdmin();

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
        body: SafeArea(
          child: Column(
            children: [
              // HeadlineG OHNE rightActionWidget - zurück zum ursprünglichen Zustand
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
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _groupNameController,
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
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
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
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                    decoration: const InputDecoration(
                                      hintText: 'Beschreibung eingeben',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mitglieder:',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                // NEU: Eine Row für die Icons auf der rechten Seite der Mitglieder-Überschrift
                                Row(
                                  mainAxisSize: MainAxisSize.min, // Wichtig!
                                  children: [
                                    if (isUserAdmin) // Info-Icon nur für Admins
                                      InkWell(
                                        onTap: _showGroupIdDialog,
                                        child: const SizedBox(
                                          // Hinzugefügt für expliziten Tap-Bereich
                                          width: 24, // Größe des Icons
                                          height: 24, // Größe des Icons
                                          child: Icon(
                                            Icons.info_outline,
                                            color: AppColors.famkaBlack,
                                          ),
                                        ),
                                      ),
                                    if (isUserAdmin) // Abstand zwischen Info- und Einladen-Icon, wenn beide sichtbar sind
                                      const SizedBox(width: 12),
                                    if (isUserAdmin) // Einladen-Icon nur für Admins
                                      InkWell(
                                        onTap: _showInviteDialog,
                                        child: const SizedBox(
                                          // Hinzugefügt für expliziten Tap-Bereich
                                          width: 24, // Größe des Icons
                                          height: 24, // Größe des Icons
                                          child: Icon(
                                            Icons.person_add,
                                            color: AppColors.famkaBlack,
                                          ),
                                        ),
                                      ),
                                    // Optional: Abstand zwischen Einladen- und Bearbeiten-Icon, wenn beide sichtbar sind
                                    const SizedBox(
                                        width:
                                            12), // Immer Abstand zum Bearbeiten-Icon
                                    InkWell(
                                      onTap:
                                          _manageGroupMembers, // Das Bearbeiten-Icon war schon da
                                      child: const SizedBox(
                                        // Hinzugefügt für expliziten Tap-Bereich
                                        width: 24, // Größe des Icons
                                        height: 24, // Größe des Icons
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
                      SizedBox(
                        height: 120,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Row(
                            children: [
                              ..._currentGroup!.groupMembers.map((member) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        borderRadius: BorderRadius.circular(40),
                                        onTap: () async {
                                          final AppUser? updatedUser =
                                              await widget.db.getUserAsync(
                                                  member.profilId);

                                          if (updatedUser != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilPage(
                                                  db: widget.db,
                                                  currentUser: updatedUser,
                                                  auth: widget.auth,
                                                ),
                                              ),
                                            );
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      AppColors.famkaCyan,
                                                  content: Text(
                                                    'Benutzerdaten können nicht geladen werden!',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  ),
                                                  duration: const Duration(
                                                      seconds: 2),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            const SizedBox(
                                              width: 70,
                                              height: 70,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: AppColors.famkaBlack,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 58,
                                              height: 58,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: AppColors.famkaWhite,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 54,
                                              height: 54,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: AssetImage(member
                                                            .avatarUrl ??
                                                        'assets/fotos/default.jpg'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          member.firstName ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(height: 1.0),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 10.0),
                        child: Align(
                          alignment: Alignment.centerRight,
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
