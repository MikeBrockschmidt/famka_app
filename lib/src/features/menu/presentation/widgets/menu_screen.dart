import 'package:famka_app/gen_l10n/app_localizations.dart';
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
import 'package:famka_app/src/features/menu/presentation/widgets/menu_sub_container_one_line_language.dart';

class MenuScreen extends StatefulWidget {
  final DatabaseRepository db;
  final Group? currentGroup;
  final AppUser? currentUser;
  final List<Group>? userGroups;
  final AuthRepository auth;

  const MenuScreen(
    this.db, {
    super.key,
    this.currentGroup,
    required this.currentUser,
    this.userGroups,
    required this.auth,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int? expandedIndex = 0;

  Group? _displayedGroup;
  List<Group> _userGroups = [];

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('MenuScreen: initState called');
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('MenuScreen: didChangeDependencies called');
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
          _displayedGroup = displayGroupCandidate;
          _isLoading = false;
          _hasError = _displayedGroup == null;
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
      if (_displayedGroup == null && mounted) {
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
          if (_displayedGroup != null &&
              _displayedGroup!.groupId == resultGroup.groupId) {
            _displayedGroup = resultGroup;
          }
        });
      } else {
        await _loadInitialData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MenuScreen: build called');
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.famkaCyan),
        ),
      );
    }

    if (_hasError || _displayedGroup == null) {
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

    assert(_displayedGroup != null);
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
                ExpansionTile(
                  key: Key('tile_1_${expandedIndex == 1}'),
                  backgroundColor: AppColors.famkaYellow,
                  initiallyExpanded: expandedIndex == 1,
                  title: _buildTileTitle(
                      context, AppLocalizations.of(context)!.calendarTitle),
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                ],
                              ),
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
                              group: _displayedGroup!,
                              currentUser: widget.currentUser!,
                              auth: widget.auth,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  key: Key('tile_2_${expandedIndex == 2}'),
                  backgroundColor: AppColors.famkaYellow,
                  initiallyExpanded: expandedIndex == 2,
                  title: _buildTileTitle(
                      context, AppLocalizations.of(context)!.groupsTitle),
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Fehler beim Laden: ${snapshot.error}',
                                style:
                                    const TextStyle(color: AppColors.famkaRed),
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else {
                            return MenuSubContainer2LinesGroup(
                              widget.db,
                              currentGroup: _displayedGroup!,
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
                ExpansionTile(
                  key: Key('tile_3_${expandedIndex == 3}'),
                  backgroundColor: AppColors.famkaYellow,
                  initiallyExpanded: expandedIndex == 3,
                  title: _buildTileTitle(
                      context, AppLocalizations.of(context)!.languageTitle),
                  onExpansionChanged: (isExpanded) =>
                      _handleExpansion(3, isExpanded),
                  children: [
                    Container(
                      color: AppColors.famkaWhite,
                      child: Column(
                        children: [
                          FutureBuilder<void>(
                            future: Future.delayed(
                              const Duration(milliseconds: 50),
                              () => Future.value(),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                    ],
                                  ),
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
                                return MenuSubContainer1LinesImpressum(
                                    widget.db);
                              }
                            },
                          ),
                          MenuSubContainer1LinesLanguage(),
                        ],
                      ),
                    ),
                  ],
                ),
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  height: 1.5,
                ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
