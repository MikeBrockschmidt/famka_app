import 'package:famka_app/src/data/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';

class CalendarCellIcon extends StatelessWidget {
  final DateTime date;
  final AppUser user;
  final DatabaseRepository db;

  const CalendarCellIcon({
    super.key,
    required this.date,
    required this.user,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    final allEvents = db.getAllEvents();
    final userId = user.profilId;

    final eventsForPerson = allEvents.where((event) {
      final sameDay = event.singleEventDate.year == date.year &&
          event.singleEventDate.month == date.month &&
          event.singleEventDate.day == date.day;
      final attending = event.attendingUsers.contains(userId);
      return sameDay && attending;
    }).toList();

    if (eventsForPerson.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const iconWidth = 28.0;
        const spacing = 4.0;
        (constraints.maxWidth / (iconWidth + spacing)).floor().clamp(1, 2);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: eventsForPerson.map((event) {
            return SizedBox(
              width: iconWidth,
              child: Text(
                event.singleEventUrl,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.none,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
