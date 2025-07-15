import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/image_utils.dart';

class SingleEventAvatar extends StatelessWidget {
  final bool isSelected;
  final String avatarUrl;

  const SingleEventAvatar({
    super.key,
    required this.isSelected,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.famkaRed : Colors.white,
          width: 3,
        ),
      ),
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.4,
        child: CircleAvatar(
          radius: 26,
          backgroundImage: getDynamicImageProvider(avatarUrl) ??
              const AssetImage('assets/fotos/default.jpg'),
          backgroundColor: Colors.transparent,
          onBackgroundImageError: (exception, stackTrace) {
            debugPrint(
                'Fehler beim Laden des Avatars in SingleEventAvatar: $exception');
          },
        ),
      ),
    );
  }
}
