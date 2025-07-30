import 'dart:io';
import 'package:flutter/material.dart';

class ProfilImageDisplay extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const ProfilImageDisplay({
    super.key,
    required this.imageUrl,
    this.radius = 70,
  });

  @override
  Widget build(BuildContext context) {
    final String effectiveUrl = (imageUrl == null || imageUrl!.isEmpty)
        ? 'assets/grafiken/famka-kreis.png'
        : imageUrl!;

    ImageProvider imageProvider;
    if (effectiveUrl.startsWith('http')) {
      imageProvider = NetworkImage(effectiveUrl);
    } else if (effectiveUrl.startsWith('assets/')) {
      imageProvider = AssetImage(effectiveUrl);
    } else if (File(effectiveUrl).existsSync()) {
      imageProvider = FileImage(File(effectiveUrl));
    } else {
      imageProvider = const AssetImage('assets/grafiken/famka-kreis.png');
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage: imageProvider,
    );
  }
}
