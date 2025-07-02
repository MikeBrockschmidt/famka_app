import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/common/profil_avatar_row.dart';
import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image3.dart';
import 'package:famka_app/src/features/profil_page/presentation/widgets/create_group_dialog.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/group_page/presentation/group_page.dart';

class ProfilPage extends StatefulWidget {
  final DatabaseRepository db;
  final AppUser currentUser;
  final Group? group;

  const ProfilPage({
    super.key,
    required this.db,
    required this.currentUser,
    this.group,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  List<Group> _userGroups = [];
  bool _isLoadingGroups = true;

  @override
  void initState() {
    super.initState();
    _loadUserGroups();
  }

  Future<void> _loadUserGroups() async {
    setState(() {
      _isLoadingGroups = true;
    });

    final allGroups = widget.db.getAllGroups();
    final List<Group> userGroups = [];

    for (var group in allGroups) {
      if (group.groupMembers
          .any((member) => member.profilId == widget.currentUser.profilId)) {
        userGroups.add(group);
      }
    }

    if (mounted) {
      setState(() {
        _userGroups = userGroups;
        _isLoadingGroups = false;
      });
    }
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CreateGroupDialog(
        db: widget.db,
        currentUser: widget.currentUser,
        onGroupCreated: (newGroup) async {
          await _loadUserGroups();

          if (!mounted) return;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.famkaGreen,
                  content: Text(
                    'Gruppe "${newGroup.groupName}" erfolgreich erstellt!',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            }
          });

          final dynamic result = await Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => GroupPage(
                db: widget.db,
                group: newGroup,
                currentUser: widget.currentUser,
              ),
            ),
          );

          if (result == null && mounted) {
            await _loadUserGroups();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.famkaCyan,
                    content: Text(
                      'Die erstellte Gruppe wurde wieder gelöscht.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              }
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeadlineK(screenHead: 'Profil'),
                    const SizedBox(height: 20),
                    Center(
                      child: ProfilImage3(
                        db: widget.db,
                        avatarUrl: widget.currentUser.avatarUrl,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(
                        thickness: 0.3, height: 0.1, color: Colors.black),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${widget.currentUser.firstName} ${widget.currentUser.lastName}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(
                        thickness: 0.3, height: 0.1, color: Colors.black),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.phone,
                                  size: 20, color: Colors.black),
                              const SizedBox(width: 12),
                              Text(
                                widget.currentUser.phoneNumber.isEmpty
                                    ? 'Nicht angegeben'
                                    : widget.currentUser.phoneNumber,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.email,
                                  size: 20, color: Colors.black),
                              const SizedBox(width: 12),
                              Text(
                                widget.currentUser.email.isEmpty
                                    ? 'Nicht angegeben'
                                    : widget.currentUser.email,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 20, color: Colors.black),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.currentUser.miscellaneous.isEmpty
                                      ? 'Keine zusätzlichen Infos'
                                      : widget.currentUser.miscellaneous,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const Divider(
                        thickness: 0.3, height: 1, color: Colors.black),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isLoadingGroups
                            ? const Center(child: CircularProgressIndicator())
                            : _userGroups.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        'Du bist noch keiner Gruppe beigetreten. Füge eine neue Gruppe hinzu!',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: 120,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0, right: 12.0),
                                            child: Column(
                                              children: [
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                  onTap: () {
                                                    _showCreateGroupDialog(
                                                        context);
                                                  },
                                                  child: Container(
                                                    width: 70,
                                                    height: 70,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.grey,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Center(
                                                      child: Icon(Icons.add,
                                                          size: 36,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                SizedBox(
                                                  width: 70,
                                                  child: Text(
                                                    'Gruppe hinzufügen',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall
                                                        ?.copyWith(height: 1.0),
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ..._userGroups.map((group) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12.0),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final dynamic result =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          GroupPage(
                                                        db: widget.db,
                                                        group: group,
                                                        currentUser:
                                                            widget.currentUser,
                                                      ),
                                                    ),
                                                  );

                                                  if (result == null &&
                                                      mounted) {
                                                    await _loadUserGroups();

                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            backgroundColor:
                                                                AppColors
                                                                    .famkaCyan,
                                                            content: Text(
                                                              'Gruppe erfolgreich gelöscht.',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    });
                                                  }
                                                },
                                                child: ProfilAvatarRow(
                                                  widget.db,
                                                  group: group,
                                                  currentUser:
                                                      widget.currentUser,
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                      ],
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
        initialGroup: widget.group,
        initialIndex: 0,
      ),
    );
  }
}
