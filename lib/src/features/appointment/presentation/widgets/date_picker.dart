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
  // Initialize date formatting for German locale
  await initializeDateFormatting('de_DE');

  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

  // Variable to track the currently selected date
  DateTime selectedDate = initialDate;
  // Format für den Header
  final locale = localeProvider.locale.languageCode;
  // Reference to the header's StateSetter
  StateSetter? headerSetState;

  // Create a completer to handle custom button actions
  final completer = Completer<DateTime?>();

  // Show the date picker dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.famkaCyan,
                onPrimary: AppColors.famkaWhite,
                surface: AppColors.famkaWhite,
                onSurface: AppColors.famkaBlack,
              ),
          dialogBackgroundColor: AppColors.famkaWhite,
          textTheme: appTheme.textTheme,
        ),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: AppColors.famkaWhite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Datum-Header
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setHeaderState) {
                  headerSetState = setHeaderState;

                  // Format the date based on the locale
                  String formattedDate = "";
                  if (locale == 'de') {
                    // For German, format day name and day number with dot
                    String dayName =
                        DateFormat('EEEE', 'de_DE').format(selectedDate);
                    // Capitalize first letter
                    dayName = dayName.substring(0, 1).toUpperCase() +
                        dayName.substring(1);
                    formattedDate = "$dayName, ${selectedDate.day}.";
                  } else {
                    // For English, format day name and day number
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
                  // Update the header to show the new date
                  if (headerSetState != null) {
                    headerSetState!(() {});
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                          Navigator.pop(context);
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
