import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/theme/font_theme.dart';
import 'package:famka_app/src/providers/locale_provider.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<DateTime?> selectAppointmentDate(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  // Capture all context-dependent data before async gap
  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  final themeData = Theme.of(context);
  final colorScheme = themeData.colorScheme.copyWith(
    primary: AppColors.famkaCyan,
    onPrimary: AppColors.famkaWhite,
    surface: AppColors.famkaWhite,
    onSurface: AppColors.famkaBlack,
  );
  final textTheme = appTheme.textTheme;
  final locale = localeProvider.locale.languageCode;

  await initializeDateFormatting('de_DE');

  DateTime selectedDate = initialDate;
  StateSetter? headerSetState;
  final completer = Completer<DateTime?>();

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Theme(
          data: themeData.copyWith(
            colorScheme: colorScheme,
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.famkaWhite,
            ),
            textTheme: textTheme,
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: AppColors.famkaWhite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                StatefulBuilder(
                  builder:
                      (BuildContext headerContext, StateSetter setHeaderState) {
                    headerSetState = setHeaderState;
                    String formattedDate = "";
                    if (locale == 'de') {
                      String dayName =
                          DateFormat('EEEE', 'de_DE').format(selectedDate);
                      dayName = dayName.substring(0, 1).toUpperCase() +
                          dayName.substring(1);
                      formattedDate = "$dayName, ${selectedDate.day}.";
                    } else {
                      String dayName =
                          DateFormat('EEEE', 'en_US').format(selectedDate);
                      formattedDate = "$dayName, ${selectedDate.day}";
                    }
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        color: AppColors.famkaCyan,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      child: Text(
                        formattedDate,
                        textAlign: TextAlign.center,
                        style: appTheme.textTheme.titleLarge?.copyWith(
                          color: AppColors.famkaWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SFProDisplay',
                        ),
                      ),
                    );
                  },
                ),
                CalendarDatePicker(
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onDateChanged: (DateTime date) {
                    selectedDate = date;
                    headerSetState?.call(() {});
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            completer.complete(null);
                          },
                          child: Text(
                            'Abbrechen',
                            style: TextStyle(
                              color: AppColors.famkaGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(dialogContext);
                            completer.complete(selectedDate);
                          },
                          child: ButtonLinearGradient(
                            buttonText: 'OK',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return completer.future;
  }
  return Future.value(null);
}
