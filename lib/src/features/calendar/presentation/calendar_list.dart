import 'package:famka_app/src/features/calendar/presentation/widgets/event_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/event_list_item.dart';
import 'package:famka_app/src/theme/color_theme.dart';

class CalendarList extends StatefulWidget {
  final DatabaseRepository db;
  final Group? currentGroup;
  final AppUser? currentUser;
  final List<SingleEvent> allEvents;
  final Function(String eventId)? onEventDeletedConfirmed;

  const CalendarList(
    this.db, {
    super.key,
    this.currentGroup,
    this.currentUser,
    required this.allEvents,
    this.onEventDeletedConfirmed,
  });

  @override
  State<CalendarList> createState() => _CalendarListState();
}

class _CalendarListState extends State<CalendarList> {
  // ...existing code...
  List<MapEntry<DateTime, List<SingleEvent>>> _groupedEvents = [];

  @override
  void initState() {
    super.initState();
    _groupEvents();
  }

  void _groupEvents() {
    final Map<DateTime, List<SingleEvent>> eventsByDate = {};
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    for (var event in widget.allEvents) {
      final date = DateTime(
        event.singleEventDate.year,
        event.singleEventDate.month,
        event.singleEventDate.day,
      );
      // Nur Events ab heute (inklusive heute) anzeigen
      if (!date.isBefore(todayDateOnly)) {
        if (!eventsByDate.containsKey(date)) {
          eventsByDate[date] = [];
        }
        eventsByDate[date]?.add(event);
      }
    }

    _groupedEvents = eventsByDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  @override
  Widget build(BuildContext context) {
    if (_groupedEvents.isEmpty) {
      return const Center(child: Text('Keine Ereignisse zum Anzeigen.'));
    }

    return ListView.builder(
      itemCount: _groupedEvents.length,
      itemBuilder: (context, index) {
        final date = _groupedEvents[index].key;
        final eventsForDay = _groupedEvents[index].value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Row(
                children: [
                  Text(
                    DateFormat('EEEE, d. MMMM yyyy', 'de_DE').format(date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${eventsForDay.length} ${eventsForDay.length == 1 ? 'Event' : 'Events'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: eventsForDay.length,
              itemBuilder: (context, eventIndex) {
                final event = eventsForDay[eventIndex];
                // Hier wird das zentrale EventListItem-Widget verwendet
                return EventListItem(
                  event: event,
                  groupMembers: widget.currentGroup?.groupMembers ?? [],
                  onDeleteEvent: null,
                );
              },
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildEventIcon(SingleEvent event) {
    // Einheitliches Event-Icon (Text) für die Kalenderlistenansicht
    return EventIconWidget(
      eventUrl: event.singleEventUrl,
      eventName: event.singleEventName,
      size: 40,
      db: null,
    );
  }
}
