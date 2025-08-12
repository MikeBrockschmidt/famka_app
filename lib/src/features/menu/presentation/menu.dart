import 'package:famka_app/src/common/bottom_navigation_three.dart';
import 'package:famka_app/src/common/color_row1.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/menu/presentation/widgets/menu_sub_container_one_line_impessum.dart';
import 'package:famka_app/src/features/menu/presentation/widgets/menu_sub_container_two_lines_calendar.dart';
import 'package:famka_app/src/features/menu/presentation/widgets/menu_sub_container_two_lines_group.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';

class Menu extends StatefulWidget {
  final DatabaseRepository db;
  final Group? currentGroup;
  final AppUser? currentUser;
  final List<Group>? userGroups;
  final AuthRepository auth;

  const Menu(
    this.db, {
    super.key,
    this.currentGroup,
    required this.currentUser,
    this.userGroups,
    required this.auth,
  });

  @override
  State<Menu> createState() => _CustomScreenState();
}

class _CustomScreenState extends State<Menu> {
  int? expandedIndex = 0;

  Group? _displayGroup;
  List<Group> _userGroups = [];

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      if (widget.currentUser == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage =
                'Fehler: Kein aktueller Benutzer verfügbar. Bitte melden Sie sich an.';
          });
        }
        return;
      }

      _userGroups =
          await widget.db.getGroupsForUser(widget.currentUser!.profilId);

      Group? displayGroupCandidate = widget.currentGroup;

      if (displayGroupCandidate == null ||
          !_userGroups
              .any((g) => g.groupId == displayGroupCandidate!.groupId)) {
        displayGroupCandidate =
            _userGroups.isNotEmpty ? _userGroups.first : null;
      }

      if (mounted) {
        setState(() {
          _displayGroup = displayGroupCandidate;
          _isLoading = false;
          _hasError = _displayGroup == null;
          if (_hasError) {
            _errorMessage =
                'Konnte keine Gruppen laden oder keine aktive Gruppe zum Anzeigen.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Fehler beim Laden der Gruppen: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Fehler beim Laden der Gruppen: $e',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
    }
  }

  void _handleExpansion(int index, bool isExpanded) {
    setState(() {
      if (isExpanded) {
        expandedIndex = index;
      } else {
        if (expandedIndex == index) {
          expandedIndex = null;
        }
      }
    });
  }

  Future<void> _handleGroupUpdated(Group? resultGroup) async {
    if (resultGroup == null) {
      await _loadInitialData();
      if (_displayGroup == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaYellow,
            content: Text(
              'Alle Gruppen wurden gelöscht oder konnten nicht geladen werden.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
    } else {
      final int index =
          _userGroups.indexWhere((g) => g.groupId == resultGroup.groupId);
      if (index != -1) {
        setState(() {
          _userGroups[index] = resultGroup;
          if (_displayGroup != null &&
              _displayGroup!.groupId == resultGroup.groupId) {
            _displayGroup = resultGroup;
          }
        });
      } else {
        await _loadInitialData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.famkaCyan),
        ),
      );
    }

    if (_hasError || _displayGroup == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                _errorMessage ?? 'Ein unbekannter Fehler ist aufgetreten.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              if (widget.currentUser != null && _userGroups.isEmpty)
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.famkaCyan,
                        content: Text(
                          'Funktion zum Erstellen einer Gruppe noch nicht implementiert.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                  child: const Text('Neue Gruppe erstellen'),
                ),
            ],
          ),
        ),
      );
    }

    assert(_displayGroup != null);
    assert(widget.currentUser != null);

    return Scaffold(
      backgroundColor: AppColors.famkaWhite,
      appBar: AppBar(
        toolbarHeight: 1,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const HeadlineK(screenHead: 'famka'),
          Expanded(
            child: ListView(
              children: [
                Column(
                  children: [
                    ExpansionTile(
                      key: Key('tile_1_${expandedIndex == 1}'),
                      backgroundColor: AppColors.famkaYellow,
                      initiallyExpanded: expandedIndex == 1,
                      title: _buildTileTitle(context, 'Kalender'),
                      onExpansionChanged: (isExpanded) =>
                          _handleExpansion(1, isExpanded),
                      children: [
                        Container(
                          color: AppColors.famkaWhite,
                          child: FutureBuilder<void>(
                            future: Future.delayed(
                              const Duration(milliseconds: 50),
                              () => Future.value(),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Fehler beim Laden: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              } else {
                                return MenuSubContainer2LinesCalendar(
                                  widget.db,
                                  group: _displayGroup!,
                                  currentUser: widget.currentUser!,
                                  auth: widget.auth,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (expandedIndex != 1)
                      const Divider(
                          thickness: 1, height: 1, color: Colors.grey),
                  ],
                ),
                Column(
                  children: [
                    ExpansionTile(
                      key: Key('tile_2_${expandedIndex == 2}'),
                      backgroundColor: AppColors.famkaYellow,
                      initiallyExpanded: expandedIndex == 2,
                      title: _buildTileTitle(context, 'Gruppen'),
                      onExpansionChanged: (isExpanded) =>
                          _handleExpansion(2, isExpanded),
                      children: [
                        Container(
                          color: AppColors.famkaWhite,
                          child: FutureBuilder<void>(
                            future: Future.delayed(
                              const Duration(milliseconds: 50),
                              () => Future.value(),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Fehler beim Laden: ${snapshot.error}',
                                    style: const TextStyle(
                                        color: AppColors.famkaRed),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              } else {
                                return MenuSubContainer2LinesGroup(
                                  widget.db,
                                  currentGroup: _displayGroup!,
                                  onGroupUpdated: _handleGroupUpdated,
                                  currentUser: widget.currentUser!,
                                  auth: widget.auth,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (expandedIndex != 2)
                      const Divider(
                          thickness: 1, height: 1, color: Colors.grey),
                  ],
                ),
                // ExpansionTile 'Einladen'
                /*
                Column(
                  children: [
                    ExpansionTile(
                      key: Key('tile_3_${expandedIndex == 3}'),
                      backgroundColor: AppColors.famkaYellow,
                      initiallyExpanded: expandedIndex == 3,
                      title: _buildTileTitle(context, 'Einladen'),
                      onExpansionChanged: (isExpanded) =>
                          _handleExpansion(3, isExpanded),
                      children: [
                        Container(
                          color: AppColors.famkaWhite,
                          child: FutureBuilder<void>(
                            future: Future.delayed(
                              const Duration(milliseconds: 50),
                              () => Future.value(),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Fehler beim Laden: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              } else {
                                return MenuSubContainer1LinesInvitation(
                                    widget.db);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (expandedIndex != 3)
                      const Divider(
                          thickness: 1, height: 1, color: Colors.grey),
                  ],
                ),
                */
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorRow1(),
        ],
      ),
    );
  }

  Widget _buildTileTitle(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const SizedBox(width: 5),
          Text(
            title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  height: 1.5,
                ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
