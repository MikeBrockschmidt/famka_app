import 'package:famka_app/src/common/bottom_navigation_three_list.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/menu_sub_container_two_lines_group_c.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/calendar_grid.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/data/app_user.dart';

class CalendarScreen extends StatefulWidget {
  final DatabaseRepository db;
  final Group? currentGroup;
  final AppUser? currentUser;

  const CalendarScreen(
    this.db, {
    super.key,
    this.currentGroup,
    required this.currentUser,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _isInitialized = false;
  Group? _displayGroup;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await initializeDateFormatting('de_DE', null);

      if (widget.currentUser == null) {
        throw Exception(
            'Kein aktueller Benutzer für den Kalender verfügbar. Bitte melden Sie sich an.');
      }

      Group? groupToDisplay = widget.currentGroup;

      groupToDisplay ??= widget.db.getGroup('g1');

      if (groupToDisplay == null) {
        throw Exception(
            'Keine Standardgruppe "g1" gefunden oder übergebene Gruppe ist ungültig.');
      }

      if (mounted) {
        setState(() {
          _displayGroup = groupToDisplay;
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = true;
          _displayGroup = null;
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Fehler beim Laden des Kalenders: $e',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
    }
  }

  void _handleGroupUpdated(Group updatedGroup) {
    if (mounted) {
      setState(() {
        _displayGroup = updatedGroup;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _displayGroup == null || widget.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                _errorMessage ??
                    'Konnte Kalender nicht laden. Keine Gruppe zum Anzeigen oder kein Benutzer verfügbar.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.blueAccent,
                      content: Text(
                        'Navigationslogik für Gruppenauswahl/-erstellung noch nicht implementiert.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                child: const Text('Gruppen verwalten'),
              ),
            ],
          ),
        ),
      );
    }

    assert(_displayGroup != null);
    assert(widget.currentUser != null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 1,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          MenuSubContainer2LinesGroupC(
            widget.db,
            currentGroup: _displayGroup!,
            onGroupUpdated: _handleGroupUpdated,
            currentUser: widget.currentUser!,
          ),
          Expanded(
            child: CalendarGrid(
              widget.db,
              currentGroup: _displayGroup!,
            ),
          ),
          BottomNavigationThreeList(
            widget.db,
            initialGroup: _displayGroup!,
            currentUser: widget.currentUser!,
            initialIndex: 1,
          ),
        ],
      ),
    );
  }
}
