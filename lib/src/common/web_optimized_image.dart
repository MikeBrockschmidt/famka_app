import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebOptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const WebOptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ?? 
        Icon(Icons.image_not_supported, size: width ?? height ?? 50);
    }

    // Assets
    if (imageUrl!.startsWith('assets/')) {
      return Image.asset(
        imageUrl!,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? Icon(Icons.broken_image, size: width ?? height ?? 50),
      );
    }

    // Network images
    if (imageUrl!.startsWith('http')) {
      // Web-spezifische Implementierung mit besserer CORS-Behandlung
      return Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        headers: kIsWeb ? {
          'Accept': 'image/*',
          'Access-Control-Allow-Origin': '*',
        } : null,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? 
            SizedBox(
              width: width ?? 50,
              height: height ?? 50,
              child: const CircularProgressIndicator(strokeWidth: 2),
            );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Image load error: $error for URL: $imageUrl');
          // Fallback für CORS-Probleme
          return errorWidget ?? 
            Icon(Icons.broken_image, size: width ?? height ?? 50);
        },
      );
    }

    // Fallback
    return errorWidget ?? 
      Icon(Icons.image_not_supported, size: width ?? height ?? 50);
  }
}