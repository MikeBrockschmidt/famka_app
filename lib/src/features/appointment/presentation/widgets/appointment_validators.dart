import 'package:flutter/material.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

String? validateAppointmentDate(String? value, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  if (value == null || value.isEmpty) {
    return l10n.validateDateEmpty;
  }

  final dateParts = value.split('-');
  if (dateParts.length != 3) {
    return l10n.validateDateInvalid;
  }

  try {
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);

    final selectedDate = DateTime(year, month, day);
    if (selectedDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return l10n.validateDateInPast;
    }
  } catch (e) {
    return l10n.validateDateInvalid;
  }

  return null;
}

String? validateAppointmentTime(
    String? value, bool isAllDay, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  if (!isAllDay) {
    if (value == null || value.isEmpty) {
      return l10n.validateTimeEmpty;
    }

    final timeParts = value.split(':');
    if (timeParts.length != 2) {
      return l10n.validateTimeInvalid;
    }

    try {
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return l10n.validateTimeInvalid;
      }
    } catch (e) {
      return l10n.validateTimeInvalid;
    }
  }
  return null;
}
