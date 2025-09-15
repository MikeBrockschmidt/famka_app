import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';

class ConfirmDeleteMemberDialog extends StatelessWidget {
  final AppUser member;

  const ConfirmDeleteMemberDialog({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final memberName = "${member.firstName} ${member.lastName}";

    return AlertDialog(
      title: Text(
        "Mitglied entfernen",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.famkaBlack,
            ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            memberName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.famkaBlack,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Möchten Sie $memberName wirklich aus der Gruppe entfernen?",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    l10n.cancelButtonText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(true),
                  child: ButtonLinearGradient(
                    buttonText: "Entfernen",
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
