import 'package:famka_app/src/features/calendar/presentation/calendar_screen.dart';

import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/appointment_validators.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:famka_app/src/features/appointment/presentation/widgets/appointment_form_fields.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/event_participants_selector.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/gallery_selection_field.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/repeat_reminder_settings.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/save_appointment_button.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/time_picker.dart'
    as time_picker;
import 'package:famka_app/src/features/appointment/presentation/widgets/date_picker.dart';
import 'package:famka_app/src/data/auth_repository.dart';

// Auswahlmodus für Datum: Einzelner Tag oder Zeitraum
enum DateSelectionMode { single, range }

class Appointment extends StatefulWidget {
  final DatabaseRepository db;
  final AppUser? currentUser;
  final Group? currentGroup;
  final AuthRepository auth;

  const Appointment(
    this.db, {
    super.key,
    this.currentUser,
    this.currentGroup,
    required this.auth,
  });

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  Color _selectedRangeColor = AppColors.famkaYellow;
  final List<Color> _rangeColors = [
    AppColors.famkaYellow,
    AppColors.famkaGreen,
    AppColors.famkaCyan,
    AppColors.famkaRed,
    AppColors.famkaBlue,
  ];
  Widget _buildRangeColorPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _rangeColors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRangeColor = color;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              border: Border.all(
                color:
                    _selectedRangeColor == color ? color : Colors.transparent,
                width: 3,
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      }).toList(),
    );
  }

  DateTimeRange? _selectedDateRange;
  // Auswahlmodus für Datum: Einzelner Tag oder Zeitraum
  DateSelectionMode _dateMode = DateSelectionMode.single;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final GlobalKey _saveButtonKey = GlobalKey();

  bool _allDay = true;
  bool _repeat = false;
  bool _reminder = false;

  String? _selectedRepeat;
  String? _selectedReminder;

  late Future<List<AppUser>> _groupMembersFuture;
  Set<String> selectedMembers = {};

  String? _selectedGalleryItemContent;
  final Uuid _uuid = const Uuid();

  int _numberOfRepeats = 1;
  final TextEditingController _numberOfRepeatsController =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _dateController.text =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    if (widget.currentGroup != null) {
      _groupMembersFuture = Future.value(widget.currentGroup!.groupMembers);
    } else {
      _groupMembersFuture = Future.value([]);
    }
    _numberOfRepeatsController.text = _numberOfRepeats.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _selectedRepeat = l10n.repeatDaily;
          _selectedReminder = l10n.reminderOneHour;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _endTimeController.dispose();
    _numberOfRepeatsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validatorTitleEmpty;
    }
    if (value.length > 80) {
      return l10n.validatorTitleLength;
    }
    final RegExp emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true);
    if (emojiRegex.hasMatch(value)) {
      return l10n.validatorTitleEmojis;
    }
    return null;
  }

  String? _validateLocation(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (_dateMode == DateSelectionMode.range) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return l10n.validatorLocationEmpty;
    }
    final RegExp allowedChars = RegExp(r'^[a-zA-ZäöüÄÖÜß\s\d.,\-()\/]+$');
    if (!allowedChars.hasMatch(value)) {
      return l10n.validatorLocationInvalidChars;
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'Maximal 500 Zeichen erlaubt';
    }
    return null;
  }

  String? _validateNumberOfRepeats(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validatorRepeatCountEmpty;
    }
    final count = int.tryParse(value);
    if (count == null || count <= 0) {
      return l10n.validatorRepeatCountInvalid;
    }
    if (count > 365) {
      return l10n.validatorRepeatCountMax;
    }
    return null;
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  int _daysInMonth(int year, int month) {
    if (month == DateTime.february) {
      return _isLeapYear(year) ? 29 : 28;
    } else if (month == DateTime.april ||
        month == DateTime.june ||
        month == DateTime.september ||
        month == DateTime.november) {
      return 30;
    } else {
      return 31;
    }
  }

  Future<void> _generateAndSaveRecurringEvents(SingleEvent initialEvent) async {
    DateTime currentEventDate = initialEvent.singleEventDate;
    final List<Future<void>> saveOperations = [];
    int occurrencesGenerated = 0;

    int maxOccurrencesToGenerate = _numberOfRepeats;

    saveOperations.add(widget.db.createEvent(initialEvent));
    occurrencesGenerated++;

    while (occurrencesGenerated < maxOccurrencesToGenerate) {
      DateTime nextEventDate;
      try {
        final l10n = AppLocalizations.of(context)!;
        switch (_selectedRepeat) {
          case String repeat when repeat == l10n.repeatDaily:
            nextEventDate = currentEventDate.add(const Duration(days: 1));
            break;
          case String repeat when repeat == l10n.repeatWeekly:
            nextEventDate = currentEventDate.add(const Duration(days: 7));
            break;
          case String repeat when repeat == l10n.repeatMonthly:
            int newMonth = currentEventDate.month + 1;
            int newYear = currentEventDate.year;
            if (newMonth > 12) {
              newMonth = 1;
              newYear++;
            }
            int dayOfMonth =
                min(currentEventDate.day, _daysInMonth(newYear, newMonth));
            nextEventDate = DateTime(
              newYear,
              newMonth,
              dayOfMonth,
              currentEventDate.hour,
              currentEventDate.minute,
            );
            break;
          case String repeat when repeat == l10n.repeatYearly:
            int dayOfYear = currentEventDate.day;
            if (currentEventDate.month == DateTime.february &&
                currentEventDate.day == 29 &&
                !_isLeapYear(currentEventDate.year + 1)) {
              dayOfYear = 28;
            }
            nextEventDate = DateTime(
              currentEventDate.year + 1,
              currentEventDate.month,
              dayOfYear,
              currentEventDate.hour,
              currentEventDate.minute,
            );
            break;
          default:
            return;
        }
      } catch (e) {
        break;
      }

      currentEventDate = nextEventDate;

      final recurringEvent = SingleEvent(
        singleEventId: _uuid.v4(),
        singleEventName: initialEvent.singleEventName,
        singleEventLocation: initialEvent.singleEventLocation,
        singleEventDate: currentEventDate,
        singleEventUrl: initialEvent.singleEventUrl,
        singleEventDescription: initialEvent.singleEventDescription,
        groupId: initialEvent.groupId,
        creatorId: initialEvent.creatorId,
        acceptedMemberIds: initialEvent.acceptedMemberIds,
        invitedMemberIds: initialEvent.invitedMemberIds,
        maybeMemberIds: initialEvent.maybeMemberIds,
        declinedMemberIds: initialEvent.declinedMemberIds,
        isAllDay: initialEvent.isAllDay,
        hasReminder: initialEvent.hasReminder,
        reminderOffset: initialEvent.reminderOffset,
      );
      saveOperations.add(widget.db.createEvent(recurringEvent));
      occurrencesGenerated++;
    }

    await Future.wait(saveOperations);
  }

  void _createAndSaveAppointment() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      if (!mounted) return;

      if (_saveButtonKey.currentContext != null) {
        Scrollable.ensureVisible(
          _saveButtonKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text(l10n.snackbarFillAllFields),
        ),
      );
      return;
    }

    if (_dateMode != DateSelectionMode.range &&
        (_selectedGalleryItemContent == null ||
            _selectedGalleryItemContent!.isEmpty)) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text(l10n.snackbarAddImage),
        ),
      );
      return;
    }

    if (selectedMembers.isEmpty) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text(l10n.snackbarSelectParticipants),
        ),
      );
      return;
    }

    DateTime eventDate;

    try {
      if (_dateMode == DateSelectionMode.range && _selectedDateRange != null) {
        // Use start of range for eventDate
        eventDate = _selectedDateRange!.start;
      } else {
        final dateParts = _dateController.text.split('-');
        final year = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final day = int.parse(dateParts[2]);

        if (_allDay) {
          eventDate = DateTime(year, month, day);
        } else {
          final timeParts = _timeController.text.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          eventDate = DateTime(year, month, day, hour, minute);
        }
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text(l10n.snackbarDateParseError),
        ),
      );
      return;
    }

    final String creatorId = widget.currentUser?.profilId ?? '';
    if (creatorId.isEmpty) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text(l10n.snackbarCreatorError),
        ),
      );
      return;
    }

    final String descriptionToSave =
        _descriptionController.text.isEmpty ? '' : _descriptionController.text;

    final String urlToSave = _selectedGalleryItemContent ?? '';

    final initialEvent = SingleEvent(
      singleEventId: _uuid.v4(),
      singleEventName: _titleController.text,
      singleEventLocation: _locationController.text,
      singleEventDate: eventDate,
      singleEventUrl: urlToSave,
      singleEventDescription: descriptionToSave,
      groupId: widget.currentGroup?.groupId ?? 'personal_events',
      creatorId: creatorId,
      acceptedMemberIds: selectedMembers.toList(),
      invitedMemberIds: [],
      maybeMemberIds: [],
      declinedMemberIds: [],
      isAllDay: _allDay,
      hasReminder: _reminder,
      reminderOffset: _reminder ? _selectedReminder : null,
      // Markierungsdaten für Bereichs-Termine
      selectedDateRange:
          _dateMode == DateSelectionMode.range ? _selectedDateRange : null,
      selectedRangeColorValue: _dateMode == DateSelectionMode.range
          ? _selectedRangeColor.value
          : null,
      selectedMemberIds: _dateMode == DateSelectionMode.range
          ? selectedMembers.toList()
          : null,
    );
    debugPrint('*** DEBUGGING EVENT ERSTELLUNG ***');
    debugPrint('Ersteller ID (creatorId): ${initialEvent.creatorId}');
    debugPrint('Gruppen ID des Events (groupId): ${initialEvent.groupId}');
    debugPrint('Ist widget.currentGroup null? ${widget.currentGroup == null}');
    if (widget.currentGroup != null) {
      debugPrint(
          'widget.currentGroup.groupId: ${widget.currentGroup!.groupId}');
      if (widget.currentUser != null) {
        debugPrint(
            'widget.currentGroup.userRoles[currentUserId]: ${widget.currentGroup!.userRoles[widget.currentUser!.profilId]}');
      } else {
        debugPrint(
            'widget.currentUser ist null, kann userRoles nicht abrufen.');
      }
    } else {
      debugPrint(
          'currentGroup oder currentUser ist null, kann Rollen nicht prüfen.');
    }
    debugPrint('*** ENDE DEBUGGING EVENT ERSTELLUNG ***');

    try {
      if (_repeat) {
        await _generateAndSaveRecurringEvents(initialEvent);
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaCyan,
            content: Text(l10n.snackbarRecurringEventSaved),
          ),
        );
      } else {
        await widget.db.createEvent(initialEvent);
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaCyan,
            content: Text(l10n.snackbarSingleEventSaved),
          ),
        );
      }
      // Nach erfolgreichem Speichern: Navigiere zum CalendarScreen und übergebe die Markierungs-Parameter
      if (_dateMode == DateSelectionMode.range &&
          _selectedDateRange != null &&
          selectedMembers.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CalendarScreen(
              widget.db,
              currentGroup: widget.currentGroup!,
              currentUser: widget.currentUser!,
              auth: widget.auth,
              selectedDateRange: _selectedDateRange,
              selectedRangeColor: _selectedRangeColor,
              selectedMemberIds: selectedMembers.toList(),
            ),
          ),
        );
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text('Fehler beim Speichern des Termins: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ...existing code...
    // Pass selectedMembers to CalendarGrid
    // Example usage (add where CalendarGrid is instantiated):
    /*
    CalendarGrid(
      widget.db,
      auth: widget.auth,
      currentGroup: widget.currentGroup,
      currentUser: widget.currentUser,
      allEvents: [], // or your events list
      selectedDateRange: _selectedDateRange,
      selectedRangeColor: _selectedRangeColor,
      selectedMemberIds: selectedMembers.toList(),
    )
    */
    Row(
      children: [
        Expanded(
          child: RadioListTile<DateSelectionMode>(
            title: Text('Einzelner Tag'),
            value: DateSelectionMode.single,
            groupValue: _dateMode,
            onChanged: (val) => setState(() => _dateMode = val!),
          ),
        ),
        Expanded(
          child: RadioListTile<DateSelectionMode>(
            title: Text('Zeitraum'),
            value: DateSelectionMode.range,
            groupValue: _dateMode,
            onChanged: (val) => setState(() => _dateMode = val!),
          ),
        ),
      ],
    );
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.famkaWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeadlineK(screenHead: l10n.appointmentTitle),
            Expanded(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (widget.currentUser != null)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            l10n.createdByUser(widget.currentUser!.firstName),
                          ),
                        ),
                      if (widget.currentGroup != null)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            l10n.forGroup(widget.currentGroup!.groupName),
                          ),
                        ),
                      AppTextField(
                        leftIcon: Icons.sort,
                        controller: _titleController,
                        label: l10n.appointmentTitleLabel,
                        hint: l10n.appointmentTitleHint,
                        validator: _validateTitle,
                      ),
                      // Radio-Button-Row für Datumsauswahl
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<DateSelectionMode>(
                              title: Text('Einzelner Tag'),
                              value: DateSelectionMode.single,
                              groupValue: _dateMode,
                              onChanged: (val) =>
                                  setState(() => _dateMode = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<DateSelectionMode>(
                              title: Text('Zeitraum'),
                              value: DateSelectionMode.range,
                              groupValue: _dateMode,
                              onChanged: (val) =>
                                  setState(() => _dateMode = val!),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          AppTextField(
                            leftIcon: Icons.calendar_today,
                            controller: _dateController,
                            label: l10n.dateLabel,
                            hint: l10n.dateHint,
                            validator: (value) =>
                                validateAppointmentDate(value, context),
                            readOnly: true,
                            onTap: () async {
                              if (_dateMode == DateSelectionMode.single) {
                                final DateTime? picked =
                                    await selectAppointmentDate(
                                  context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _dateController.text =
                                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                  });
                                }
                              } else {
                                final DateTimeRange? pickedRange =
                                    await selectAppointmentDateRange(
                                  context,
                                  initialStartDate: DateTime.now(),
                                  initialEndDate: DateTime.now()
                                      .add(const Duration(days: 1)),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedRange != null) {
                                  setState(() {
                                    _selectedDateRange = pickedRange;
                                    _dateController.text =
                                        "${pickedRange.start.year}-${pickedRange.start.month.toString().padLeft(2, '0')}-${pickedRange.start.day.toString().padLeft(2, '0')} bis "
                                        "${pickedRange.end.year}-${pickedRange.end.month.toString().padLeft(2, '0')}-${pickedRange.end.day.toString().padLeft(2, '0')}";
                                  });
                                }
                              }
                            },
                          ),
                          if (_dateMode == DateSelectionMode.range)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: _buildRangeColorPicker(),
                            ),
                        ],
                      ),
                      AppSwitchRow(
                        leftIcon: Icons.timer_outlined,
                        label: l10n.allDayLabel,
                        value: _allDay,
                        onChanged: _dateMode == DateSelectionMode.range
                            ? (val) {}
                            : (val) => setState(() => _allDay = val),
                      ),
                      if (!_allDay)
                        Column(
                          children: [
                            AppTextField(
                              leftIcon: Icons.access_time,
                              controller: _timeController,
                              label: l10n.startTimeLabel,
                              hint: l10n.timeHint,
                              validator: (value) => validateAppointmentTime(
                                  value, _allDay, context),
                              readOnly: true,
                              onTap: () async {
                                final TimeOfDay? pickedTime =
                                    await time_picker.selectAppointmentTime(
                                  context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (pickedTime != null) {
                                  setState(() {
                                    _timeController.text =
                                        pickedTime.format(context);
                                  });
                                }
                              },
                            ),
                            AppTextField(
                              leftIcon: Icons.access_time_outlined,
                              controller: _endTimeController,
                              label: l10n.endTimeLabel,
                              hint: l10n.timeHint,
                              validator: (value) => validateAppointmentTime(
                                  value, _allDay, context),
                              readOnly: true,
                              onTap: () async {
                                final TimeOfDay? pickedTime =
                                    await time_picker.selectAppointmentTime(
                                  context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (pickedTime != null) {
                                  setState(() {
                                    _endTimeController.text =
                                        pickedTime.format(context);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      AppTextField(
                        leftIcon: Icons.location_on,
                        controller: _locationController,
                        label: l10n.locationLabel,
                        hint: l10n.locationHint,
                        validator: _validateLocation,
                        enabled: _dateMode != DateSelectionMode.range,
                      ),
                      GallerySelectionField(
                        db: widget.db,
                        initialSelectedContent: _selectedGalleryItemContent,
                        onChanged: _dateMode == DateSelectionMode.range
                            ? (newContent) {}
                            : (newContent) {
                                setState(() {
                                  _selectedGalleryItemContent = newContent;
                                });
                              },
                        auth: widget.auth,
                        enabled: _dateMode != DateSelectionMode.range,
                      ),
                      EventParticipantsSelector(
                        groupMembersFuture: _groupMembersFuture,
                        initialSelectedMembers: selectedMembers,
                        onSelectedMembersChanged: (newSelectedMembers) {
                          setState(() {
                            selectedMembers = newSelectedMembers;
                          });
                        },
                      ),
                      if (_selectedRepeat != null && _selectedReminder != null)
                        RepeatReminderSettings(
                          initialRepeat: _repeat,
                          onRepeatChanged: _dateMode == DateSelectionMode.range
                              ? (val) {}
                              : (val) {
                                  setState(() {
                                    _repeat = val;
                                  });
                                },
                          initialSelectedRepeat: _selectedRepeat ?? '',
                          onSelectedRepeatChanged:
                              _dateMode == DateSelectionMode.range
                                  ? (val) {}
                                  : (val) {
                                      setState(() {
                                        _selectedRepeat = val;
                                      });
                                    },
                          numberOfRepeatsController: _numberOfRepeatsController,
                          validateNumberOfRepeats: _validateNumberOfRepeats,
                          onNumberOfRepeatsChanged: _dateMode ==
                                  DateSelectionMode.range
                              ? (value) {}
                              : (value) {
                                  setState(() {
                                    _numberOfRepeats = int.tryParse(value) ?? 1;
                                  });
                                },
                          initialReminder: _reminder,
                          onReminderChanged:
                              _dateMode == DateSelectionMode.range
                                  ? (val) {}
                                  : (val) {
                                      setState(() {
                                        _reminder = val;
                                      });
                                    },
                          initialSelectedReminder: _selectedReminder ?? '',
                          onSelectedReminderChanged:
                              _dateMode == DateSelectionMode.range
                                  ? (val) {}
                                  : (val) {
                                      setState(() {
                                        _selectedReminder = val;
                                      });
                                    },
                          enabled: _dateMode != DateSelectionMode.range,
                        ),
                      AppTextField(
                        leftIcon: Icons.description,
                        controller: _descriptionController,
                        label: l10n.descriptionLabel,
                        hint: l10n.descriptionHint,
                        validator: _validateDescription,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 20),
                      SaveAppointmentButton(
                        key: _saveButtonKey,
                        onSave: _createAndSaveAppointment,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationThreeCalendar(
        widget.db,
        currentUser: widget.currentUser,
        initialGroup: widget.currentGroup,
        initialIndex: 2,
        auth: widget.auth,
      ),
    );
  }
}
