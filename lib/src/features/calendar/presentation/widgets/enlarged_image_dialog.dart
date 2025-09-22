import 'package:flutter/material.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/event_image.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/gallery1.dart';

class EnlargedImageDialog extends StatelessWidget {
  final String eventUrl;
  final String eventName;
  final SingleEvent event;
  final dynamic db;
  final Function(SingleEvent updatedEvent)? onEventUpdated;

  const EnlargedImageDialog({
    super.key,
    required this.eventUrl,
    required this.eventName,
    required this.event,
    required this.db,
    this.onEventUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black54,
            ),
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.famkaBlue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            eventName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () async {
                            final selected = await Navigator.of(context).push<String>(
                              MaterialPageRoute(
                                builder: (context) => Gallery(
                                  db,
                                  auth: db.auth,
                                ),
                              ),
                            );
                            if (selected != null && selected.isNotEmpty) {
                              String newUrl;
                              if (selected.startsWith('icon:') || selected.startsWith('emoji:')) {
                                newUrl = selected;
                              } else if (selected.startsWith('image:')) {
                                newUrl = selected;
                              } else {
                                newUrl = 'image:$selected';
                              }
                              final updatedEvent = event.copyWith(
                                singleEventUrl: newUrl,
                              );
                              await db.updateEvent(updatedEvent.groupId, updatedEvent);
                              if (onEventUpdated != null) {
                                onEventUpdated!(updatedEvent);
                              }
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Bild erfolgreich geändert!')),
                              );
                            }
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                          tooltip: 'Bild bearbeiten',
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: _buildEnlargedImageWidget(eventUrl, db),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnlargedImageWidget(String eventUrl, dynamic db) {
    if (eventUrl.startsWith('icon:')) {
      final codePoint = int.tryParse(eventUrl.substring(5));
      if (codePoint != null) {
        return Center(
          child: CircleAvatar(
            radius: 75,
            backgroundColor: Colors.grey[200],
            child: Icon(
              IconData(codePoint, fontFamily: 'MaterialIcons'),
              size: 120,
              color: Colors.blueAccent,
            ),
          ),
        );
      }
      // Fallback falls CodePoint nicht geparst werden kann
      return const Center(
        child: Icon(Icons.broken_image, size: 64, color: Colors.red),
      );
    } else if (eventUrl.startsWith('emoji:')) {
      final emoji = eventUrl.substring(6);
      return Center(
        child: CircleAvatar(
          radius: 75,
          backgroundColor: Colors.grey[200],
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 100),
          ),
        ),
      );
    } else if (eventUrl.startsWith('image:')) {
      final actualImageUrl = eventUrl.substring(6);
      if (actualImageUrl.startsWith('http://') || actualImageUrl.startsWith('https://')) {
        return EventImage(
          db,
          currentAvatarUrl: actualImageUrl,
          displayRadius: 150,
          applyTransformOffset: false,
          isInteractive: false,
        );
      } else {
        return Image.asset(
          actualImageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 64, color: Colors.red),
                SizedBox(height: 8),
                Text("Image could not be loaded"),
              ],
            );
          },
        );
      }
    } else {
      return EventImage(
        db,
        currentAvatarUrl: eventUrl,
        displayRadius: 150,
        applyTransformOffset: false,
        isInteractive: false,
      );
    }
  }
}
