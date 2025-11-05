import 'package:flutter/material.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/event_image.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/gallery1.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/rendering.dart';

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

  void _showSaveImageOptions(BuildContext context, String eventUrl) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bild speichern',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (eventUrl.startsWith('emoji:'))
                  ListTile(
                    leading: const Icon(Icons.content_copy, color: AppColors.famkaBlue),
                    title: const Text('Emoji in Zwischenablage kopieren'),
                    onTap: () {
                      final emoji = eventUrl.substring(6);
                      Clipboard.setData(ClipboardData(text: emoji));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Emoji in Zwischenablage kopiert!'),
                          backgroundColor: AppColors.famkaGreen,
                        ),
                      );
                    },
                  ),
                if (eventUrl.startsWith('image:') || (!eventUrl.startsWith('emoji:') && !eventUrl.startsWith('icon:')))
                  ListTile(
                    leading: const Icon(Icons.save_alt, color: AppColors.famkaBlue),
                    title: const Text('Bild speichern'),
                    subtitle: const Text('In Fotogalerie speichern'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _saveImageToGallery(context, eventUrl);
                    },
                  ),
                if (eventUrl.startsWith('icon:'))
                  ListTile(
                    leading: const Icon(Icons.info, color: AppColors.famkaGrey),
                    title: const Text('Icons können nicht gespeichert werden'),
                    subtitle: const Text('Icons sind bereits systemweit verfügbar'),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Abbrechen',
                        style: TextStyle(
                          color: AppColors.famkaGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveImageToGallery(BuildContext context, String eventUrl) async {
    try {
      // Berechtigungen prüfen
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          _showErrorSnackBar(context, 'Berechtigung für Speicher wurde verweigert');
          return;
        }
      }

      Uint8List imageBytes;
      String fileName = 'famka_image_${DateTime.now().millisecondsSinceEpoch}';

      if (eventUrl.startsWith('image:')) {
        final actualImageUrl = eventUrl.substring(6);
        
        if (actualImageUrl.startsWith('http://') || actualImageUrl.startsWith('https://')) {
          // Netzwerk-Bild herunterladen
          final response = await http.get(Uri.parse(actualImageUrl));
          if (response.statusCode == 200) {
            imageBytes = response.bodyBytes;
            fileName += '.jpg';
          } else {
            _showErrorSnackBar(context, 'Fehler beim Herunterladen des Bildes');
            return;
          }
        } else if (actualImageUrl.startsWith('assets/')) {
          // Asset-Bild laden
          final byteData = await rootBundle.load(actualImageUrl);
          imageBytes = byteData.buffer.asUint8List();
          fileName += actualImageUrl.contains('.png') ? '.png' : '.jpg';
        } else {
          // Lokale Datei
          final file = File(actualImageUrl);
          if (await file.exists()) {
            imageBytes = await file.readAsBytes();
            fileName += actualImageUrl.contains('.png') ? '.png' : '.jpg';
          } else {
            _showErrorSnackBar(context, 'Bilddatei nicht gefunden');
            return;
          }
        }
      } else {
        // Für normale Event-URLs (sollten als Bilder behandelt werden)
        if (eventUrl.startsWith('http://') || eventUrl.startsWith('https://')) {
          final response = await http.get(Uri.parse(eventUrl));
          if (response.statusCode == 200) {
            imageBytes = response.bodyBytes;
            fileName += '.jpg';
          } else {
            _showErrorSnackBar(context, 'Fehler beim Herunterladen des Bildes');
            return;
          }
        } else {
          _showErrorSnackBar(context, 'Bildformat wird nicht unterstützt');
          return;
        }
      }

      // Bild in Galerie speichern
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        name: fileName,
        quality: 100,
      );

      if (result['isSuccess'] == true) {
        _showSuccessSnackBar(context, 'Bild erfolgreich in Galerie gespeichert!');
      } else {
        _showErrorSnackBar(context, 'Fehler beim Speichern des Bildes');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Unerwarteter Fehler: $e');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.famkaGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.famkaRed,
        duration: const Duration(seconds: 4),
      ),
    );
  }

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
                            final selected =
                                await Navigator.of(context).push<String>(
                              MaterialPageRoute(
                                builder: (context) => Gallery(
                                  db,
                                  auth: db.auth,
                                ),
                              ),
                            );
                            if (selected != null && selected.isNotEmpty) {
                              String newUrl;
                              if (selected.startsWith('icon:') ||
                                  selected.startsWith('emoji:')) {
                                newUrl = selected;
                              } else if (selected.startsWith('image:')) {
                                newUrl = selected;
                              } else {
                                newUrl = 'image:$selected';
                              }
                              final updatedEvent = event.copyWith(
                                singleEventUrl: newUrl,
                              );
                              await db.updateEvent(
                                  updatedEvent.groupId, updatedEvent);
                              if (onEventUpdated != null) {
                                onEventUpdated!(updatedEvent);
                              }
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bild erfolgreich geändert!'),
                                  backgroundColor: AppColors.famkaGreen,
                                ),
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
                      child: GestureDetector(
                        onLongPress: () => _showSaveImageOptions(context, eventUrl),
                        child: _buildEnlargedImageWidget(eventUrl, db),
                      ),
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
      // Tree-shakable: Zeige ein festes Icon statt dynamisch
      return Center(
        child: CircleAvatar(
          radius: 75,
          backgroundColor: Colors.grey[200],
          child: Icon(
            Icons.category,
            size: 120,
            color: Colors.blueAccent,
          ),
        ),
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
      if (actualImageUrl.startsWith('http://') ||
          actualImageUrl.startsWith('https://')) {
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
