import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('de'); // Default to German

  Locale get locale => _locale;
  bool get isGerman => _locale.languageCode == 'de';
  bool get isEnglish => _locale.languageCode == 'en';

  LocaleProvider() {
    _loadSavedLocale();
  }

  // Lade gespeicherte Sprache beim App-Start
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) async {
    if (_locale != locale) {
      _locale = locale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      notifyListeners();
    }
  }

  void toggleLanguage() {
    if (isGerman) {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('de'));
    }
  }
}
