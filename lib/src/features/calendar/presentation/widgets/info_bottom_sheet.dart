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
  final ValueChanged<SingleEvent>? onEventUpdated;

  const InfoBottomSheet({
    super.key,
    required this.date,
    required this.userName,
    required this.eventsForPerson,
    required this.currentGroupMembers,
    required this.db,
    this.onEventDeleted,
    this.onEventUpdated,
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
          widget.onEventUpdated?.call(updatedEvent);
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

  Future<void> _confirmAndDeleteEvent(SingleEvent event) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Termin löschen',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Möchtest du "${event.singleEventName}" wirklich unwiderruflich löschen?',
            style: TextStyle(color: Colors.black87),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const ButtonLinearGradient(
                    buttonText: 'Abbrechen',
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const ButtonLinearGradient(
                    buttonText: 'Löschen',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      widget.onEventDeleted?.call(event.singleEventId);
      if (mounted) {
        setState(() {
          _currentEvents
              .removeWhere((e) => e.singleEventId == event.singleEventId);
        });
        if (_currentEvents.isEmpty) {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          DateFormat('dd. MMMM yyyy', 'de_DE')
                              .format(widget.date),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.famkaBlack,
                              ),
                        ),
                        Text(
                          'Termine für ${widget.userName}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.famkaGrey,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    controller: scrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
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
                                            event.isAllDay // <-- HIER wurde die Logik geändert
                                                ? 'Uhrzeit:  '
                                                : 'Uhrzeit: ${DateFormat('HH:mm', 'de_DE').format(event.singleEventDate)} Uhr',
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
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
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
                                              } else {
                                                _saveDescription(event);
                                              }
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_forever,
                                              color: AppColors.famkaRed),
                                          onPressed: () =>
                                              _confirmAndDeleteEvent(event),
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
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 52),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              for (var event in _currentEvents) {
                                if (_isEditingDescription[
                                        event.singleEventId] ==
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
                        const SizedBox(width: 26),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
