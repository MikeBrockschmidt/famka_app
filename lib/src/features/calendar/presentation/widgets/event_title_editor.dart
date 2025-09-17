import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';

class EventTitleEditor extends StatelessWidget {
  final String title;
  final bool isEditing;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;

  const EventTitleEditor({
    super.key,
    required this.title,
    required this.isEditing,
    this.controller,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return isEditing && controller != null
        ? TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Titel bearbeiten',
              border: OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.famkaBlue),
            onSubmitted: onSubmitted,
          )
        : Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.famkaBlue),
          );
  }
}
