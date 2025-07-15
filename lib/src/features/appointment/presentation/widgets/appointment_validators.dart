String? validateAppointmentDate(String? value) {
  if (value == null || value.isEmpty) {
    return 'Bitte ein Datum auswählen';
  }

  final dateParts = value.split('-');
  if (dateParts.length != 3) {
    return 'Ungültiges Datum';
  }

  try {
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);

    final selectedDate = DateTime(year, month, day);
    if (selectedDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Datum darf nicht in der Vergangenheit liegen';
    }
  } catch (e) {
    return 'Ungültiges Datum';
  }

  return null;
}
