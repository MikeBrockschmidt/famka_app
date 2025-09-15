import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/common/image_utils.dart';

class ProfilImage3 extends StatelessWidget {
  final DatabaseRepository db;
  final String avatarUrl;
  final Function(String)? onAvatarChanged;

  const ProfilImage3({
    super.key,
    required this.db,
    required this.avatarUrl,
    this.onAvatarChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object>? currentImageProvider =
        getDynamicImageProvider(avatarUrl);

    final Widget defaultAvatarWidget = Icon(
      Icons.person,
      size: 80,
      color: Colors.grey.shade600,
    );

    return InkWell(
      onTap: () {
        if (onAvatarChanged != null) {
          onAvatarChanged!(avatarUrl);
        }
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade300,
        ),
        child: ClipOval(
          child: (currentImageProvider != null)
              ? Image(
                  image: currentImageProvider,
                  fit: BoxFit.cover,
                  width: 140,
                  height: 140,
                  errorBuilder: (context, error, stackTrace) {
                    // ...existing code...
                    return defaultAvatarWidget;
                  },
                )
              : defaultAvatarWidget,
        ),
      ),
    );
  }
}
