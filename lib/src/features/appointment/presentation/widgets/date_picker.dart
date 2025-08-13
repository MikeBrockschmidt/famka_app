import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/providers/locale_provider.dart';
import 'package:provider/provider.dart';

Future<DateTime?> selectAppointmentDate(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    locale: localeProvider.locale,
    builder: (context, child) {
      final theme = Theme.of(context);
      final textTheme = theme.textTheme;

      return Theme(
        data: theme.copyWith(
          dialogBackgroundColor: AppColors.famkaWhite,
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.famkaWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            elevation: 8.0,
            alignment: Alignment.center,
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
              foregroundColor: AppColors.famkaBlue,
              textStyle: textTheme.labelLarge?.copyWith(
                fontSize: 14.0,
                color: AppColors.famkaBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          textTheme: textTheme.copyWith(
            titleLarge: textTheme.titleLarge?.copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.famkaBlack,
            ),
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
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8.0,
          backgroundColor: AppColors.famkaWhite,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: BoxConstraints(
              maxWidth: 360,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: child,
          ),
        ),
      );
    },
  );
  return picked;
}
