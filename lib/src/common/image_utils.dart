import 'package:flutter/material.dart';
import 'dart:io';
import 'package:famka_app/src/theme/color_theme.dart';

ImageProvider<Object>? getDynamicImageProvider(String? url) {
  if (url == null || url.isEmpty) {
    return null;
  }
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return NetworkImage(url);
  } else if (url.startsWith('assets/')) {
    return AssetImage(url);
  } else {
    final file = File(url);
    if (file.existsSync()) {
      return FileImage(file);
    } else {
      return null;
    }
  }
}

class DynamicAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double radius;
  final IconData fallbackIcon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;

  const DynamicAvatar({
    super.key,
    this.avatarUrl,
    this.radius = 28,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
    this.iconColor = const Color(0xFF757575),
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object>? imageProvider =
        getDynamicImageProvider(avatarUrl);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.famkaGrey,
      backgroundImage: imageProvider,
      onBackgroundImageError: (exception, stackTrace) {
        // ...existing code...
        // Fehler beim Laden des DynamicAvatar-Bildes
      },
      child: imageProvider == null
          ? Icon(
              fallbackIcon,
              size: iconSize,
              color: iconColor,
            )
          : null,
    );
  }
}
