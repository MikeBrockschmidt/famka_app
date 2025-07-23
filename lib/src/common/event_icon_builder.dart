import 'package:famka_app/src/features/gallery/presentation/widgets/event_image.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';

/// Universelle Methode zum Erzeugen eines Event-Icons (Emoji, Icon, Asset, Firebase-Bild)
Widget buildEventIcon({
  required DatabaseRepository db,
  required String? eventUrl,
  required String eventName,
  required double size,
}) {
  if (eventUrl == null || eventUrl.isEmpty) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey.shade300,
      child: Text(
        eventName.isNotEmpty ? eventName[0] : '?',
        style: TextStyle(fontSize: size / 2),
      ),
    );
  } else if (eventUrl.startsWith('emoji:')) {
    final emoji = eventUrl.replaceFirst('emoji:', '');
    return Text(
      emoji,
      style: TextStyle(fontSize: size),
    );
  } else if (eventUrl.startsWith('icon:')) {
    final codePoint = int.tryParse(eventUrl.replaceFirst('icon:', '')) ?? 0;
    return Icon(
      IconData(codePoint, fontFamily: 'MaterialIcons'),
      size: size,
    );
  } else if (eventUrl.startsWith('image:')) {
    final assetPath = eventUrl.replaceFirst('image:', '');
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  } else {
    return EventImage(
      db,
      currentAvatarUrl: eventUrl,
      displayRadius: size / 2,
      applyTransformOffset: false,
    );
  }
}
