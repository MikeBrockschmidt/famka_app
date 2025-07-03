import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';

Future<DateTime?> selectAppointmentDate(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    locale: const Locale('de'),
    builder: (context, child) {
      final theme = Theme.of(context);
      final textTheme = theme.textTheme;

      return Theme(
        data: theme.copyWith(
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors
                .famkaWhite, // <- ersetzt deprecated dialogBackgroundColor
          ),
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
              foregroundColor: AppColors.famkaBlue, // „Abbrechen“ & „OK“
              textStyle: textTheme.labelLarge?.copyWith(
                fontSize: 14.0,
                color: AppColors.famkaBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          textTheme: textTheme.copyWith(
            bodyLarge: textTheme.bodyLarge?.copyWith(
              fontSize: 14.0,
              color: AppColors.famkaBlack,
            ),
            bodyMedium: textTheme.bodyMedium?.copyWith(
              fontSize: 13.0,
              color: AppColors.famkaBlack,
            ),
            bodySmall: textTheme.bodySmall?.copyWith(
              fontSize: 12.0,
              color: AppColors.famkaBlack,
            ),
            titleMedium: textTheme.titleMedium?.copyWith(
              fontSize: 14.0,
              color: AppColors.famkaBlack,
            ),
            labelSmall: textTheme.labelSmall?.copyWith(
              fontSize: 12.0,
              color: AppColors.famkaBlack,
            ),
            labelLarge: textTheme.labelLarge?.copyWith(
              fontSize: 14.0,
              color: AppColors.famkaBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child: child!,
      );
    },
  );
  return picked;
}
