import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';

class MenuSubContainer1LinesLanguage extends StatefulWidget {
  const MenuSubContainer1LinesLanguage({super.key});

  @override
  State<MenuSubContainer1LinesLanguage> createState() =>
      _MenuSubContainer1LinesLanguageState();
}

class _MenuSubContainer1LinesLanguageState
    extends State<MenuSubContainer1LinesLanguage> {
  bool _isEnglish = false; // Zustand für den Schalter

  @override
  void initState() {
    super.initState();
    // Initialen Zustand basierend auf der aktuellen App-Sprache setzen
    _isEnglish = Localizations.localeOf(context).languageCode == 'en';
  }

  void _toggleLanguage(bool value) {
    setState(() {
      _isEnglish = value;
    });
    // Hier müsste die Logik zum tatsächlichen Wechseln der Sprache hin.
    // Dies erfordert, dass Sie die Sprache der MaterialApp dynamisch ändern können.
    // Normalerweise geschieht das über einen Provider oder einen Notifier.
    // Fürs Erste können wir hier einen Debug-Print einfügen.
    debugPrint('Sprache gewechselt zu: ${value ? 'Englisch' : 'Deutsch'}');

    // Um die Sprache tatsächlich zu ändern, müssten Sie den Locale der MaterialApp
    // von einem übergeordneten Widget aus steuern, z.B. über einen ValueNotifier
    // oder ein State-Management-Paket wie Provider/Riverpod.
    // Beispiel (nur zur Veranschaulichung, nicht direkt hier implementierbar):
    // MyApp.setLocale(context, value ? const Locale('en') : const Locale('de'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          thickness: 1,
          height: 1,
          color: Colors.grey,
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            top: 12.0,
            left: 20.0,
            bottom: 14.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.famkaCyan,
                child: const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.languageSettingTitle, // Neuer Lokalisierungsschlüssel
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      _isEnglish
                          ? l10n.languageEnglish
                          : l10n
                              .languageGerman, // Neuer Lokalisierungsschlüssel
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isEnglish,
                onChanged: _toggleLanguage,
                activeColor: AppColors.famkaGreen,
                inactiveThumbColor: AppColors.famkaRed,
                inactiveTrackColor: AppColors.famkaRed.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
