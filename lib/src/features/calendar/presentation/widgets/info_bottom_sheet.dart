import 'package:flutter/material.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/event_card.dart';

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
  void _updateEventInSheet(SingleEvent updatedEvent) {
    setState(() {
      final index = _currentEvents
          .indexWhere((e) => e.singleEventId == updatedEvent.singleEventId);
      if (index != -1) {
        _currentEvents[index] = updatedEvent;
      }
    });
  }

  late Map<String, TextEditingController> _descriptionControllers;
  late Map<String, TextEditingController> _titleControllers;
  late Map<String, bool> _isEditingDescription;
  List<SingleEvent> _currentEvents = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de', null);
    initializeDateFormatting('en', null);

    _currentEvents = List.from(widget.eventsForPerson);
    _descriptionControllers = {};
    _titleControllers = {};
    _isEditingDescription = {};

    for (var event in _currentEvents) {
      _descriptionControllers[event.singleEventId] =
          TextEditingController(text: event.singleEventDescription);
      _titleControllers[event.singleEventId] =
          TextEditingController(text: event.singleEventName);
      _isEditingDescription[event.singleEventId] = false;
    }
  }

  @override
  void dispose() {
  _descriptionControllers.forEach((key, controller) => controller.dispose());
  _titleControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  // ...existing code...
  // Die Methoden und Widgets für EventCard, EnlargedImageDialog, EventDescriptionEditor, EventParticipants wurden ausgelagert.
  // Die Logik für die Nutzung der neuen Widgets wird im nächsten Schritt eingefügt.

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
                          DateFormat('dd. MMMM yyyy',
                                  Localizations.localeOf(context).languageCode)
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
                          AppLocalizations.of(context)!
                              .appointmentsFor(widget.userName),
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
                      return EventCard(
                        event: event,
                        currentGroupMembers: widget.currentGroupMembers,
                        isEditing: isEditing,
                        descriptionController: _descriptionControllers[event.singleEventId]!,
                        titleController: _titleControllers[event.singleEventId]!,
                        db: widget.db,
                        onEditPressed: () {
                          debugPrint('info_bottom_sheet: onEditPressed ausgeführt. isEditing: $isEditing, Titel: ${_titleControllers[event.singleEventId]?.text}, Beschreibung: ${_descriptionControllers[event.singleEventId]?.text}');
                          setState(() {
                            _isEditingDescription[event.singleEventId] = !isEditing;
                          });
                        },
                        onDeletePressed: () async {
                          final bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Text(AppLocalizations.of(context)!.deleteAppointment,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                content: Text(AppLocalizations.of(context)!.confirmDeleteAppointment(event.singleEventName),
                                    style: const TextStyle(color: Colors.black87)),
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
                                        child: ButtonLinearGradient(
                                          buttonText: AppLocalizations.of(context)!.cancelButton,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop(true);
                                        },
                                        child: Text(AppLocalizations.of(context)!.deleteImageButton,
                                            style: const TextStyle(
                                              color: AppColors.famkaGrey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirm == true) {
                            widget.onEventDeleted?.call(event.singleEventId);
                            setState(() {
                              _currentEvents.removeWhere((e) => e.singleEventId == event.singleEventId);
                            });
                            if (_currentEvents.isEmpty) {
                              Navigator.of(context).pop(true);
                            }
                          }
                        },
                        onSavePressed: () async {
                          final String newDescription = _descriptionControllers[event.singleEventId]?.text ?? '';
                          final String newTitle = _titleControllers[event.singleEventId]?.text ?? '';
                          debugPrint('info_bottom_sheet: onSavePressed ausgeführt. Titel: $newTitle, Beschreibung: $newDescription');
                          bool changed = false;
                          SingleEvent updatedEvent = event;
                          if (newDescription != event.singleEventDescription) {
                            updatedEvent = updatedEvent.copyWith(singleEventDescription: newDescription);
                            changed = true;
                          }
                          if (newTitle != event.singleEventName) {
                            updatedEvent = updatedEvent.copyWith(singleEventName: newTitle);
                            changed = true;
                          }
                          if (changed) {
                            await widget.db.updateEvent(updatedEvent.groupId, updatedEvent);
                            setState(() {
                              final index = _currentEvents.indexWhere((e) => e.singleEventId == event.singleEventId);
                              if (index != -1) {
                                _currentEvents[index] = updatedEvent;
                              }
                              _isEditingDescription[event.singleEventId] = false;
                            });
                            widget.onEventUpdated?.call(updatedEvent);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.descriptionUpdateSuccess)),
                            );
                          } else {
                            setState(() {
                              _isEditingDescription[event.singleEventId] = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.noChangesToSave)),
                            );
                          }
                        },
                        onDescriptionSubmitted: (value) async {
                          final String newDescription = value;
                          final String newTitle = _titleControllers[event.singleEventId]?.text ?? '';
                          debugPrint('info_bottom_sheet: onDescriptionSubmitted ausgeführt. Titel: $newTitle, Beschreibung: $newDescription');
                          bool changed = false;
                          SingleEvent updatedEvent = event;
                          if (newDescription != event.singleEventDescription) {
                            updatedEvent = updatedEvent.copyWith(singleEventDescription: newDescription);
                            changed = true;
                          }
                          if (newTitle != event.singleEventName) {
                            updatedEvent = updatedEvent.copyWith(singleEventName: newTitle);
                            changed = true;
                          }
                          if (changed) {
                            await widget.db.updateEvent(updatedEvent.groupId, updatedEvent);
                            setState(() {
                              final index = _currentEvents.indexWhere((e) => e.singleEventId == event.singleEventId);
                              if (index != -1) {
                                _currentEvents[index] = updatedEvent;
                              }
                              _isEditingDescription[event.singleEventId] = false;
                            });
                            widget.onEventUpdated?.call(updatedEvent);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.descriptionUpdateSuccess)),
                            );
                          } else {
                            setState(() {
                              _isEditingDescription[event.singleEventId] = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.noChangesToSave)),
                            );
                          }
                        },
                        onTitleSubmitted: (value) async {
                          final String newTitle = value;
                          final String newDescription = _descriptionControllers[event.singleEventId]?.text ?? '';
                          debugPrint('info_bottom_sheet: onTitleSubmitted ausgeführt. Titel: $newTitle, Beschreibung: $newDescription');
                          bool changed = false;
                          SingleEvent updatedEvent = event;
                          if (newTitle != event.singleEventName) {
                            updatedEvent = updatedEvent.copyWith(singleEventName: newTitle);
                            changed = true;
                          }
                          if (newDescription != event.singleEventDescription) {
                            updatedEvent = updatedEvent.copyWith(singleEventDescription: newDescription);
                            changed = true;
                          }
                          if (changed) {
                            await widget.db.updateEvent(updatedEvent.groupId, updatedEvent);
                            setState(() {
                              final index = _currentEvents.indexWhere((e) => e.singleEventId == event.singleEventId);
                              if (index != -1) {
                                _currentEvents[index] = updatedEvent;
                              }
                              _isEditingDescription[event.singleEventId] = false;
                            });
                            widget.onEventUpdated?.call(updatedEvent);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.descriptionUpdateSuccess)),
                            );
                          } else {
                            setState(() {
                              _isEditingDescription[event.singleEventId] = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.noChangesToSave)),
                            );
                          }
                        },
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
                              bool hasChanges = false;
                              for (var event in _currentEvents) {
                                if (_isEditingDescription[
                                        event.singleEventId] ==
                                    true) {
                                  final newDescription =
                                      _descriptionControllers[
                                                  event.singleEventId]
                                              ?.text ??
                                          '';
                                  if (newDescription !=
                                      event.singleEventDescription) {
                                    final updatedEvent = event.copyWith(
                                        singleEventDescription: newDescription);
                                    await widget.db.updateEvent(
                                        updatedEvent.groupId, updatedEvent);
                                    setState(() {
                                      final index = _currentEvents.indexWhere(
                                          (e) =>
                                              e.singleEventId ==
                                              event.singleEventId);
                                      if (index != -1) {
                                        _currentEvents[index] = updatedEvent;
                                      }
                                      _isEditingDescription[
                                          event.singleEventId] = false;
                                    });
                                    widget.onEventUpdated?.call(updatedEvent);
                                    hasChanges = true;
                                  } else {
                                    setState(() {
                                      _isEditingDescription[
                                          event.singleEventId] = false;
                                    });
                                  }
                                }
                              }
                              if (!hasChanges) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .noChangesToSave)),
                                );
                              }
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            },
                            child: ButtonLinearGradient(
                              buttonText:
                                  AppLocalizations.of(context)!.saveButton,
                            ),
                          ),
                        ),
                        const SizedBox(width: 26),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.closeButton,
                                style: TextStyle(
                                  color: AppColors.famkaGrey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
