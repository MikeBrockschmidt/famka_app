import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

Future<TimeOfDay?> selectAppointmentTime(
  BuildContext context, {
  required TimeOfDay initialTime,
}) async {
  // Get the app's current locale for consistency
  // Note: showTimePicker doesn't have a locale parameter like showDatePicker

  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (context, child) {
      final theme = Theme.of(context);
      final textTheme = theme.textTheme;

      return Theme(
        data: theme.copyWith(
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.famkaWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            elevation: 8.0,
            // Make dialog more compact
            alignment: Alignment.center,
          ),
          canvasColor: AppColors.famkaWhite,
          colorScheme: theme.colorScheme.copyWith(
            primary: AppColors.famkaCyan,
            onPrimary: AppColors.famkaWhite,
            surface: AppColors.famkaWhite,
            onSurface: AppColors.famkaBlack,
            secondary: AppColors.famkaYellow,
            onSecondary: AppColors.famkaBlack,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.famkaBlue,
              textStyle: textTheme.labelLarge?.copyWith(
                fontSize: 14.0, // Smaller font size
                color: AppColors.famkaBlue,
                fontWeight: FontWeight.w600,
              ),
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
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            // Make time picker more compact
            hourMinuteShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            dayPeriodShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            dayPeriodBorderSide: const BorderSide(color: AppColors.famkaCyan),
            hourMinuteTextStyle: const TextStyle(
              fontSize: 40.0, // Smaller hour/minute text
              fontWeight: FontWeight.bold,
            ),
            dayPeriodTextStyle: const TextStyle(
              fontSize: 12.0, // Smaller AM/PM text
            ),
            helpTextStyle: const TextStyle(
              fontSize: 12.0, // Smaller help text
            ),
          ),
          textTheme: textTheme.copyWith(
            titleLarge: textTheme.titleLarge?.copyWith(
              fontSize: 16.0, // Smaller font size
              fontWeight: FontWeight.bold,
              color: AppColors.famkaBlack,
            ),
            bodyLarge: textTheme.bodyLarge?.copyWith(
              fontSize: 14.0, // Smaller font size
              color: AppColors.famkaBlack,
            ),
            bodyMedium: textTheme.bodyMedium?.copyWith(
              fontSize: 13.0, // Smaller font size
              color: AppColors.famkaBlack,
            ),
            bodySmall: textTheme.bodySmall?.copyWith(
              fontSize: 12.0, // Smaller font size
              color: AppColors.famkaBlack,
            ),
            titleMedium: textTheme.titleMedium?.copyWith(
              fontSize: 14.0, // Smaller font size
              color: AppColors.famkaBlack,
            ),
            labelSmall: textTheme.labelSmall?.copyWith(
              fontSize: 12.0, // Smaller font size
              color: AppColors.famkaBlack,
            ),
            labelLarge: textTheme.labelLarge?.copyWith(
              fontSize: 14.0, // Smaller font size
              color: AppColors.famkaBlack,
              fontWeight: FontWeight.w500,
            ),
            displayLarge: textTheme.displayLarge?.copyWith(
                fontSize: 40.0, // Smaller dial text
                color: AppColors.famkaBlack),
            headlineMedium: textTheme.headlineMedium?.copyWith(
                fontSize: 24.0, // Smaller headline
                color: AppColors.famkaBlack),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        // Create a compact window-like appearance
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8.0,
          backgroundColor: AppColors.famkaWhite,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85, // Limit width
            constraints: BoxConstraints(
              maxWidth: 340, // Maximum width for larger screens
              maxHeight:
                  MediaQuery.of(context).size.height * 0.6, // Limit height
            ),
            child: child,
          ),
        ),
      );
    },
  );
  return picked;
}

String? validateAppointmentTime(
    String? value, bool isAllDay, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  if (isAllDay) {
    return null;
  }
  if (value == null || value.isEmpty) {
    return l10n.validateTimeEmpty;
  }
  final parts = value.split(':');
  if (parts.length != 2) {
    return l10n.validateTimeInvalid;
  }
  try {
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return l10n.validateTimeInvalid;
    }
  } catch (e) {
    return l10n.validateTimeInvalid;
  }
  return null;
}
