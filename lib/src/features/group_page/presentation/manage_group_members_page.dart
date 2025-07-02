import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/theme/color_theme.dart';

class ManageGroupMembersPage extends StatefulWidget {
  final DatabaseRepository db;
  final Group group;

  const ManageGroupMembersPage({
    super.key,
    required this.db,
    required this.group,
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
            .where((user) => !_currentGroupMembersEditable
                .any((member) => member.profilId == user.profilId))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Fehler beim Laden der Benutzer: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaCyan,
          content: Text('Fehler beim Laden der Benutzer: $e'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleNewUserSelection(AppUser user) {
    setState(() {
      if (_selectedNewUsers
          .any((selected) => selected.profilId == user.profilId)) {
        _selectedNewUsers
            .removeWhere((selected) => selected.profilId == user.profilId);
      } else {
        _selectedNewUsers.add(user);
      }
      _hasChanges = true;
    });
  }

  void _removeMember(AppUser member) {
    setState(() {
      _currentGroupMembersEditable
          .removeWhere((m) => m.profilId == member.profilId);
      if (!_allAvailableUsers.any((user) => user.profilId == member.profilId) &&
          !_selectedNewUsers.any((user) => user.profilId == member.profilId)) {
        _allAvailableUsers.add(member);
      }
      _hasChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final List<AppUser> updatedMemberList =
          List<AppUser>.from(_currentGroupMembersEditable)
            ..addAll(_selectedNewUsers);

      final updatedGroup = widget.group.copyWith(
        groupMembers: updatedMemberList,
      );

      await widget.db.updateGroup(updatedGroup);

      if (!mounted) return;
      setState(() {
        _hasChanges = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaCyan,
          content: Text(
            'Änderungen gespeichert!',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );

      Navigator.pop(context, updatedGroup);
    } catch (e) {
      debugPrint('Fehler beim Speichern der Mitglieder: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaCyan,
          content: Text('Fehler beim Speichern: $e'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop && _hasChanges) {
          final bool? shouldSave = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Ungespeicherte Änderungen'),
              content: const Text(
                  'Möchten Sie die Änderungen speichern, bevor Sie zurückgehen?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Verwerfen'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Speichern'),
                ),
              ],
            ),
          );

          if (!mounted) return;

          if (shouldSave == true) {
            await _saveChanges();
          } else {
            if (mounted) {
              Navigator.pop(context, null);
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.famkaWhite,
        appBar: AppBar(
          title: Text(
            'Mitglieder verwalten',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          backgroundColor: AppColors.famkaYellow,
          foregroundColor: AppColors.famkaBlack,
          elevation: 0.5,
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Aktuelle Mitglieder',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            Expanded(
              flex: 3,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _currentGroupMembersEditable.isEmpty
                      ? const Center(
                          child:
                              Text('Diese Gruppe hat noch keine Mitglieder.'))
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _currentGroupMembersEditable.length,
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final AppUser item = _currentGroupMembersEditable
                                  .removeAt(oldIndex);
                              _currentGroupMembersEditable.insert(
                                  newIndex, item);
                              _hasChanges = true;
                            });
                          },
                          itemBuilder: (BuildContext context, int index) {
                            final member = _currentGroupMembersEditable[index];
                            return Card(
                              key: ValueKey(member.profilId),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              color: AppColors.famkaWhite,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(member.avatarUrl),
                                  backgroundColor: AppColors.famkaGrey,
                                  radius: 24,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.famkaCyan,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${member.firstName} ${member.lastName}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                subtitle: Text(
                                  member.email.isNotEmpty
                                      ? member.email
                                      : 'Keine E-Mail',
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
            const Divider(height: 30, thickness: 1),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Weitere Mitglieder hinzufügen',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            Expanded(
              flex: 2,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _allAvailableUsers.isEmpty
                      ? const Center(
                          child: Text(
                              'Keine weiteren Benutzer zum Hinzufügen gefunden.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          itemCount: _allAvailableUsers.length,
                          itemBuilder: (context, index) {
                            final user = _allAvailableUsers[index];
                            final isSelected = _selectedNewUsers.any(
                                (selected) =>
                                    selected.profilId == user.profilId);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(user.avatarUrl),
                                backgroundColor: AppColors.famkaGrey,
                                radius: 24,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.famkaCyan,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                '${user.firstName} ${user.lastName}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              subtitle: Text(
                                user.email.isNotEmpty
                                    ? user.email
                                    : 'Keine E-Mail',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  _toggleNewUserSelection(user);
                                },
                                activeColor: AppColors.famkaBlue,
                              ),
                              onTap: () {
                                _toggleNewUserSelection(user);
                              },
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
                        buttonText: _isLoading ? 'Speichern...' : 'Speichern',
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
