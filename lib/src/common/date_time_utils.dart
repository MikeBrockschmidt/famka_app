import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<String?> selectAndFormatDate(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final DateTime effectiveInitialDate = initialDate ?? DateTime.now();
  final DateTime effectiveFirstDate = firstDate ?? DateTime(1900);
  final DateTime effectiveLastDate = lastDate ?? DateTime(2101);

  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: effectiveInitialDate,
    firstDate: effectiveFirstDate,
    lastDate: effectiveLastDate,
    locale: const Locale('de', ''),
    builder: (BuildContext builderContext, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1E3A8A),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1E3A8A),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (pickedDate != null) {
    return DateFormat('yyyy-MM-dd').format(pickedDate);
  }
  return null;
}

DateTime? parseDateString(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }
  try {
    return DateFormat('yyyy-MM-dd').parseStrict(dateString);
  } catch (e) {
    return null;
  }
}
