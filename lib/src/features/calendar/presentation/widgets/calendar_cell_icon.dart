import 'package:flutter/material.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/info_bottom_sheet.dart';

class CalendarCellIcon extends StatelessWidget {
  final DateTime date;
  final AppUser user;
  final dynamic db;
  final List<SingleEvent> allEvents;
  final List<AppUser> currentGroupMembers;
  final Widget Function(String?, String, double) buildEventContent;
  final Function()? onEventsRefreshed;
  final Function(String eventId)? onEventDeletedConfirmed;

  const CalendarCellIcon({
    Key? key,
    required this.date,
    required this.user,
    required this.db,
    required this.buildEventContent,
    required this.allEvents,
    required this.currentGroupMembers,
    this.onEventsRefreshed,
    this.onEventDeletedConfirmed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  final userId = user.profilId;
  final eventsForPerson = allEvents.where((event) {
    final sameDay = event.singleEventDate.year == date.year &&
      event.singleEventDate.month == date.month &&
      event.singleEventDate.day == date.day;
    final attending = event.acceptedMemberIds.contains(userId) ||
      event.invitedMemberIds.contains(userId) ||
      event.maybeMemberIds.contains(userId);
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
            return GestureDetector(
              onTap: () async {
                await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return InfoBottomSheet(
                      date: date,
                      userName: user.firstName,
                      eventsForPerson: eventsForPerson,
                      currentGroupMembers: currentGroupMembers,
                      db: db,
                      onEventUpdated: (_) {
                        if (onEventsRefreshed != null) onEventsRefreshed!();
                      },
                      onEventDeleted: (eventId) {
                        if (onEventDeletedConfirmed != null) {
                          onEventDeletedConfirmed!(eventId);
                        }
                        if (onEventsRefreshed != null) onEventsRefreshed!();
                      },
                    );
                  },
                );
              },
              child: SizedBox(
                width: iconSize,
                height: iconSize,
                child: buildEventContent(
                  event.singleEventUrl,
                  event.singleEventName,
                  iconSize,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
