import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';

Future<TimeOfDay?> selectAppointmentTime(
  BuildContext context, {
  required TimeOfDay initialTime,
}) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.famkaWhite,
          ),
          canvasColor: AppColors.famkaWhite,
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.famkaCyan,
                onPrimary: AppColors.famkaWhite,
                surface: AppColors.famkaWhite,
                onSurface: AppColors.famkaBlack,
                secondary: AppColors.famkaYellow,
                onSecondary: AppColors.famkaBlack,
              ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.famkaCyan,
            ),
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppColors.famkaWhite,
            dialBackgroundColor: AppColors.famkaWhite,
            hourMinuteTextColor: AppColors.famkaBlack,
            hourMinuteColor: AppColors.famkaYellow,
            dayPeriodColor: AppColors.famkaYellow,
            dayPeriodTextColor: AppColors.famkaBlack,
            dialHandColor: AppColors.famkaYellow,
            dialTextColor: AppColors.famkaBlack,
            entryModeIconColor: AppColors.famkaCyan,
          ),
          textTheme: Theme.of(context).textTheme.copyWith(
                displayLarge: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 48.0, color: AppColors.famkaBlack),
                headlineMedium: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 28.0, color: AppColors.famkaBlack),
                bodyLarge: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.famkaBlack),
                bodyMedium: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.famkaBlack),
                titleMedium: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.famkaBlack),
                labelSmall: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.famkaBlack),
                labelLarge: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontSize: 16.0, color: AppColors.famkaCyan),
              ),
        ),
        child: child!,
      );
    },
  );
  return picked;
}

String? validateAppointmentTime(String? value, bool isAllDay) {
  if (isAllDay) {
    return null;
  }
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
