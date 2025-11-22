import 'package:flutter/material.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/event_icon_widget.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/event_title_editor.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/enlarged_image_dialog.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/date_picker.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/time_picker.dart';
import 'package:famka_app/src/common/image_utils.dart';

class EventCard extends StatelessWidget {
  final SingleEvent event;
  final List<AppUser> currentGroupMembers;
  final bool isEditing;
  final TextEditingController descriptionController;
  final TextEditingController titleController;
  final TextEditingController locationController;
  final DateTime selectedDate;
  final bool isAllDay;
  final dynamic db;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onSavePressed;
  final ValueChanged<String>? onDescriptionSubmitted;
  final ValueChanged<String>? onTitleSubmitted;
  final ValueChanged<String>? onLocationSubmitted;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<bool>? onAllDayChanged;
  final ValueChanged<SingleEvent>? onEventUpdated;
  final ValueChanged<List<String>>? onParticipantsChanged;
  final VoidCallback? onTimeRangeEditPressed; // Neuer Callback für Zeitraum-Bearbeitung

  const EventCard({
    super.key,
    required this.event,
    required this.currentGroupMembers,
    required this.isEditing,
    required this.descriptionController,
    required this.titleController,
    required this.locationController,
    required this.selectedDate,
    required this.isAllDay,
    required this.db,
    this.onEditPressed,
    this.onDeletePressed,
    this.onSavePressed,
    this.onDescriptionSubmitted,
    this.onTitleSubmitted,
    this.onLocationSubmitted,
    this.onDateChanged,
    this.onAllDayChanged,
    this.onEventUpdated,
    this.onParticipantsChanged,
    this.onTimeRangeEditPressed, // Neuer Parameter hinzufügen
  });

