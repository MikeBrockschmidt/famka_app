import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/event_image.dart';

class EventIconWidget extends StatelessWidget {
  final String? eventUrl;
  final String eventName;
  final double size;
  final dynamic db;

  const EventIconWidget({
    Key? key,
    required this.eventUrl,
    required this.eventName,
    required this.size,
    this.db,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (eventUrl == null || eventUrl!.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey.shade200,
        child: Center(
          child: Text(
            eventName,
            textAlign: TextAlign.center,
            maxLines: 6,
            overflow: TextOverflow.clip,
            softWrap: true,
            style: const TextStyle(
              fontSize: 11,
              height: 1.1,
              color: AppColors.famkaBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    if (eventUrl!.startsWith('emoji:')) {
      final emoji = eventUrl!.substring(6);
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          emoji,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
          ),
        ),
      );
    } else if (eventUrl!.startsWith('icon:')) {
      final iconCodePoint = int.tryParse(eventUrl!.substring(5));
      if (iconCodePoint != null) {
        return Icon(
          Icons.category,
          size: size * 0.9,
          color: AppColors.famkaBlack,
        );
      }
    } else if (eventUrl!.startsWith('image:')) {
      final imageUrl = eventUrl!.substring(6);
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.contain,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image,
                size: size * 0.7, color: Colors.red);
          },
        );
      } else {
        return Image.asset(
          imageUrl,
          fit: BoxFit.contain,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image,
                size: size * 0.7, color: Colors.red);
          },
        );
      }
    }
    return EventImage(
      db,
      currentAvatarUrl: eventUrl,
      displayRadius: size / 2,
      applyTransformOffset: false,
      isInteractive: false,
    );
  }
}
