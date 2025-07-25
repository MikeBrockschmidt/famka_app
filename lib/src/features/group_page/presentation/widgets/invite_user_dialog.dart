import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';

class InviteUserDialog extends StatefulWidget {
  final Function(String inviteeProfileId) onInvite;

  const InviteUserDialog({
    super.key,
    required this.onInvite,
  });

  @override
  State<InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends State<InviteUserDialog> {
  final TextEditingController _inviteeIdController = TextEditingController();

  @override
  void dispose() {
    _inviteeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Gebe die Profil-ID des Benutzers ein, den du hinzufügen möchtes:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inviteeIdController,
            decoration: InputDecoration(
              hintText: 'Profil-ID des Benutzers',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      actions: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final String inviteeProfileId =
                      _inviteeIdController.text.trim();
                  if (inviteeProfileId.isNotEmpty) {
                    Navigator.of(context).pop();
                    widget.onInvite(inviteeProfileId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.famkaRed,
                        content: Text(
                          'Bitte geben Sie eine Profil-ID ein.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  }
                },
                child: const ButtonLinearGradient(buttonText: 'Hinzufügen'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Abbrechen',
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
