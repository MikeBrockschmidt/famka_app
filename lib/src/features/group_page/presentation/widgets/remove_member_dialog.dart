import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';

class RemoveMemberDialog extends StatelessWidget {
  final AppUser member;
  final VoidCallback onConfirm;

  const RemoveMemberDialog({
    super.key,
    required this.member,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.manageMembersRemoveTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.famkaBlack,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.manageMembersRemoveConfirmation(
              '${member.firstName} ${member.lastName}',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            '${member.firstName} ${member.lastName}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.famkaGrey,
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
                  Navigator.of(context).pop();
                  onConfirm();
                },
                child: ButtonLinearGradient(
                  buttonText: l10n.manageMembersRemoveConfirm,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.manageMembersRemoveCancel,
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
