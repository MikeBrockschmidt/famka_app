import 'package:flutter/material.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

class SaveButton extends StatelessWidget {
  final bool hasChanges;
  final VoidCallback onSave;

  const SaveButton({
    super.key,
    required this.hasChanges,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
      child: Align(
        alignment: Alignment.center,
        child: Opacity(
          opacity: hasChanges ? 1.0 : 0.5,
          child: InkWell(
            onTap: hasChanges ? onSave : null,
            child: SizedBox(
              width: 150,
              height: 50,
              child: ButtonLinearGradient(
                buttonText: l10n.saveButtonText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
