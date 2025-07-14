import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';

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
          const Text(
            'Teilen Sie diese ID, um andere zur Gruppe einzuladen:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
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
                    const SnackBar(
                      content: Text('Gruppen-ID kopiert!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const ButtonLinearGradient(buttonText: 'Kopieren'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Schließen',
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
