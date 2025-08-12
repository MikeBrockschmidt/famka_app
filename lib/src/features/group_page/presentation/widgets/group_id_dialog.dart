import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

class GroupIdDialog extends StatelessWidget {
  final String groupName;
  final String groupId;

  const GroupIdDialog({
    super.key,
    required this.groupName,
    required this.groupId,
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
            l10n.shareGroupIdInstruction,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          SelectableText(
            groupId,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.famkaCyan,
                ),
          ),
        ],
      ),
      actions: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: groupId));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.groupIdCopied),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: ButtonLinearGradient(
                  buttonText: l10n.copyButton,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.closeButton,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
