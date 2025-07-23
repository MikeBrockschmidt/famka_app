import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/theme/font_theme.dart';
import 'dart:io';

class InfoBottomSheet extends StatefulWidget {
  const InfoBottomSheet({
    super.key,
    required this.date,
    required this.userName,
    required this.eventsForPerson,
    required this.currentGroupMembers,
    this.onEventDeleted,
    required this.db,
  });

  final DateTime date;
  final String userName;
  final List<SingleEvent> eventsForPerson;
  final List<AppUser> currentGroupMembers;
  final Function(String eventId)? onEventDeleted;
  final DatabaseRepository db;

  @override
  State<InfoBottomSheet> createState() => _InfoBottomSheetState();
}

class _InfoBottomSheetState extends State<InfoBottomSheet> {
  Widget _buildEventLeadingIcon(String? url, String name,
      {double size = 32.0}) {
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey.shade200,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(fontSize: size * 0.5, color: AppColors.famkaBlack),
        ),
      );
    }

    if (url.startsWith('emoji:')) {
      return Text(
        url.substring(6),
        style: TextStyle(fontSize: size * 0.9),
      );
    } else if (url.startsWith('icon:')) {
      final iconCode = int.tryParse(url.substring(5));
      if (iconCode != null) {
        return Icon(IconData(iconCode, fontFamily: 'MaterialIcons'),
            size: size, color: Colors.black);
      }
    } else if (url.startsWith('image:')) {
      final assetPath = url.substring(6);
      return Image.asset(
        assetPath,
        fit: BoxFit.contain,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image, color: AppColors.famkaRed),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.red.shade100,
      child: Text('!',
          style: TextStyle(fontSize: size * 0.5, color: AppColors.famkaRed)),
    );
  }

  void _deleteEvent(SingleEvent event) async {
    final confirm = await showDialog<bool>(
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
                    child: const ButtonLinearGradient(buttonText: 'Löschen'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Abbrechen',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirm == true) {
      print('Attempting to delete event: ${event.singleEventId}');
      try {
        await widget.db.deleteEvent(event.groupId, event.singleEventId);
        print('Event deleted successfully: ${event.singleEventId}');
        widget.onEventDeleted?.call(event
            .singleEventId); // Hier ist der Callback für Löschungen korrekt
      } catch (e) {
        print('Error deleting event: $e');
      }
      if (mounted)
        Navigator.of(context)
            .pop(true); // Signalisiere, dass etwas geändert wurde
    }
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
            Text('Keine Events für diesen Tag.',
                style: Theme.of(context).textTheme.titleMedium),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.eventsForPerson.map((event) {
                  final List<String> names = event.acceptedMemberIds.map((id) {
                    final AppUser user = widget.currentGroupMembers.firstWhere(
                      (u) => u.profilId == id,
                      orElse: () => AppUser(
                        profilId: id,
                        firstName: id,
                        lastName: '',
                        email: '',
                        phoneNumber: '',
                        avatarUrl: '',
                        miscellaneous: '',
                        password: '',
                      ),
                    );
                    return user.firstName;
                  }).toList();

                  String dateDisplay =
                      DateFormat('dd.MM.yyyy').format(event.singleEventDate);

                  return ListTile(
                    leading: _buildEventLeadingIcon(
                        event.singleEventUrl, event.singleEventName),
                    title: Text(event.singleEventName,
                        style: Theme.of(context).textTheme.titleLarge),
                    subtitle: Text('Teilnehmer: ${names.join(', ')}',
                        style: Theme.of(context).textTheme.titleMedium),
                    onTap: () {
                      final TextEditingController descriptionController =
                          TextEditingController(
                              text: event.singleEventDescription);

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            titlePadding:
                                const EdgeInsets.fromLTRB(24, 24, 16, 0),
                            title: Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: _buildEventLeadingIcon(
                                    event.singleEventUrl,
                                    event.singleEventName,
                                    size: 50,
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
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Ort: ${event.singleEventLocation}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 4),
                                  Text('Datum: $dateDisplay',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 4),
                                  Text('Teilnehmer: ${names.join(', ')}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 4),
                                  // Das TextField ohne sichtbaren Rahmen
                                  TextField(
                                    controller: descriptionController,
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    decoration: const InputDecoration(
                                      labelText: 'Beschreibung',
                                      border: InputBorder.none, // Kein Rahmen
                                      focusedBorder: InputBorder
                                          .none, // Kein Rahmen im Fokus
                                      enabledBorder: InputBorder
                                          .none, // Kein Rahmen im enabled Zustand
                                      errorBorder: InputBorder
                                          .none, // Kein Rahmen bei Fehlern
                                      disabledBorder: InputBorder
                                          .none, // Kein Rahmen bei Deaktivierung
                                      hintText: 'Keine Beschreibung',
                                      contentPadding:
                                          EdgeInsets.zero, // Padding anpassen
                                      isDense: true, // Macht das Feld kompakter
                                    ),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    print('Speichern Button geklickt!');
                                    final updatedDescription =
                                        descriptionController.text.trim();
                                    print(
                                        'Neue Beschreibung: "$updatedDescription"');
                                    final updatedEvent = event.copyWith(
                                        singleEventDescription:
                                            updatedDescription);

                                    try {
                                      await widget.db.updateEvent(
                                          event.groupId, updatedEvent);
                                      print(
                                          'Event erfolgreich aktualisiert in DB.');
                                      if (mounted) {
                                        // Dialog schließen und "true" zurückgeben, um dem aufrufenden Widget zu signalisieren, dass sich etwas geändert hat
                                        Navigator.of(context).pop(true);
                                        print(
                                            'Dialog geschlossen mit Ergebnis: true');
                                      }
                                    } catch (e) {
                                      print(
                                          'Fehler beim Aktualisieren des Events: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Fehler beim Speichern der Beschreibung: $e')),
                                      );
                                      if (mounted) {
                                        Navigator.of(context).pop(
                                            false); // Bei Fehler "false" zurückgeben
                                      }
                                    }
                                  },
                                  child: const ButtonLinearGradient(
                                      buttonText: 'Speichern & Schließen'),
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
              onTap: () => Navigator.of(context)
                  .pop(false), // Signalisiere, dass nichts geändert wurde
              child: const ButtonLinearGradient(buttonText: 'Schließen'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
        ],
      ),
    );
  }
}
