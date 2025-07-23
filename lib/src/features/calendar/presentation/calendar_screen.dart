import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/common/bottom_navigation_three_list.dart';
// import 'package:famka_app/src/common/bottom_navigation_three_list.dart'; // <-- Diesen Import entfernen, wenn nicht benötigt
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/calendar_grid.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/menu_sub_container_two_lines_group_c.dart';
import 'package:famka_app/src/features/calendar/presentation/event_list_page.dart'; // HINZUGEFÜGT

// Hinzufügen einer Extension, wenn firstWhereOrNull noch nicht verfügbar ist (Flutter 2.x)
// Siehe https://stackoverflow.com/questions/59483321/list-firstwhereorufnull-method-in-flutter-dart
extension IterableExtension<E> on Iterable<E> {
  /// The first element satisfying [test], or `null` if there is none.
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
  int _selectedIndex = 0; // Für die BottomNavigation (wenn Sie diese verwenden)

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
      // Wenn die Gruppe oder der Benutzer wechselt, DisplayGroup aktualisieren und Events neu laden
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
      // *** Wichtige Änderung hier: Verwenden Sie getEventsForGroup! ***
      final List<SingleEvent> fetchedEvents =
          await widget.db.getEventsForGroup(_displayGroup.groupId);

      setState(() {
        _allEvents =
            fetchedEvents; // Keine weitere clientseitige Filterung notwendig!
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

  Future<void> _onEventDeletedConfirmed(String eventId) async {
    try {
      // Stellen Sie sicher, dass Sie die korrekte groupId des Events haben
      final SingleEvent? deletedEvent = _allEvents.firstWhereOrNull(
        (event) => event.singleEventId == eventId,
      );

      if (deletedEvent != null) {
        // Die deleteEvent Methode in Ihrer FirestoreRepository benötigt groupId
        await widget.db
            .deleteEvent(deletedEvent.groupId, deletedEvent.singleEventId);
        if (mounted) {
          setState(() {
            _allEvents.removeWhere((e) => e.singleEventId == eventId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Termin erfolgreich gelöscht.')),
          );
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
      // Nach einem Fehler beim Löschen, Events neu laden, um den Zustand abzugleichen
      await _loadEvents();
    }
    // Nach erfolgreichem Löschen, die Liste im Grid neu laden (falls die Liste direkt aktualisiert wird)
    // Wenn _allEvents.removeWhere verwendet wird, ist dies nicht zwingend notwendig, aber sicher.
    // Ein erneutes Laden ist besser, wenn andere Events sich geändert haben könnten.
    await _loadEvents();
  }

  void _handleGroupUpdated(Group updatedGroup) {
    if (mounted) {
      setState(() {
        _displayGroup = updatedGroup;
        _loadEvents(); // Events neu laden, wenn die Gruppe aktualisiert wird
      });
    }
  }

  // Dies ist die Methode, die aufgerufen wird, wenn ein Tab in der Bottom Navigation Bar getippt wird.
  // Sie muss in dem Widget definiert werden, das die Bottom Navigation Bar steuert.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definieren Sie die Widgets, die in den Tabs der BottomNavigation angezeigt werden
    final List<Widget> _widgetOptions = <Widget>[
      // Index 0: CalendarGrid
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
                  allEvents: _allEvents, // <-- Filtered events
                  onEventDeletedConfirmed: _onEventDeletedConfirmed,
                ),
      // Index 1: EventListPage
      EventListPage(
        db: widget.db,
        currentGroup: _displayGroup,
        currentUser: widget.currentUser,
        auth: widget.auth,
      ),
      // Index 2: Optional, z.B. eine andere Ansicht
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
          // MenuSubContainer muss nicht zwingend im CalendarScreen sein, wenn es in EventListPage auch ist.
          // Aber wenn es global für beide Ansichten sein soll, ist es hier richtig.
          MenuSubContainer2LinesGroupC(
            widget.db,
            currentGroup: _displayGroup,
            onGroupUpdated: _handleGroupUpdated,
            currentUser: widget.currentUser,
            auth: widget.auth,
          ),
          const Divider(thickness: 0.4, height: 0.4, color: Colors.grey),
          Expanded(
            child: _widgetOptions.elementAt(
                _selectedIndex), // Zeigt das aktuell ausgewählte Widget
          ),
          // Nutzen Sie BottomNavigationThreeCalendar, wenn das der Name Ihrer Komponente ist
          BottomNavigationThreeList(
            // <--- Achten Sie auf den korrekten Klassennamen
            widget.db,
            initialGroup: _displayGroup,
            currentUser: widget.currentUser,
            initialIndex: _selectedIndex, // Setzen Sie den initialen Index
            auth: widget.auth,
            // onTabSelected: _onItemTapped, // <--- DIESE ZEILE ENTFERNEN!
          ),
        ],
      ),
    );
  }
}
