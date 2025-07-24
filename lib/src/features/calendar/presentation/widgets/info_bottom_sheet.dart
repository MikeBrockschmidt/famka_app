// lib/src/features/calendar/presentation/widgets/info_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:intl/intl.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/event_image.dart';

class InfoBottomSheet extends StatefulWidget {
  final DateTime date;
  final String userName;
  final List<SingleEvent> eventsForPerson;
  final List<AppUser> currentGroupMembers;
  final DatabaseRepository db;
  final ValueChanged<String>? onEventDeleted;
  final ValueChanged<SingleEvent>?
      onEventUpdated; // NEU: Callback für aktualisierte Events

  const InfoBottomSheet({
    super.key,
    required this.date,
    required this.userName,
    required this.eventsForPerson,
    required this.currentGroupMembers,
    required this.db,
    this.onEventDeleted,
    this.onEventUpdated, // NEU: Initialisierung des Callbacks
  });

  @override
  State<InfoBottomSheet> createState() => _InfoBottomSheetState();
}

class _InfoBottomSheetState extends State<InfoBottomSheet> {
  late Map<String, TextEditingController> _descriptionControllers;
  late Map<String, bool> _isEditingDescription;
  List<SingleEvent> _currentEvents = [];

  @override
  void initState() {
    super.initState();
    _currentEvents = List.from(widget.eventsForPerson);
    _descriptionControllers = {};
    _isEditingDescription = {};

    for (var event in _currentEvents) {
      _descriptionControllers[event.singleEventId] =
          TextEditingController(text: event.singleEventDescription);
      _isEditingDescription[event.singleEventId] = false;
    }
  }

