import 'package:flutter/material.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';

class SaveAppointmentButton extends StatelessWidget {
  const SaveAppointmentButton({
    super.key,
    required this.onSave,
  });

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onSave,
            child: const ButtonLinearGradient(buttonText: 'Speichern'),
          ),
        ],
      ),
    );
  }
}
