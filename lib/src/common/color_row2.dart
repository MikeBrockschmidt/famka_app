import 'package:flutter/material.dart';

class ColorRow2 extends StatelessWidget {
  const ColorRow2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        // _ColorBandRow(color: Color(0xFFFF63C8), height: 20),
        // _ColorBandRow(color: Color(0xFF4779C8), height: 20),
        // _ColorBandRow(color: Color(0xFFFF4647), height: 20),
        _ColorBandRow(color: Color(0xFF32BDE6), height: 20),
        _ColorBandRow(color: Color(0xFF2C6464), height: 20),
        _ColorBandRow(color: Color(0xFFFFD301), height: 90),
      ],
    );
  }
}

class _ColorBandRow extends StatelessWidget {
  final Color color;
  final double height;

  const _ColorBandRow({
    required this.color,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: color,
    );
  }
}
