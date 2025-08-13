import 'package:flutter/material.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/event_image.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

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
    initializeDateFormatting('de', null);
    initializeDateFormatting('en', null);

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

  Widget _buildEventLeadingIcon(String? eventUrl, String eventName, double size,
      {bool isClickable = true}) {
    Widget iconWidget;

    if (eventUrl == null || eventUrl.isEmpty) {
      iconWidget = CircleAvatar(
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
    } else if (eventUrl.startsWith('emoji:')) {
      final emoji = eventUrl.substring(6);
      iconWidget = SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            emoji,
            style: const TextStyle(
              fontFamilyFallback: [
                'Apple Color Emoji',
                'Segoe UI Emoji',
                'Segoe UI Symbol'
              ],
            ),
          ),
        ),
      );
    } else if (eventUrl.startsWith('icon:')) {
      final iconCodePoint = int.tryParse(eventUrl.substring(5));
      if (iconCodePoint != null) {
        iconWidget = Icon(
          IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
          size: size * 0.9,
          color: AppColors.famkaBlack,
        );
      } else {
        iconWidget =
            Icon(Icons.broken_image, size: size * 0.7, color: Colors.red);
      }
    } else if (eventUrl.startsWith('image:')) {
      final actualImageUrl = eventUrl.substring(6);
      if (actualImageUrl.startsWith('http://') ||
          actualImageUrl.startsWith('https://')) {
        iconWidget = EventImage(
          widget.db,
          currentAvatarUrl: actualImageUrl,
          displayRadius: size / 2,
          applyTransformOffset: false,
          isInteractive: false,
        );
      } else {
        iconWidget = Image.asset(
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
    } else {
      iconWidget = EventImage(
        widget.db,
        currentAvatarUrl: eventUrl,
        displayRadius: size / 2,
        applyTransformOffset: false,
        isInteractive: false,
      );
    }

    if (isClickable && _canShowEnlarged(eventUrl)) {
      return GestureDetector(
        onTap: () => _showEnlargedImage(eventUrl!, eventName),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: iconWidget,
          ),
        ),
      );
    }

    return iconWidget;
  }

  bool _canShowEnlarged(String? eventUrl) {
    if (eventUrl == null || eventUrl.isEmpty) return false;
    return eventUrl.startsWith('image:') ||
        eventUrl.startsWith('http://') ||
        eventUrl.startsWith('https://') ||
        (!eventUrl.startsWith('emoji:') && !eventUrl.startsWith('icon:'));
  }

  void _showEnlargedImage(String eventUrl, String eventName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black54,
                ),
              ),
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.famkaBlue,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                eventName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: _buildEnlargedImageWidget(eventUrl),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnlargedImageWidget(String eventUrl) {
    if (eventUrl.startsWith('image:')) {
      final actualImageUrl = eventUrl.substring(6);
      if (actualImageUrl.startsWith('http://') ||
          actualImageUrl.startsWith('https://')) {
        return EventImage(
          widget.db,
          currentAvatarUrl: actualImageUrl,
          displayRadius: 150,
          applyTransformOffset: false,
          isInteractive: false,
        );
      } else {
        return Image.asset(
          actualImageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 64, color: Colors.red),
                SizedBox(height: 8),
                Text("Image could not be loaded"),
              ],
            );
          },
        );
      }
    } else {
      return EventImage(
        widget.db,
        currentAvatarUrl: eventUrl,
        displayRadius: 150,
        applyTransformOffset: false,
        isInteractive: false,
      );
    }
  }

  Future<void> _saveDescription(SingleEvent event) async {
    final String newDescription =
        _descriptionControllers[event.singleEventId]?.text ?? '';

    print('Saving description for event: ${event.singleEventId}');
    print('Old description: "${event.singleEventDescription}"');
    print('New description: "$newDescription"');

    if (newDescription != event.singleEventDescription) {
      final updatedEvent =
          event.copyWith(singleEventDescription: newDescription);

      print('Calling database update...');

      try {
        await widget.db.updateEvent(updatedEvent.groupId, updatedEvent);

        print('Database update successful');

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
            SnackBar(
                content: Text(
                    AppLocalizations.of(context)!.descriptionUpdateSuccess)),
          );
        }
      } catch (e) {
        print('Database update failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .descriptionUpdateError(e.toString())),
              backgroundColor: AppColors.famkaRed,
            ),
          );
        }
      }
    } else {
      print('No changes detected');
      if (mounted) {
        setState(() {
          _isEditingDescription[event.singleEventId] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.noChangesToSave)),
        );
      }
    }
  }

  Future<void> _saveAllDescriptions() async {
    bool hasChanges = false;

    for (var event in _currentEvents) {
      if (_isEditingDescription[event.singleEventId] == true) {
        final newDescription =
            _descriptionControllers[event.singleEventId]?.text ?? '';
        if (newDescription != event.singleEventDescription) {
          hasChanges = true;
          await _saveDescription(event);
        } else {
          setState(() {
            _isEditingDescription[event.singleEventId] = false;
          });
        }
      }
    }

    if (!hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noChangesToSave)),
      );
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
          title: Text(
            AppLocalizations.of(context)!.deleteAppointment,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            AppLocalizations.of(context)!
                .confirmDeleteAppointment(event.singleEventName),
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
                  child: ButtonLinearGradient(
                    buttonText: AppLocalizations.of(context)!.cancelButton,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: ButtonLinearGradient(
                    buttonText: AppLocalizations.of(context)!.deleteImageButton,
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
                        return user.firstName;
                      }).toList();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
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
                                            event.isAllDay
                                                ? AppLocalizations.of(context)!
                                                    .timeAllDay
                                                : '${AppLocalizations.of(context)!.timeAt(DateFormat('HH:mm', Localizations.localeOf(context).languageCode).format(event.singleEventDate))}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .location(
                                                    event.singleEventLocation),
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
                                          onPressed: () async {
                                            if (isEditing) {
                                              await _saveDescription(event);
                                            } else {
                                              setState(() {
                                                _isEditingDescription[
                                                    event.singleEventId] = true;
                                              });
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_forever,
                                              color: AppColors.famkaGrey),
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
                                        decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)!
                                                  .editDescription,
                                          border: const OutlineInputBorder(),
                                        ),
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        onSubmitted: (_) async {
                                          await _saveDescription(event);
                                        },
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!
                                            .description(event
                                                    .singleEventDescription
                                                    .isNotEmpty
                                                ? event.singleEventDescription
                                                : AppLocalizations.of(context)!
                                                    .noDescription),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.participants(
                                      participantNames.join(', ')),
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
                              await _saveAllDescriptions();
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
                            child: ButtonLinearGradient(
                              buttonText:
                                  AppLocalizations.of(context)!.closeButton,
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
