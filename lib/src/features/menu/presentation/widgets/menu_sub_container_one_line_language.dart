import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:provider/provider.dart';
import 'package:famka_app/src/providers/locale_provider.dart';

class MenuSubContainer1LinesLanguage extends StatelessWidget {
  const MenuSubContainer1LinesLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.languageSettingTitle,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontSize: 18, // Schriftgröße reduziert
                                    height: 0.9, // Zeilenhöhe reduzieren
                                  ),
                          overflow: TextOverflow.ellipsis, // Vermeidet Umbrüche
                        ),
                        const SizedBox(
                            height: 2), // Reduzierter vertikaler Abstand
                        Text(
                          localeProvider.isEnglish
                              ? l10n.languageEnglish
                              : l10n.languageGerman,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: localeProvider.isEnglish,
                    onChanged: (value) => localeProvider.toggleLanguage(),
                    activeColor: AppColors.famkaCyan,
                    activeTrackColor: AppColors.famkaCyan.withOpacity(0.5),
                    inactiveThumbColor: AppColors.famkaWhite,
                    inactiveTrackColor: AppColors.famkaGrey,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
