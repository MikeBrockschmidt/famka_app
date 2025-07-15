import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
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
      _displayGroup = widget.currentGroup;
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoadingEvents = true;
      _eventsErrorMessage = null;
    });
    try {
      final List<SingleEvent> fetchedEvents = await widget.db.getAllEvents();
      setState(() {
        _allEvents = fetchedEvents
            .where((event) => event.groupId == _displayGroup.groupId)
            .toList();
        _allEvents
            .sort((a, b) => a.singleEventDate.compareTo(b.singleEventDate));
      });
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
      final SingleEvent? deletedEvent = _allEvents.firstWhere(
        (event) => event.singleEventId == eventId,
        orElse: () => null!,
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
      await _loadEvents();
    }
    await _loadEvents();
  }

  void _handleGroupUpdated(Group updatedGroup) {
    if (mounted) {
      setState(() {
        _displayGroup = updatedGroup;
        _loadEvents();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: _isLoadingEvents
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
                      ),
          ),
          BottomNavigationThreeList(
            widget.db,
            initialGroup: _displayGroup,
            currentUser: widget.currentUser,
            initialIndex: 1,
            auth: widget.auth,
          ),
        ],
      ),
    );
  }
}
