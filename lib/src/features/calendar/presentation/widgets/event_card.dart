import 'package:flutter/material.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/event_icon_widget.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/event_title_editor.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/enlarged_image_dialog.dart';

class EventCard extends StatelessWidget {
  final SingleEvent event;
  final List<AppUser> currentGroupMembers;
  final bool isEditing;
  final TextEditingController descriptionController;
  final TextEditingController titleController;
  final dynamic db;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onSavePressed;
  final ValueChanged<String>? onDescriptionSubmitted;
  final ValueChanged<String>? onTitleSubmitted;
  final ValueChanged<SingleEvent>? onEventUpdated;

  const EventCard({
    super.key,
    required this.event,
    required this.currentGroupMembers,
    required this.isEditing,
    required this.descriptionController,
    required this.titleController,
    required this.db,
  this.onEditPressed,
  this.onDeletePressed,
  this.onSavePressed,
  this.onDescriptionSubmitted,
  this.onTitleSubmitted,
  this.onEventUpdated,
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
                        Text(
                          event.isAllDay
                              ? AppLocalizations.of(context)!.timeAllDay
                              : AppLocalizations.of(context)!.timeAt(event
                                      .singleEventDate
                                      .toLocal()
                                      .hour
                                      .toString()
                                      .padLeft(2, '0') +
                                  ':' +
                                  event.singleEventDate
                                      .toLocal()
                                      .minute
                                      .toString()
                                      .padLeft(2, '0')),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!
                              .location(event.singleEventLocation),
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
              Text(
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
}
