import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';

class EventListItem extends StatelessWidget {
  final SingleEvent event;
  final List<AppUser> groupMembers;
  final ValueChanged<SingleEvent>? onDeleteEvent;

  const EventListItem({
    super.key,
    required this.event,
    required this.groupMembers,
    this.onDeleteEvent,
  });

  Widget _buildEventLeadingIcon(String? eventUrl, String eventName,
      {double size = 32.0}) {
    if (eventUrl == null || eventUrl.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey.shade200,
        child: Text(
          eventName.isNotEmpty ? eventName[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.5,
            color: AppColors.famkaBlack,
          ),
        ),
      );
    }

    if (eventUrl.startsWith('emoji:')) {
      final emoji = eventUrl.substring(6);
      return Text(
        emoji,
        style: TextStyle(
          fontSize: size * 0.9,
          fontFamilyFallback: const [
            'Apple Color Emoji',
            'Noto Color Emoji',
            'Segoe UI Emoji',
          ],
        ),
      );
    } else if (eventUrl.startsWith('icon:')) {
      final iconCodePoint = int.tryParse(eventUrl.substring(5));
      if (iconCodePoint != null) {
        return Icon(
          IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
          size: size,
          color: Colors.black,
        );
      }
    } else if (eventUrl.startsWith('image:')) {
      final imageUrl = eventUrl.substring(6);
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.broken_image,
            size: size,
            color: AppColors.famkaRed,
          );
        },
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.red.shade100,
      child: Text(
        '!',
        style: TextStyle(fontSize: size * 0.5, color: AppColors.famkaRed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
          bottomLeft: Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
          bottomLeft: Radius.zero,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.famkaYellow,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        bottomLeft: Radius.zero,
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        final List<String> names =
                            event.attendingUsers.map((id) {
                          final AppUser user = groupMembers.firstWhere(
                            (u) => u.profilId == id,
                            orElse: () => AppUser(
                              profilId: id,
                              firstName: id,
                              lastName: '',
                              birthDate: DateTime.now(),
                              email: '',
                              phoneNumber: '',
                              avatarUrl: '',
                              miscellaneous: '',
                              password: '',
                            ),
                          );
                          return user.firstName;
                        }).toList();

                        final bool isAllDayEvent =
                            event.singleEventDate.hour == 0 &&
                                event.singleEventDate.minute == 0 &&
                                (event.singleEventEndTime == null ||
                                    (event.singleEventEndTime!.hour == 0 &&
                                        event.singleEventEndTime!.minute == 0 &&
                                        event.singleEventEndTime!.day ==
                                            event.singleEventDate.day));

                        String dateDisplay = DateFormat('dd.MM.yyyy')
                            .format(event.singleEventDate);
                        if (!isAllDayEvent) {
                          dateDisplay +=
                              ' ${DateFormat('HH:mm').format(event.singleEventDate)}';
                        }

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              titlePadding: const EdgeInsets.fromLTRB(
                                  24.0, 24.0, 16.0, 0.0),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: _buildEventLeadingIcon(
                                      event.singleEventUrl,
                                      event.singleEventName,
                                      size: 50.0,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      event.singleEventName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: AppColors.famkaBlack),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      onDeleteEvent?.call(event);
                                    },
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text('Ort: ${event.singleEventLocation}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 2),
                                  Text('Datum: $dateDisplay',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  if (event.singleEventEndTime != null &&
                                      !isAllDayEvent)
                                    Text(
                                        'Endzeit: ${DateFormat('HH:mm').format(event.singleEventEndTime!)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                  if (event.repeatOption != null &&
                                      event.repeatOption!.isNotEmpty)
                                    Text('Wiederholung: ${event.repeatOption}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                  if (event.reminderOption != null &&
                                      event.reminderOption!.isNotEmpty)
                                    Text('Erinnerung: ${event.reminderOption}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                  const SizedBox(height: 4),
                                  Text('Teilnehmer: ${names.join(', ')}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Beschreibung: ${event.description ?? "Keine Beschreibung"}',
                                      style: (Theme.of(context)
                                          .textTheme
                                          .titleMedium)),
                                ],
                              ),
                              actions: [
                                Center(
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const ButtonLinearGradient(
                                      buttonText: 'Schließen',
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                        bottomLeft: Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0, top: 4.0),
                                  child: _buildEventLeadingIcon(
                                      event.singleEventUrl,
                                      event.singleEventName,
                                      size: 28),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.singleEventName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('dd.MM.yyyy', 'de_DE')
                                                .format(event.singleEventDate),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: Colors.grey[800]),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.access_time,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('HH:mm', 'de_DE')
                                                .format(event.singleEventDate),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: AppColors.famkaRed,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              event.singleEventLocation,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 2,
              decoration: const BoxDecoration(
                color: AppColors.famkaBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
