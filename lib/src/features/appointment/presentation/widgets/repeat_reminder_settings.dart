import 'package:flutter/material.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/appointment_form_fields.dart';

class RepeatReminderSettings extends StatefulWidget {
  const RepeatReminderSettings({
    super.key,
    required this.initialRepeat,
    required this.onRepeatChanged,
    required this.initialSelectedRepeat,
    required this.onSelectedRepeatChanged,
    required this.numberOfRepeatsController,
    required this.validateNumberOfRepeats,
    required this.onNumberOfRepeatsChanged,
    required this.initialReminder,
    required this.onReminderChanged,
    required this.initialSelectedReminder,
    required this.onSelectedReminderChanged,
  });

  final bool initialRepeat;
  final ValueChanged<bool> onRepeatChanged;
  final String initialSelectedRepeat;
  final ValueChanged<String> onSelectedRepeatChanged;
  final TextEditingController numberOfRepeatsController;
  final FormFieldValidator<String> validateNumberOfRepeats;
  final ValueChanged<String> onNumberOfRepeatsChanged;

  final bool initialReminder;
  final ValueChanged<bool> onReminderChanged;
  final String initialSelectedReminder;
  final ValueChanged<String> onSelectedReminderChanged;

  @override
  State<RepeatReminderSettings> createState() => _RepeatReminderSettingsState();
}

class _RepeatReminderSettingsState extends State<RepeatReminderSettings> {
  late bool _repeat;
  late String _selectedRepeat;
  late bool _reminder;
  late String _selectedReminder;

  @override
  void initState() {
    super.initState();
    _repeat = widget.initialRepeat;
    _selectedRepeat = widget.initialSelectedRepeat;
    _reminder = widget.initialReminder;
    _selectedReminder = widget.initialSelectedReminder;
  }

  @override
  void didUpdateWidget(covariant RepeatReminderSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRepeat != oldWidget.initialRepeat) {
      _repeat = widget.initialRepeat;
    }
    if (widget.initialSelectedRepeat != oldWidget.initialSelectedRepeat) {
      _selectedRepeat = widget.initialSelectedRepeat;
    }
    if (widget.initialReminder != oldWidget.initialReminder) {
      _reminder = widget.initialReminder;
    }
    if (widget.initialSelectedReminder != oldWidget.initialSelectedReminder) {
      _selectedReminder = widget.initialSelectedReminder;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSwitchRow(
          leftIcon: Icons.repeat,
          label: 'Wiederholen',
          value: _repeat,
          onChanged: (val) {
            setState(() {
              _repeat = val;
            });
            widget.onRepeatChanged(val);
          },
        ),
        if (_repeat)
          Column(
            children: [
              AppDropdownRow(
                leftIcon: Icons.repeat_one,
                label: 'Wiederholung',
                value: _selectedRepeat,
                items: const [
                  'Täglich',
                  'Wöchentlich',
                  'Monatlich',
                  'Jährlich'
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedRepeat = val;
                    });
                    widget.onSelectedRepeatChanged(val);
                  }
                },
              ),
              AppTextField(
                leftIcon: Icons.exposure_plus_1,
                controller: widget.numberOfRepeatsController,
                label: 'Anzahl der Wiederholungen',
                hint: 'z.B. 5 (inkl. diesem Termin)',
                keyboardType: TextInputType.number,
                validator: widget.validateNumberOfRepeats,
                onChanged: (value) {
                  widget.onNumberOfRepeatsChanged(value);
                },
              ),
            ],
          ),
        AppSwitchRow(
          leftIcon: Icons.notifications,
          label: 'Erinnerung',
          value: _reminder,
          onChanged: (val) {
            setState(() {
              _reminder = val;
            });
            widget.onReminderChanged(val);
          },
        ),
        if (_reminder)
          AppDropdownRow(
            leftIcon: Icons.notifications_active,
            label: 'Erinnerung vor',
            value: _selectedReminder,
            items: const ['30 Minuten', '1 Stunde', '1 Tag'],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedReminder = val;
                });
                widget.onSelectedReminderChanged(val);
              }
            },
          ),
      ],
    );
  }
}
