import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/group_page/presentation/group_page.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/data/app_user.dart';

class _SingleGroupItem extends StatelessWidget {
  final DatabaseRepository db;
  final Group group;
  final ValueChanged<Group> onGroupSelected;
  final AppUser currentUser;

  const _SingleGroupItem(
    this.db, {
    required this.group,
    required this.onGroupSelected,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          thickness: 1,
          height: 1,
          color: Colors.grey,
        ),
        InkWell(
          onTap: () async {
            final Group? updatedGroup = await Navigator.push<Group>(
              context,
              MaterialPageRoute(
                builder: (context) => GroupPage(
                  db: db,
                  group: group,
                  currentUser: currentUser,
                ),
              ),
            );
            if (updatedGroup != null) {
              onGroupSelected(updatedGroup);
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              top: 12.0,
              left: 20.0,
              bottom: 14.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(group.groupAvatarUrl),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.groupName,
                        style:
                            Theme.of(context).textTheme.labelMedium!.copyWith(
                                  height: 0.9,
                                ),
                      ),
                      Text(
                        group.groupLocation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.0,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final Group? updatedGroup = await Navigator.push<Group>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupPage(
                          db: db,
                          group: group,
                          currentUser: currentUser,
                        ),
                      ),
                    );
                    if (updatedGroup != null) {
                      onGroupSelected(updatedGroup);
                    }
                  },
                  iconSize: 16,
                  color: Colors.black,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MenuSubContainer2LinesGroup extends StatefulWidget {
  final DatabaseRepository db;
  final Group currentGroup;
  final ValueChanged<Group> onGroupUpdated;
  final AppUser currentUser;
  const MenuSubContainer2LinesGroup(
    this.db, {
    super.key,
    required this.currentGroup,
    required this.onGroupUpdated,
    required this.currentUser,
  });

  @override
  State<MenuSubContainer2LinesGroup> createState() =>
      _MenuSubContainer2LinesGroupState();
}

class _MenuSubContainer2LinesGroupState
    extends State<MenuSubContainer2LinesGroup> {
  List<Group> _userGroups = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserGroups();
  }

  @override
  void didUpdateWidget(covariant MenuSubContainer2LinesGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentGroup != oldWidget.currentGroup) {
      _loadUserGroups();
    }
  }

  Future<void> _loadUserGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final String userId = await widget.db.getCurrentUserId();
      final List<Group> groups = await widget.db.getGroupsForUser(userId);

      if (mounted) {
        setState(() {
          _userGroups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Laden der Gruppen: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _handleGroupSelected(Group selectedGroup) {
    widget.onGroupUpdated(selectedGroup);
    _loadUserGroups();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(_errorMessage!),
        ),
      );
    }

    if (_userGroups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'Sie sind noch keiner Gruppe beigetreten.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _userGroups.length,
      itemBuilder: (context, index) {
        final group = _userGroups[index];
        return _SingleGroupItem(
          widget.db,
          group: group,
          onGroupSelected: _handleGroupSelected,
          currentUser: widget.currentUser,
        );
      },
    );
  }
}
