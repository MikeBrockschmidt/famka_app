import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'dart:io';

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
    debugPrint(
        'Debug: _buildEventLeadingIcon aufgerufen mit eventUrl: $eventUrl, eventName: $eventName');

    if (eventUrl == null || eventUrl.isEmpty) {
      debugPrint(
          'Debug: eventUrl ist null oder leer. Zeige Standard-CircleAvatar.');
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
      debugPrint('Debug: eventUrl ist emoji: $emoji');
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
      final iconCodePointString = eventUrl.substring(5);
      final iconCodePoint = int.tryParse(iconCodePointString);
      debugPrint(
          'Debug: eventUrl ist icon:. Code-Punkt-String: "$iconCodePointString", geparsed: $iconCodePoint');
      if (iconCodePoint != null) {
        return Icon(
          IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
          size: size,
          color: Colors.black,
        );
      } else {
        debugPrint(
            'Fehler: Konnte Icon-Code-Punkt nicht von "$iconCodePointString" parsen. Zeige Fehler-Icon.');
        return Icon(
          Icons.error_outline,
          size: size,
          color: AppColors.famkaRed,
        );
      }
    } else if (eventUrl.startsWith('image:')) {
      final imageUrl = eventUrl.substring(6);
      debugPrint('Debug: eventUrl ist image:. Bild-URL: "$imageUrl"');
      if (imageUrl.isNotEmpty) {
        Widget imageWidget;
        if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
          final Uri uri = Uri.parse(imageUrl);
          final Map<String, String> params = Map.from(uri.queryParameters);
          params['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
          final String newImageUrl =
              uri.replace(queryParameters: params).toString();
          debugPrint('Debug: Cache-busted URL: $newImageUrl');

          imageWidget = Image.network(
            newImageUrl,
            fit: BoxFit.contain,
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) {
              debugPrint(
                  'Fehler: Laden des Netzwerkbildes fehlgeschlagen: $imageUrl, Fehler: $error');
              return Icon(
                Icons.broken_image,
                size: size,
                color: AppColors.famkaRed,
              );
            },
          );
        } else if (imageUrl.startsWith('assets/')) {
          imageWidget = Image.asset(
            imageUrl,
            fit: BoxFit.contain,
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) {
              debugPrint(
                  'Fehler: Laden des Asset-Bildes fehlgeschlagen: $imageUrl, Fehler: $error');
              return Icon(
                Icons.broken_image,
                size: size,
                color: AppColors.famkaRed,
              );
            },
          );
        } else if (File(imageUrl).existsSync()) {
          imageWidget = Image.file(
            File(imageUrl),
            fit: BoxFit.contain,
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) {
              debugPrint(
                  'Fehler: Laden des Datei-Bildes fehlgeschlagen: $imageUrl, Fehler: $error');
              return Icon(
                Icons.broken_image,
                size: size,
                color: AppColors.famkaRed,
              );
            },
          );
        } else {
          debugPrint(
              'Fehler: Bild-URL "$imageUrl" ist kein gültiger Netzwerk-, Asset- oder Dateipfad. Zeige Fehler-Icon.');
          return Icon(
            Icons.broken_image,
            size: size,
            color: AppColors.famkaRed,
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(0.0),
          child: SizedBox(
            width: size,
            height: size,
            child: imageWidget,
          ),
        );
      } else {
        debugPrint(
            'Fehler: Bild-URL ist nach dem "image:" Präfix leer. Zeige Fehler-Icon.');
        return Icon(
          Icons.broken_image,
          size: size,
          color: AppColors.famkaRed,
        );
      }
    }

    debugPrint(
        'Debug: eventUrl "$eventUrl" stimmte mit keinem bekannten Typ überein. Zeige generischen Fallback.');
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
            color: Colors.grey.withOpacity(0.1),
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
                        final Set<String> allParticipantIds = {};
                        allParticipantIds.addAll(event.acceptedMemberIds);
                        allParticipantIds.addAll(event.invitedMemberIds);
                        allParticipantIds.addAll(event.maybeMemberIds);

                        final List<String> participantNames =
                            allParticipantIds.map((id) {
                          final AppUser user = groupMembers.firstWhere(
                            (u) => u.profilId == id,
                            orElse: () => AppUser(
                              profilId: id,
                              firstName: 'Unbekannt ($id)',
                              lastName: '',
                              email: '',
                              phoneNumber: '',
                              avatarUrl: '',
                              miscellaneous: '',
                              password: '',
                            ),
                          );
                          return user.firstName ?? 'Unbekannt';
                        }).toList();

                        final bool isAllDayEvent = false;
                        String dateDisplay = DateFormat('dd.MM.yyyy')
                            .format(event.singleEventDate);
                        dateDisplay +=
                            ' ${DateFormat('HH:mm').format(event.singleEventDate)}';

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
                                    width: 40,
                                    height: 40,
                                    child: _buildEventLeadingIcon(
                                      event.singleEventUrl,
                                      event.singleEventName,
                                      size: 40.0,
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
                                        color: AppColors.famkaGrey),
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
                                  const SizedBox(height: 4),
                                  Text(
                                      'Teilnehmer: ${participantNames.join(', ')}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Beschreibung: ${event.singleEventDescription.isNotEmpty ? event.singleEventDescription : "Keine Beschreibung"}',
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
