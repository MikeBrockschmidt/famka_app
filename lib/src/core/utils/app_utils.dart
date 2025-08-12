import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime date, {String locale = 'de'}) {
    return DateFormat.yMMMd(locale).format(date);
  }

  static String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static DateTime? tryParse(String? dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  static bool isInPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }
}

class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#\$&*~]').hasMatch(password);
  }
}

class ImageUtils {
  static String getDefaultAvatarPath() {
    return 'assets/fotos/default.jpg';
  }

  static String? validateImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return getDefaultAvatarPath();
    }
    return url;
  }
}
