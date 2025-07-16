import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/auth_repository.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ItemType { emoji, icon, image, addPhoto }

class Gallery extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;

  const Gallery(this.db, {super.key, required this.auth});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final List<GalleryItem> fixedThumbnails = const [
    GalleryItem(
      type: ItemType.image,
      imageUrl: 'assets/hintergruende/thumbnail1.jpg',
      content: 'image:assets/hintergruende/thumbnail1.jpg',
    ),
    GalleryItem(
      type: ItemType.image,
      imageUrl: 'assets/hintergruende/thumbnail2.jpg',
      content: 'image:assets/hintergruende/thumbnail2.jpg',
    ),
  ];

  final List<GalleryItem> _uploadedImages = [];
  bool _isPickingImage = false;

  static const String _imagePathsKey = 'uploadedImagePaths';

  late List<GalleryItem> galleryData;

  @override
  void initState() {
    super.initState();
    _loadUploadedImages().then((_) {
      _updateGalleryData();
    });
  }

  Future<void> _loadUploadedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedPaths = prefs.getStringList(_imagePathsKey);

    if (storedPaths != null) {
      final List<GalleryItem> loadedItems = [];
      for (String path in storedPaths) {
        final file = File(path);
        if (await file.exists()) {
          loadedItems.add(GalleryItem(
              type: ItemType.image, imageUrl: path, content: 'image:$path'));
        } else {
          print('Warnung: Gespeicherte Bilddatei nicht gefunden: $path');
        }
      }
      setState(() {
        _uploadedImages.addAll(loadedItems);
      });
    }
  }

  Future<void> _saveUploadedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> pathsToSave = _uploadedImages
        .where((item) =>
            item.imageUrl != null && !item.imageUrl!.startsWith('assets/'))
        .map((item) => item.imageUrl!)
        .toList();
    await prefs.setStringList(_imagePathsKey, pathsToSave);
  }

  Future<void> _deleteImage(GalleryItem itemToDelete) async {
    if (itemToDelete.type != ItemType.image ||
        itemToDelete.imageUrl == null ||
        itemToDelete.imageUrl!.startsWith('assets/')) {
      return;
    }

    final bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            final TextTheme textTheme = Theme.of(context).textTheme;
            final Color famkaBlue = AppColors.famkaBlue;

            return AlertDialog(
              title: Text(
                'Bild löschen?',
                style: textTheme.labelMedium?.copyWith(color: famkaBlue),
              ),
              content: Text(
                'Möchten Sie dieses Bild wirklich aus der Galerie entfernen? Diese Aktion kann nicht rückgängig gemacht werden.',
                style: textTheme.labelSmall?.copyWith(color: famkaBlue),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Abbrechen',
                    style: textTheme.labelMedium?.copyWith(color: famkaBlue),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Löschen',
                    style: textTheme.labelMedium?.copyWith(color: famkaBlue),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmDelete) {
      try {
        final File file = File(itemToDelete.imageUrl!);
        if (await file.exists()) {
          await file.delete();
          print('Bilddatei gelöscht: ${itemToDelete.imageUrl}');
        }

        setState(() {
          _uploadedImages.remove(itemToDelete);
          _updateGalleryData();
        });
        await _saveUploadedImages();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bild erfolgreich gelöscht.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Löschen des Bildes: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _updateGalleryData() {
    final List<GalleryItem> dynamicData = List.generate(
      80,
      (index) {
        if (index % 3 == 0) {
          final imagePaths = [
            'assets/fotos/Mike.jpg',
            'assets/fotos/Martha.jpg',
            'assets/fotos/Max.jpg',
            'assets/fotos/boyd.jpg',
            'assets/fotos/Familie.jpg',
          ];
          return GalleryItem(
            type: ItemType.image,
            imageUrl: imagePaths[index % imagePaths.length],
            content: 'image:${imagePaths[index % imagePaths.length]}',
          );
        } else if (index % 3 == 1) {
          final icons = [
            Icons.sports_basketball,
            Icons.sports_tennis,
            Icons.directions_bike,
            Icons.snowboarding,
            Icons.directions_run,
            Icons.pool,
            Icons.fitness_center,
            Icons.sports_soccer,
            Icons.sports_handball,
            Icons.kitesurfing,
            Icons.paragliding,
            Icons.sports_mma,
          ];
          return GalleryItem(
            type: ItemType.icon,
            iconData: icons[index % icons.length],
            content: 'icon:${icons[index % icons.length].codePoint}',
          );
        } else {
          final emojis = [
            '⚽️',
            '🏀',
            '🎾',
            '🏸',
            '🥎',
            '🏐',
            '🏓',
            '⛷️',
            '🚴',
            '🏃‍♂️',
            '🤾‍♀️',
            '🏇',
            '🏂',
            '🏌️‍♂️',
            '🤸‍♂️',
            '🧘‍♀️',
            '🛹',
            '🛼',
            '🎿',
            '🤼‍♂️',
            '🤽‍♂️',
            '🪂',
            '🤺',
            '🧗‍♀️',
            '🏄‍♂️',
            '🚣‍♀️',
            '🚵‍♂️',
            '🏊‍♂️',
            '🏹',
            '🛷',
            '🧊',
            '🚤',
            '🪁',
            '🥋',
            '⛳️',
            '🛶',
            '🪃',
            '🏋️‍♂️',
            '🏉',
            '🥌',
          ];
          return GalleryItem(
            type: ItemType.emoji,
            content: 'emoji:${emojis[index % emojis.length]}',
          );
        }
      },
    );
    setState(() {
      galleryData = [
        const GalleryItem(type: ItemType.addPhoto),
        ..._uploadedImages,
        ...fixedThumbnails,
        ...dynamicData,
      ];
    });
  }

  Future<void> _pickImageAndAddToGallery() async {
    setState(() {
      _isPickingImage = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Aus Galerie wählen'),
                  onTap: () {
                    Navigator.pop(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Foto aufnehmen'),
                  onTap: () {
                    Navigator.pop(context, ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );

      if (source == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bildauswahl abgebrochen.')),
          );
        }
        return;
      }

      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Bild zuschneiden',
                toolbarColor: Theme.of(context).colorScheme.primary,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true),
            IOSUiSettings(
              title: 'Bild zuschneiden',
              aspectRatioLockEnabled: true,
            ),
          ],
        );

        if (croppedFile != null) {
          final appDocDir = await getApplicationDocumentsDirectory();
          final String fileName =
              '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final String permanentPath = '${appDocDir.path}/$fileName';
          final File newImage =
              await File(croppedFile.path).copy(permanentPath);
          final String localPath = newImage.path;

          setState(() {
            _uploadedImages.insert(
                0,
                GalleryItem(
                    type: ItemType.image,
                    imageUrl: localPath,
                    content: 'image:$localPath'));
            _updateGalleryData();
          });
          await _saveUploadedImages();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Bild zur Galerie hinzugefügt (zugeschnitten & gespeichert).')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zuschneiden abgebrochen.')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Fehler bei der Bildauswahl oder beim Zuschneiden: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 1,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 80,
            width: double.infinity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: HeadlineK(screenHead: 'Piktogramme'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.builder(
                itemCount: galleryData.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final item = galleryData[index];

                  return GestureDetector(
                    onTap: () {
                      if (item.type == ItemType.addPhoto) {
                        if (!_isPickingImage) {
                          _pickImageAndAddToGallery();
                        }
                      } else {
                        Navigator.pop(context, item.content);
                      }
                    },
                    onLongPress: () {
                      if (item.type == ItemType.image &&
                          item.imageUrl != null &&
                          !item.imageUrl!.startsWith('assets/')) {
                        _deleteImage(item);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: item.type == ItemType.addPhoto
                            ? AppColors.famkaYellow
                            : Colors.white,
                        border: Border.all(
                          color: AppColors.famkaYellow,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Builder(
                          builder: (innerContext) {
                            if (item.type == ItemType.addPhoto) {
                              return Center(
                                child: _isPickingImage
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      )
                                    : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 36,
                                            color: AppColors.famkaGreen,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Foto hinzufügen',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.famkaGreen),
                                          ),
                                        ],
                                      ),
                              );
                            } else if (item.type == ItemType.emoji &&
                                item.content != null &&
                                item.content!.startsWith('emoji:')) {
                              return Center(
                                child: Text(
                                  item.content!.substring(6),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    color: AppColors.famkaGreen,
                                    fontFamilyFallback: [
                                      'Apple Color Emoji',
                                      'Noto Color Emoji',
                                      'Segoe UI Emoji',
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            } else if (item.type == ItemType.icon &&
                                item.iconData != null) {
                              return Center(
                                child: Icon(
                                  item.iconData,
                                  size: 48,
                                  color: AppColors.famkaGreen,
                                ),
                              );
                            } else if (item.type == ItemType.image &&
                                item.imageUrl != null) {
                              if (item.imageUrl!.startsWith('assets/')) {
                                return Image.asset(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.broken_image,
                                          size: 48, color: Colors.red),
                                    );
                                  },
                                );
                              } else {
                                return Image.file(
                                  File(item.imageUrl!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.broken_image,
                                          size: 48, color: Colors.red),
                                    );
                                  },
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationThreeCalendar(
        widget.db,
        auth: widget.auth,
      ),
    );
  }
}

class GalleryItem {
  final ItemType type;
  final String? content;
  final IconData? iconData;
  final String? imageUrl;

  const GalleryItem({
    required this.type,
    this.content,
    this.iconData,
    this.imageUrl,
  });
}
