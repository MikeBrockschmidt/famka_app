import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
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
  late final DateTime _startDate;
  late final DateTime _endDate;
  List<MapEntry<DateTime, List<SingleEvent>>> _groupedEvents = [];

  @override
  void initState() {
    super.initState();
    print('CalendarList: initState aufgerufen');
    print(
        'CalendarList: allEvents Count im initState: ${widget.allEvents.length}');
    _startDate = DateTime.now().subtract(const Duration(days: 180));
    _endDate = DateTime.now().add(const Duration(days: 180));
    _groupEvents();
    print(
        'CalendarList: _groupedEvents Count nach Gruppierung: ${_groupedEvents.length}');
  }

  void _groupEvents() {
    print('CalendarList: _groupEvents Methode gestartet');
    final Map<DateTime, List<SingleEvent>> eventsByDate = {};

    for (var event in widget.allEvents) {
      final date = DateTime(
        event.singleEventDate.year,
        event.singleEventDate.month,
        event.singleEventDate.day,
      );

      if (!eventsByDate.containsKey(date)) {
        eventsByDate[date] = [];
      }
      eventsByDate[date]?.add(event);
    }

    _groupedEvents = eventsByDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    print(
        'CalendarList: _groupEvents Methode beendet. Gruppierte Events: ${_groupedEvents.length}');
  }

  @override
  Widget build(BuildContext context) {
    print('CalendarList: build aufgerufen');
    if (_groupedEvents.isEmpty) {
      print('CalendarList: _groupedEvents ist leer, zeige leere Nachricht an.');
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
                return ListTile(
                  leading: _buildEventIcon(event),
                  title: Text(event.singleEventName),
                  subtitle: Text(
                    'Teilnehmer: ${event.acceptedMemberIds.length}',
                  ),
                  onTap: () {},
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
    final String initial = event.singleEventName.isNotEmpty
        ? event.singleEventName[0].toUpperCase()
        : '?';

    if (event.singleEventUrl == null || event.singleEventUrl!.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Text(
          initial,
          style: TextStyle(color: AppColors.famkaBlack),
        ),
      );
    }

    if (event.singleEventUrl!.startsWith('emoji:')) {
      return Text(
        event.singleEventUrl!.substring(6),
        style: const TextStyle(fontSize: 24),
      );
    }

    return CircleAvatar(
      backgroundColor: Colors.grey[200],
      child: Text(
        initial,
        style: TextStyle(color: AppColors.famkaBlack),
      ),
    );
  }
}