  @override
  Widget build(BuildContext context) {
    final Set<String> allParticipantIds = {};
    allParticipantIds.addAll(event.acceptedMemberIds);
    allParticipantIds.addAll(event.invitedMemberIds);
    allParticipantIds.addAll(event.maybeMemberIds);

    final List<String> participantNames = allParticipantIds.map((id) {
      final AppUser user = currentGroupMembers.firstWhere(
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
      return user.firstName;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        color: AppColors.famkaWhite,
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
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => EnlargedImageDialog(
                            eventUrl: event.singleEventUrl,
                            eventName: event.singleEventName,
                            event: event,
                            db: db,
                            onEventUpdated: (updatedEvent) {
                              if (onEventUpdated != null) {
                                onEventUpdated!(updatedEvent);
                              }
                            },
                          ),
                        );
                      },
                      child: EventIconWidget(
                        eventUrl: event.singleEventUrl,
                        eventName: event.singleEventName,
                        size: 50,
                        db: db,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EventTitleEditor(
                          title: event.singleEventName,
                          isEditing: isEditing,
                          controller: titleController,
                          onSubmitted: (value) {
                            debugPrint(
                                'EventCard: onTitleSubmitted ausgelöst mit Wert: $value');
                            if (onTitleSubmitted != null) {
                              onTitleSubmitted!(value);
                            }
                          },
                        ),
                        const SizedBox(height: 4),
                        // Datum/Zeit Bereich
                        isEditing
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.timeAllDay,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      Switch(
                                        value: isAllDay,
                                        onChanged: onAllDayChanged,
                                        activeColor: AppColors.famkaGreen,
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final date = await selectAppointmentDate(
                                        context,
                                        initialDate: selectedDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null) {
                                        if (!isAllDay) {
                                          final time = await selectAppointmentTime(
                                            context,
                                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                                          );
                                          if (time != null) {
                                            final newDateTime = DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                              time.hour,
                                              time.minute,
                                            );
                                            onDateChanged?.call(newDateTime);
                                          }
                                        } else {
                                          onDateChanged?.call(date);
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isAllDay
                                            ? '${selectedDate.day}.${selectedDate.month}.${selectedDate.year} (${AppLocalizations.of(context)!.timeAllDay})'
                                            : '${selectedDate.day}.${selectedDate.month}.${selectedDate.year} ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Zeitanzeige mit Startzeit und optionaler Endzeit
                                  Row(
                                    children: [
                                      Expanded(
                                        child: isAllDay
                                            ? Text(
                                                AppLocalizations.of(context)!.timeAllDay,
                                                style: Theme.of(context).textTheme.bodyLarge,
                                              )
                                            : event.selectedDateRange != null
                                                ? Text(
                                                    '${AppLocalizations.of(context)!.timeAt(selectedDate.toLocal().hour.toString().padLeft(2, '0') + ':' + selectedDate.toLocal().minute.toString().padLeft(2, '0'))} - ${event.selectedDateRange!.end.hour.toString().padLeft(2, '0')}:${event.selectedDateRange!.end.minute.toString().padLeft(2, '0')}',
                                                    style: Theme.of(context).textTheme.bodyLarge,
                                                  )
                                                : Text(
                                                    AppLocalizations.of(context)!.timeAt(selectedDate.toLocal().hour.toString().padLeft(2, '0') + ':' + selectedDate.toLocal().minute.toString().padLeft(2, '0')),
                                                    style: Theme.of(context).textTheme.bodyLarge,
                                                  ),
                                      ),
                                      if (!isAllDay && isEditing)
                                        IconButton(
                                          icon: const Icon(Icons.access_time),
                                          color: AppColors.famkaBlue,
                                          onPressed: () async {
                                            // Callback für Zeit-Bearbeitung
                                            onTimeRangeEditPressed?.call();
                                          },
                                          tooltip: 'Zeitraum bearbeiten',
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                        const SizedBox(height: 4),
                        // Ort Bereich
                        isEditing
                            ? TextField(
                                controller: locationController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.locationLabel,
                                  border: const OutlineInputBorder(),
                                ),
                                onSubmitted: onLocationSubmitted,
                              )
                            : Text(
                                AppLocalizations.of(context)!
                                    .location(locationController.text),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(isEditing ? Icons.check : Icons.edit),
                            color: isEditing
                                ? AppColors.famkaGreen
                                : AppColors.famkaGrey,
                            onPressed: () {
                              if (isEditing) {
                                debugPrint(
                                    'EventCard: Check-Icon (Speichern) wurde geklickt. Titel: ${titleController.text}, Beschreibung: ${descriptionController.text}');
                                if (onSavePressed != null) {
                                  onSavePressed!();
                                }
                              } else {
                                debugPrint(
                                    'EventCard: Edit-Icon wurde geklickt.');
                              }
                              if (onEditPressed != null) {
                                onEditPressed!();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever,
                                color: AppColors.famkaGrey),
                            onPressed: onDeletePressed,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              isEditing
                  ? TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.editDescription,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onSubmitted: (value) {
                        debugPrint(
                            'EventCard: onDescriptionSubmitted ausgelöst mit Wert: $value');
                        if (onDescriptionSubmitted != null) {
                          onDescriptionSubmitted!(value);
                        }
                      },
                    )
                  : Text(
                      AppLocalizations.of(context)!.description(
                          event.singleEventDescription.isNotEmpty
                              ? event.singleEventDescription
                              : AppLocalizations.of(context)!.noDescription),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
              const SizedBox(height: 8),
              isEditing
                  ? _buildParticipantsEditor(context)
                  : Text(
                      AppLocalizations.of(context)!
                          .participants(participantNames.join(', ')),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsEditor(BuildContext context) {
    final Set<String> allParticipantIds = {};
    allParticipantIds.addAll(event.acceptedMemberIds);
    allParticipantIds.addAll(event.invitedMemberIds);
    allParticipantIds.addAll(event.maybeMemberIds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.group, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              'Teilnehmer:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: currentGroupMembers.map((member) {
              final isSelected = allParticipantIds.contains(member.profilId);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    Set<String> updatedParticipants = Set.from(allParticipantIds);
                    if (isSelected) {
                      updatedParticipants.remove(member.profilId);
                    } else {
                      updatedParticipants.add(member.profilId);
                    }
                    onParticipantsChanged?.call(updatedParticipants.toList());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.famkaRed : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: DynamicAvatar(
                      avatarUrl: member.avatarUrl,
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      fallbackIcon: Icons.person,
                      iconSize: 20,
                      iconColor: isSelected ? AppColors.famkaRed : Colors.grey[600],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${allParticipantIds.length} von ${currentGroupMembers.length} ausgewählt',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
