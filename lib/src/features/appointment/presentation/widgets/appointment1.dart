import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import 'package:famka_app/src/features/appointment/presentation/widgets/appointment_form_fields.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/event_participants_selector.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/gallery_selection_field.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/repeat_reminder_settings.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/save_appointment_button.dart';

class Appointment extends StatefulWidget {
  final DatabaseRepository db;
  final AppUser? currentUser;
  final Group? currentGroup;

  const Appointment(
    this.db, {
    super.key,
    this.currentUser,
    this.currentGroup,
  });

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
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

  String _selectedRepeat = 'Täglich';
  String _selectedReminder = '1 Stunde';

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
    if (value == null || value.isEmpty) {
      return 'Bitte Titel eingeben';
    }
    if (value.length > 80) {
      return 'Maximal 80 Zeichen erlaubt';
    }
    final RegExp emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true);
    if (emojiRegex.hasMatch(value)) {
      return 'Keine Emojis erlaubt';
    }
    return null;
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte Datum auswählen';
    }
    return null;
  }

  String? _validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte Zeit eingeben';
    }
    final parts = value.split(':');
    if (parts.length != 2) {
      return 'Zeit muss im Format HH:MM sein';
    }
    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      if (hour < 0 || hour > 23) {
        return 'Stunden müssen zwischen 00 und 23 liegen';
      }
      if (minute < 0 || minute > 59) {
        return 'Minuten müssen zwischen 00 und 59 liegen';
      }
    } catch (e) {
      return 'Zeit muss im Format HH:MM sein';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte Standort eingeben';
    }
    final RegExp allowedChars = RegExp(r'^[a-zA-ZäöüÄÖÜß\s\d.,\-()\/]+$');
    if (!allowedChars.hasMatch(value)) {
      return 'Unerlaubte Zeichen im Standort';
    }
    if (value.isNotEmpty && !RegExp(r'^[A-ZÄÖÜ]').hasMatch(value[0])) {
      return 'Erster Buchstabe muss groß sein';
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
    if (value == null || value.isEmpty) {
      return 'Bitte Anzahl eingeben';
    }
    final count = int.tryParse(value);
    if (count == null || count <= 0) {
      return 'Ungültige Anzahl (muss > 0 sein)';
    }
    if (count > 365) {
      return 'Max. 365 Wiederholungen';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('de'),
      builder: (context, child) {
        final bodySmallStyle = Theme.of(context).textTheme.bodySmall;
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              bodyLarge: bodySmallStyle,
              bodyMedium: bodySmallStyle,
              bodySmall: bodySmallStyle,
              titleMedium: bodySmallStyle,
              labelSmall: bodySmallStyle,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
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
        switch (_selectedRepeat) {
          case 'Täglich':
            nextEventDate = currentEventDate.add(const Duration(days: 1));
            break;
          case 'Wöchentlich':
            nextEventDate = currentEventDate.add(const Duration(days: 7));
            break;
          case 'Monatlich':
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
          case 'Jährlich':
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
        singleEventEndTime: initialEvent.singleEventEndTime != null
            ? DateTime(
                currentEventDate.year,
                currentEventDate.month,
                currentEventDate.day,
                initialEvent.singleEventEndTime!.hour,
                initialEvent.singleEventEndTime!.minute,
              )
            : null,
        attendingUsers: initialEvent.attendingUsers,
        singleEventUrl: initialEvent.singleEventUrl,
        description: initialEvent.description,
        groupId: initialEvent.groupId,
        repeatOption: initialEvent.repeatOption,
        reminderOption: initialEvent.reminderOption,
        numberOfRepeats: initialEvent.numberOfRepeats,
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text('Bitte füllen Sie alle Felder korrekt aus.'),
        ),
      );
      return;
    }

    if (_selectedGalleryItemContent == null ||
        _selectedGalleryItemContent!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text('Bitte geben Sie Ihrem Event ein Gesicht.'),
        ),
      );
      return;
    }

    if (selectedMembers.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text(
              'Für wen ist der Termin? Bitte wählen Sie mindestens einen Teilnehmer aus.'),
        ),
      );
      return;
    }

    DateTime eventDate;
    DateTime? eventEndTime;

    try {
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

        if (_endTimeController.text.isNotEmpty) {
          final endTimeParts = _endTimeController.text.split(':');
          final endHour = int.parse(endTimeParts[0]);
          final endMinute = int.parse(endTimeParts[1]);
          eventEndTime = DateTime(year, month, day, endHour, endMinute);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text('Fehler beim Parsen von Datum oder Zeit.'),
        ),
      );
      return;
    }

    final initialEvent = SingleEvent(
      singleEventId: _uuid.v4(),
      singleEventName: _titleController.text,
      singleEventLocation: _locationController.text,
      singleEventDate: eventDate,
      singleEventEndTime: eventEndTime,
      attendingUsers: selectedMembers.toList(),
      singleEventUrl: _selectedGalleryItemContent ?? '',
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      groupId: widget.currentGroup?.groupId ?? 'personal_events',
      repeatOption: _repeat ? _selectedRepeat : null,
      reminderOption: _reminder ? _selectedReminder : null,
      numberOfRepeats: _repeat ? _numberOfRepeats : null,
    );

    try {
      if (_repeat) {
        await _generateAndSaveRecurringEvents(initialEvent);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.famkaCyan,
            content: Text('Terminserie gespeichert!'),
          ),
        );
      } else {
        await widget.db.createEvent(initialEvent);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.famkaCyan,
            content: Text('Termin gespeichert!'),
          ),
        );
      }
      Navigator.of(context).pop(true);
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeadlineK(screenHead: 'Termin'),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (widget.currentUser != null)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                              'Erstellt von: ${widget.currentUser!.firstName}'),
                        ),
                      if (widget.currentGroup != null)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                              'Für Gruppe: ${widget.currentGroup!.groupName}'),
                        ),
                      AppTextField(
                        leftIcon: Icons.sort,
                        controller: _titleController,
                        label: 'Titel des Termins',
                        hint: 'Titel des Termins',
                        validator: _validateTitle,
                      ),
                      AppTextField(
                        leftIcon: Icons.calendar_today,
                        controller: _dateController,
                        label: 'Datum',
                        hint: 'YYYY-MM-DD',
                        validator: _validateDate,
                        readOnly: true,
                        onTap: () {
                          _selectDate(context);
                        },
                      ),
                      AppSwitchRow(
                        leftIcon: Icons.timer_outlined,
                        label: 'Ganzer Tag',
                        value: _allDay,
                        onChanged: (val) => setState(() => _allDay = val),
                      ),
                      if (!_allDay)
                        Column(
                          children: [
                            AppTextField(
                              leftIcon: Icons.access_time,
                              controller: _timeController,
                              label: 'Startzeit',
                              hint: 'HH:MM',
                              validator: _validateTime,
                              keyboardType: TextInputType.datetime,
                            ),
                            AppTextField(
                              leftIcon: Icons.access_time_outlined,
                              controller: _endTimeController,
                              label: 'Endzeit',
                              hint: 'HH:MM',
                              validator: _validateTime,
                              keyboardType: TextInputType.datetime,
                            ),
                          ],
                        ),
                      AppTextField(
                        leftIcon: Icons.location_on,
                        controller: _locationController,
                        label: 'Standort',
                        hint: 'Ort des Termins',
                        validator: _validateLocation,
                      ),
                      GallerySelectionField(
                        db: widget.db,
                        initialSelectedContent: _selectedGalleryItemContent,
                        onChanged: (newContent) {
                          setState(() {
                            _selectedGalleryItemContent = newContent;
                          });
                        },
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
                      RepeatReminderSettings(
                        initialRepeat: _repeat,
                        onRepeatChanged: (val) {
                          setState(() {
                            _repeat = val;
                          });
                        },
                        initialSelectedRepeat: _selectedRepeat,
                        onSelectedRepeatChanged: (val) {
                          setState(() {
                            _selectedRepeat = val;
                          });
                        },
                        numberOfRepeatsController: _numberOfRepeatsController,
                        validateNumberOfRepeats: _validateNumberOfRepeats,
                        onNumberOfRepeatsChanged: (value) {
                          setState(() {
                            _numberOfRepeats = int.tryParse(value) ?? 1;
                          });
                        },
                        initialReminder: _reminder,
                        onReminderChanged: (val) {
                          setState(() {
                            _reminder = val;
                          });
                        },
                        initialSelectedReminder: _selectedReminder,
                        onSelectedReminderChanged: (val) {
                          setState(() {
                            _selectedReminder = val;
                          });
                        },
                      ),
                      AppTextField(
                        leftIcon: Icons.description,
                        controller: _descriptionController,
                        label: 'Beschreibung',
                        hint: 'Details zum Termin (optional)',
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
      ),
    );
  }
}
