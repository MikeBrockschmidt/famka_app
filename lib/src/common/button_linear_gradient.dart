import 'package:flutter/material.dart';

class ButtonLinearGradient extends StatelessWidget {
  final String buttonText;

  const ButtonLinearGradient({
    super.key,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6DC0), Color(0xFFFFA95C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromARGB(10, 216, 215, 215).withAlpha(51),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9375B6).withAlpha(128),
            blurRadius: 90,
            offset: const Offset(0, 90),
          ),
        ],
      ),
      child: Text(
        buttonText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