  @override
  void dispose() {
    _descriptionControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Widget _buildEventLeadingIcon(
      String? eventUrl, String eventName, double size) {
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
            'Segoe UI Emoji',
            'Segoe UI Symbol'
          ],
        ),
      );
    } else if (eventUrl.startsWith('icon:')) {
      final iconCodePoint = int.tryParse(eventUrl.substring(5));
      if (iconCodePoint != null) {
        return Icon(
          IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
          size: size * 0.9,
          color: AppColors.famkaBlack,
        );
      }
    } else if (eventUrl.startsWith('image:')) {
      final actualImageUrl = eventUrl.substring(6);
      if (actualImageUrl.startsWith('http://') ||
          actualImageUrl.startsWith('https://')) {
        return EventImage(
          widget.db,
          currentAvatarUrl: actualImageUrl,
          displayRadius: size / 2,
          applyTransformOffset: false,
          isInteractive: false,
        );
      } else {
        return Image.asset(
          actualImageUrl,
          fit: BoxFit.contain,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image,
                size: size * 0.7, color: Colors.red);
          },
        );
      }
    }
    return EventImage(
      widget.db,
      currentAvatarUrl: eventUrl,
      displayRadius: size / 2,
      applyTransformOffset: false,
      isInteractive: false,
    );
  }

  Future<void> _saveDescription(SingleEvent event) async {
    final String newDescription =
        _descriptionControllers[event.singleEventId]?.text ?? '';
    if (newDescription != event.singleEventDescription) {
      final updatedEvent =
          event.copyWith(singleEventDescription: newDescription);
      try {
        await widget.db.updateEvent(updatedEvent.groupId, updatedEvent);
        if (mounted) {
          setState(() {
            final index = _currentEvents
                .indexWhere((e) => e.singleEventId == event.singleEventId);
            if (index != -1) {
              _currentEvents[index] = updatedEvent;
            }
            _isEditingDescription[event.singleEventId] = false;
          });
          widget.onEventUpdated?.call(
              updatedEvent); // NEU: Event an das übergeordnete Widget zurückgeben
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Beschreibung erfolgreich aktualisiert.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Aktualisieren der Beschreibung: $e'),
              backgroundColor: AppColors.famkaRed,
            ),
          );
        }
      }
    } else {
      // Wenn keine Änderung vorgenommen wurde, einfach den Bearbeitungsmodus beenden
      if (mounted) {
        setState(() {
          _isEditingDescription[event.singleEventId] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keine Änderungen zum Speichern.')),
        );
      }
    }
  }

  // NEUE Methode zum Bestätigen und Löschen eines einzelnen Events
  Future<void> _confirmAndDeleteEvent(SingleEvent event) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Termin löschen'),
          content: Text(
              'Möchtest du "${event.singleEventName}" wirklich unwiderruflich löschen?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Löschen',
                  style: TextStyle(color: AppColors.famkaRed)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      widget.onEventDeleted?.call(event.singleEventId);
      // Optional: Entferne das Event sofort aus der lokalen Liste
      if (mounted) {
        setState(() {
          _currentEvents
              .removeWhere((e) => e.singleEventId == event.singleEventId);
        });
        // Wenn keine Events mehr übrig sind, schließe das Bottom Sheet
        if (_currentEvents.isEmpty) {
          Navigator.of(context).pop(
              true); // Signalisiert dem aufrufenden Widget, dass Events gelöscht wurden
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5, // Startet mit 50% des Bildschirms
      minChildSize: 0.25, // Mindestgröße 25%
      maxChildSize: 0.9, // Maximalgröße 90%
      expand: false, // Nicht den ganzen Bildschirm ausfüllen
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      DateFormat('dd. MMMM yyyy', 'de_DE').format(widget.date),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.famkaBlack,
                              ),
                    ),
                    Text(
                      'Termine für ${widget.userName}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.famkaGrey,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller:
                      scrollController, // Wichtig: Controller an ListView binden
                  itemCount: _currentEvents.length,
                  itemBuilder: (context, index) {
                    final event = _currentEvents[index];
                    final isEditing =
                        _isEditingDescription[event.singleEventId] ?? false;

                    final Set<String> allParticipantIds = {};
                    allParticipantIds.addAll(event.acceptedMemberIds);
                    allParticipantIds.addAll(event.invitedMemberIds);
                    allParticipantIds.addAll(event.maybeMemberIds);

                    final List<String> participantNames =
                        allParticipantIds.map((id) {
                      final AppUser user =
                          widget.currentGroupMembers.firstWhere(
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

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: _buildEventLeadingIcon(
                                      event.singleEventUrl,
                                      event.singleEventName,
                                      50,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.singleEventName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.famkaBlue),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Uhrzeit: ${DateFormat('HH:mm', 'de_DE').format(event.singleEventDate)} Uhr',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ort: ${event.singleEventLocation}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // NEUE POSITION DER ICONS
                                  Row(
                                    mainAxisSize: MainAxisSize.min, // Wichtig!
                                    children: [
                                      IconButton(
                                        icon: Icon(isEditing
                                            ? Icons.check
                                            : Icons.edit),
                                        color: isEditing
                                            ? AppColors.famkaGreen
                                            : AppColors.famkaGrey,
                                        onPressed: () {
                                          setState(() {
                                            _isEditingDescription[event
                                                .singleEventId] = !isEditing;
                                            if (!isEditing) {
                                              // Wenn in den Bearbeitungsmodus gewechselt wird, nichts tun
                                            } else {
                                              // Wenn Bearbeitungsmodus verlassen wird, versuchen zu speichern
                                              _saveDescription(event);
                                            }
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_forever,
                                            color: AppColors.famkaRed),
                                        onPressed: () => _confirmAndDeleteEvent(
                                            event), // Rufe die neue Methode auf
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              isEditing
                                  ? TextField(
                                      controller: _descriptionControllers[
                                          event.singleEventId],
                                      decoration: const InputDecoration(
                                        labelText: 'Beschreibung bearbeiten',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                    )
                                  : Text(
                                      'Beschreibung: ${event.singleEventDescription.isNotEmpty ? event.singleEventDescription : "Keine Beschreibung"}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                              const SizedBox(height: 8),
                              Text(
                                'Teilnehmer: ${participantNames.join(', ')}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              // DER VORHERIGE "TERMIN LÖSCHEN" BUTTON WIRD HIER ENTFERNT
                              // const SizedBox(height: 16),
                              // Center(
                              //   child: GestureDetector(
                              //     onTap: () async {
                              //       final bool confirmDelete = await showDialog(
                              //             context: context,
                              //             builder:
                              //                 (BuildContext dialogContext) {
                              //               return AlertDialog(
                              //                 title:
                              //                     const Text('Termin löschen'),
                              //                 content: const Text(
                              //                     'Bist du sicher, dass du diesen Termin löschen möchtest?'),
                              //                 actions: <Widget>[
                              //                   TextButton(
                              //                     child:
                              //                         const Text('Abbrechen'),
                              //                     onPressed: () {
                              //                       Navigator.of(dialogContext)
                              //                           .pop(false);
                              //                     },
                              //                   ),
                              //                   TextButton(
                              //                     child: const Text('Löschen',
                              //                         style: TextStyle(
                              //                             color: AppColors
                              //                                 .famkaRed)),
                              //                     onPressed: () {
                              //                       Navigator.of(dialogContext)
                              //                           .pop(true);
                              //                     },
                              //                   ),
                              //                 ],
                              //               );
                              //             },
                              //           ) ??
                              //           false;
                              //       if (confirmDelete) {
                              //         widget.onEventDeleted
                              //             ?.call(event.singleEventId);
                              //         Navigator.of(context).pop(true);
                              //       }
                              //     },
                              //     child: const ButtonLinearGradient(
                              //       buttonText: 'Termin löschen',
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          // Nur speichern, wenn der Bearbeitungsmodus aktiv ist und Änderungen vorliegen
                          for (var event in _currentEvents) {
                            if (_isEditingDescription[event.singleEventId] ==
                                true) {
                              await _saveDescription(event);
                            }
                          }
                          Navigator.pop(context);
                        },
                        child: const ButtonLinearGradient(
                          buttonText: 'Speichern',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const ButtonLinearGradient(
                          buttonText: 'Schließen',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
