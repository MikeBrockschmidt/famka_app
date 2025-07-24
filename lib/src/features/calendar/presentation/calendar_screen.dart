import 'package:famka_app/src/common/bottom_navigation_three_list.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/calendar_grid.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/menu_sub_container_two_lines_group_c.dart';
import 'package:famka_app/src/features/calendar/presentation/event_list_page.dart';

extension IterableExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class CalendarScreen extends StatefulWidget {
  final DatabaseRepository db;
  final Group currentGroup;
  final AppUser currentUser;
  final AuthRepository auth;

  const CalendarScreen(
    this.db, {
    super.key,
    required this.currentGroup,
    required this.currentUser,
    required this.auth,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Group _displayGroup;
  List<SingleEvent> _allEvents = [];
  bool _isLoadingEvents = true;
  String? _eventsErrorMessage;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _displayGroup = widget.currentGroup;
    _loadEvents();
  }

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentGroup.groupId != oldWidget.currentGroup.groupId ||
        widget.currentUser.profilId != oldWidget.currentUser.profilId) {
      setState(() {
        _displayGroup = widget.currentGroup;
      });
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoadingEvents = true;
      _eventsErrorMessage = null;
    });
    try {
      final List<SingleEvent> fetchedEvents =
          await widget.db.getEventsForGroup(_displayGroup.groupId);

      setState(() {
        _allEvents = fetchedEvents;
        _allEvents
            .sort((a, b) => a.singleEventDate.compareTo(b.singleEventDate));
      });
      print(
          'CalendarScreen: Events für Gruppe ${_displayGroup.groupId} geladen: ${_allEvents.length} Events');
    } catch (e) {
      if (mounted) {
        setState(() {
          _eventsErrorMessage = 'Fehler beim Laden der Termine: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text('Fehler beim Laden der Termine: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEvents = false;
        });
      }
    }
  }

  // Diese Methode wird aufgerufen, wenn Events in den Unter-Widgets aktualisiert oder gelöscht wurden
  void _onEventsRefreshed() {
    print('CalendarScreen: _onEventsRefreshed aufgerufen, lade Events neu.');
    _loadEvents(); // Löst das Neuladen der Events und ein setState aus
  }

  Future<void> _onEventDeletedConfirmed(String eventId) async {
    try {
      final SingleEvent? deletedEvent = _allEvents.firstWhereOrNull(
        (event) => event.singleEventId == eventId,
      );

      if (deletedEvent != null) {
        await widget.db
            .deleteEvent(deletedEvent.groupId, deletedEvent.singleEventId);
        if (mounted) {
          setState(() {
            _allEvents.removeWhere((e) => e.singleEventId == eventId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Termin erfolgreich gelöscht.')),
          );
          // WICHTIG: Nach dem Löschen die Events in der Hauptliste neu laden
          _loadEvents();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.famkaRed,
              content: Text('Fehler: Zu löschender Termin nicht gefunden.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text('Fehler beim Löschen des Termins: $e'),
          ),
        );
      }
      await _loadEvents(); // Auch bei Fehler neu laden, um den aktuellen Stand zu bekommen
    }
    // _loadEvents(); // Dieser Aufruf ist überflüssig, da er oben schon in if/else ausgeführt wird
  }

  void _handleGroupUpdated(Group updatedGroup) {
    if (mounted) {
      setState(() {
        _displayGroup = updatedGroup;
        _loadEvents(); // Events neu laden, wenn die Gruppe aktualisiert wurde
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      _isLoadingEvents
          ? const Center(child: CircularProgressIndicator())
          : _eventsErrorMessage != null
              ? Center(
                  child: Text(_eventsErrorMessage!,
                      style: TextStyle(color: AppColors.famkaRed)),
                )
              : CalendarGrid(
                  widget.db,
                  currentGroup: _displayGroup,
                  currentUser: widget.currentUser,
                  allEvents: _allEvents,
                  onEventDeletedConfirmed: _onEventDeletedConfirmed,
                  onEventsRefreshed:
                      _onEventsRefreshed, // NEU: Callback übergeben
                ),
      EventListPage(
        db: widget.db,
        currentGroup: _displayGroup,
        currentUser: widget.currentUser,
        auth: widget.auth,
        onEventsRefreshed: _onEventsRefreshed, // NEU: Callback übergeben
      ),
      const Center(
        child: Text(
          'Hier könnte eine weitere Ansicht sein.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 1,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          MenuSubContainer2LinesGroupC(
            widget.db,
            currentGroup: _displayGroup,
            onGroupUpdated: _handleGroupUpdated,
            currentUser: widget.currentUser,
            auth: widget.auth,
          ),
          const Divider(thickness: 0.4, height: 0.4, color: Colors.grey),
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          BottomNavigationThreeList(
            widget.db,
            initialGroup: _displayGroup,
            currentUser: widget.currentUser,
            initialIndex: _selectedIndex,
            auth: widget.auth,
          ),
        ],
      ),
    );
  }
}
