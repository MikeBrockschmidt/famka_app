import 'package:flutter/material.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

class EventDescriptionEditor extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing;
  final String currentDescription;
  final VoidCallback? onSave;
  final ValueChanged<String>? onSubmitted;

  const EventDescriptionEditor({
    super.key,
    required this.controller,
    required this.isEditing,
    required this.currentDescription,
    this.onSave,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return isEditing
        ? TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.editDescription,
              border: const OutlineInputBorder(),
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            onSubmitted: onSubmitted,
          )
        : Text(
            AppLocalizations.of(context)!.description(
                currentDescription.isNotEmpty
                    ? currentDescription
                    : AppLocalizations.of(context)!.noDescription),
            style: Theme.of(context).textTheme.bodyMedium,
          );
  }
}
