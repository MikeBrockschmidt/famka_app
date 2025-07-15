import 'package:flutter/material.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';

class CalendarCellIcon extends StatelessWidget {
  final DateTime date;
  final AppUser user;

  final List<SingleEvent> allEvents;
  final Widget Function(String?, String, double) buildEventContent;

  const CalendarCellIcon({
    super.key,
    required this.date,
    required this.user,
    required this.allEvents,
    required this.buildEventContent,
  });

  @override
  Widget build(BuildContext context) {
    final userId = user.profilId;

    final eventsForPerson = allEvents.where((event) {
      final sameDay = event.singleEventDate.year == date.year &&
          event.singleEventDate.month == date.month &&
          event.singleEventDate.day == date.day;

      final attending = event.acceptedMemberIds.contains(userId) ||
          event.invitedMemberIds.contains(userId) ||
          event.maybeMemberIds.contains(userId) ||
          event.creatorId == userId;

      return sameDay && attending;
    }).toList();

    if (eventsForPerson.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const iconSize = 40.0;
        const spacing = 0.5;

        final maxIconsPerRow =
            (constraints.maxWidth / (iconSize + spacing)).floor();

        final displayEvents = eventsForPerson.take(maxIconsPerRow * 2).toList();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: displayEvents.map((event) {
            return SizedBox(
              width: iconSize,
              height: iconSize,
              child: buildEventContent(
                event.singleEventUrl,
                event.singleEventName,
                iconSize,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
