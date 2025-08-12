import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

class ConfirmDeleteGroupDialog extends StatelessWidget {
  final String groupName;

  const ConfirmDeleteGroupDialog({
    super.key,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            groupName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.famkaBlack,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.confirmDeleteAppointment(groupName),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: ButtonLinearGradient(
                  buttonText: l10n.deleteAppointment,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  l10n.cancelButtonText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
