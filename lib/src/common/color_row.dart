import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';

class ColorRow extends StatelessWidget {
  const ColorRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _ColorBandRow(color: AppColors.famkaPink),
        _ColorBandRow(color: AppColors.famkaBlue),
        _ColorBandRow(color: AppColors.famkaRed),
        _ColorBandRow(color: AppColors.famkaCyan),
        _ColorBandRow(color: AppColors.famkaGreen),
        _ColorBandRow(color: AppColors.famkaYellow),
      ],
    );
  }
}

class _ColorBandRow extends StatelessWidget {
  final Color color;

  const _ColorBandRow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: double.infinity,
      color: color,
    );
  }
}
