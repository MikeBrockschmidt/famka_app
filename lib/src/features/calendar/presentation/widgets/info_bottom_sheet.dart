import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:famka_app/src/data/mock_database_repository.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/data/database_repository.dart';

class InfoBottomSheet extends StatefulWidget {
  const InfoBottomSheet({
    super.key,
    required this.date,
    required this.userName,
    required this.eventsForPerson,
    required this.currentGroupMembers,
    this.onEventDeleted,
  });

  final DateTime date;
  final String userName;
  final List<SingleEvent> eventsForPerson;
  final List<AppUser> currentGroupMembers;
  final Function(String eventId)? onEventDeleted;

  @override
  State<InfoBottomSheet> createState() => _InfoBottomSheetState();
}

class _InfoBottomSheetState extends State<InfoBottomSheet> {
  final DatabaseRepository _db = MockDatabaseRepository();

  @override
  void initState() {
    super.initState();
  }

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
      await _db.deleteEvent(event.groupId, event.singleEventId);
      widget.onEventDeleted?.call(event.singleEventId);

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details für ${DateFormat('dd.MM.yyyy').format(widget.date)} - ${widget.userName}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          if (widget.eventsForPerson.isEmpty)
            Text(
              'Keine Events für diesen Tag.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.eventsForPerson.map((event) {
                  final List<String> names = event.attendingUsers.map((id) {
                    final AppUser user = widget.currentGroupMembers.firstWhere(
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

                  final bool isAllDayEvent = event.singleEventDate.hour == 0 &&
                      event.singleEventDate.minute == 0 &&
                      (event.singleEventEndTime == null ||
                          (event.singleEventEndTime!.hour == 0 &&
                              event.singleEventEndTime!.minute == 0 &&
                              event.singleEventEndTime!.day ==
                                  event.singleEventDate.day));

                  String dateDisplay =
                      DateFormat('dd.MM.yyyy').format(event.singleEventDate);
                  if (!isAllDayEvent) {
                    dateDisplay +=
                        ' ${DateFormat('HH:mm').format(event.singleEventDate)}';
                  }

                  return ListTile(
                    leading: _buildEventLeadingIcon(
                        event.singleEventUrl, event.singleEventName),
                    title: Text(
                      event.singleEventName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(
                      'Teilnehmer: ${names.join(', ')}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            titlePadding: const EdgeInsets.fromLTRB(
                                24.0, 24.0, 16.0, 0.0),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: AppColors.famkaBlack),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _deleteEvent(event);
                                  },
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Ort: ${event.singleEventLocation}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 4),
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
                                  Text(
                                      'Wiederholung: ${event.repeatOption}${event.numberOfRepeats != null && event.numberOfRepeats! > 1 ? ' (${event.numberOfRepeats}x)' : ''}',
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
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const ButtonLinearGradient(
                buttonText: 'Schließen',
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
        ],
      ),
    );
  }
}
