import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/common/bottom_navigation_three_list.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/menu_sub_container_two_lines_group_c.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/event_list_item.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';

class EventListPage extends StatefulWidget {
  final DatabaseRepository db;
  final Group currentGroup;
  final AppUser currentUser;

  const EventListPage({
    super.key,
    required this.db,
    required this.currentGroup,
    required this.currentUser,
  });

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<SingleEvent> _events = [];
  bool _isLoading = true;
  String? _errorMessage;
  late Group _displayGroup;

  @override
  void initState() {
    super.initState();
    _displayGroup = widget.currentGroup;
    _loadEvents();
  }

  void _handleGroupUpdated(Group updatedGroup) {
    if (mounted) {
      setState(() {
        _displayGroup = updatedGroup;
        _loadEvents();
      });
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final allEvents = widget.db.getAllEvents();
      _events = allEvents
          .where((event) => event.groupId == _displayGroup.groupId)
          .toList();
      _events.sort((a, b) => a.singleEventDate.compareTo(b.singleEventDate));
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Ereignisse: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _deleteEvent(SingleEvent event) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.singleEventName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Möchtest du diesen Termin wirklich löschen?',
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

    if (!mounted) {
      return;
    }

    if (confirmDelete == true) {
      await widget.db.deleteEvent(event.groupId, event.singleEventId);

      await _loadEvents();
    } else {}
  }

  String _getDateHeader(DateTime date, DateTime? previousDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final nextWeek = DateTime(now.year, now.month, now.day + 7);

    final eventDate = DateTime(date.year, date.month, date.day);

    if (previousDate != null &&
        DateTime(previousDate.year, previousDate.month, previousDate.day) ==
            eventDate) {
      return '';
    }

    if (eventDate == today) {
      return 'Heute';
    } else if (eventDate == tomorrow) {
      return 'Morgen';
    } else if (eventDate.isBefore(nextWeek)) {
      return DateFormat('EEEE, dd. MMMM', 'de_DE').format(date);
    } else if (eventDate.year == now.year) {
      if (previousDate != null && previousDate.month == date.month) {
        return '';
      }
      return DateFormat('MMMM', 'de_DE').format(date);
    } else {
      if (previousDate != null && previousDate.year == date.year) {
        return '';
      }
      return DateFormat('MMMM yyyy', 'de_DE').format(date);
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
          ),
          const Divider(thickness: 0.4, height: 0.4, color: Colors.grey),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.famkaRed),
                          ),
                        ),
                      )
                    : _events.isEmpty
                        ? Center(
                            child: Text(
                              'Keine Ereignisse für diese Gruppe gefunden.',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _events.length,
                            itemBuilder: (context, index) {
                              final event = _events[index];
                              final DateTime? previousEventDate = index > 0
                                  ? _events[index - 1].singleEventDate
                                  : null;
                              final String headerText = _getDateHeader(
                                  event.singleEventDate, previousEventDate);

                              return StickyHeaderBuilder(
                                builder: (context, stuckAmount) {
                                  if (headerText.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    height: 40.0,
                                    color: AppColors.famkaCyan,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      headerText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppColors.famkaBlack,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  );
                                },
                                content: EventListItem(
                                  event: event,
                                  groupMembers: _displayGroup.groupMembers,
                                  onDeleteEvent: _deleteEvent,
                                ),
                              );
                            },
                          ),
          ),
          BottomNavigationThreeCalendar(
            widget.db,
            initialGroup: _displayGroup,
            currentUser: widget.currentUser,
            initialIndex: 1,
          ),
        ],
      ),
    );
  }
}
