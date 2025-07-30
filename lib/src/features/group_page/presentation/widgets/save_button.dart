import 'package:flutter/material.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: Align(
        alignment: Alignment.center,
        child: Opacity(
          opacity: hasChanges ? 1.0 : 0.5,
          child: InkWell(
            onTap: hasChanges ? onSave : null,
            child: const SizedBox(
              width: 150,
              height: 50,
              child: ButtonLinearGradient(
                buttonText: 'Speichern',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
