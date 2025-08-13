import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:famka_app/src/providers/locale_provider.dart';
import 'package:famka_app/src/theme/color_theme.dart';

class HeadlineK extends StatelessWidget {
  final String screenHead;
  final bool showLanguageSwitch;

  const HeadlineK({
    super.key,
    required this.screenHead,
    this.showLanguageSwitch = false,
  });

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    screenHead,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (showLanguageSwitch)
                  GestureDetector(
                    onTap: () {
                      localeProvider.toggleLanguage();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.famkaWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.famkaBlack,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localeProvider.isGerman ? 'DE' : 'EN',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.famkaBlack,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.language,
                            size: 14,
                            color: AppColors.famkaBlack,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(
            height: 0.5,
            thickness: 0.5,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
