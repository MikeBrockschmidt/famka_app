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

class GalleryItem {
  final ItemType type;
  final String? imageUrl;
  final IconData? iconData;
  final String? emoji;
  final String content;

  const GalleryItem({
    required this.type,
    this.imageUrl,
    this.iconData,
    this.emoji,
    required this.content,
  });
}

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
      if (mounted) {
        setState(() {
          _uploadedImages.addAll(loadedItems);
        });
      }
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
                    style: textTheme.labelMedium
                        ?.copyWith(color: AppColors.famkaRed),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmDelete) {
      try {
        final file = File(itemToDelete.imageUrl!);
        if (await file.exists()) {
          await file.delete();
        }
        if (mounted) {
          setState(() {
            _uploadedImages
                .removeWhere((item) => item.imageUrl == itemToDelete.imageUrl);
            _updateGalleryData();
          });
        }
        await _saveUploadedImages();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.famkaCyan,
              content: Text('Bild erfolgreich gelöscht.'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.famkaRed,
              content: Text('Fehler beim Löschen des Bildes: $e'),
            ),
          );
        }
      }
    }
  }

  void _updateGalleryData() {
    final List<GalleryItem> dynamicImages = List.generate(
      5,
      (index) {
        final imagePaths = [
          'assets/fotos/Mike.jpg',
          'assets/fotos/Martha.jpg',
          'assets/fotos/Max.jpg',
          'assets/fotos/boyd.jpg',
          'assets/grafiken/famka-kreis.png',
        ];
        return GalleryItem(
          type: ItemType.image,
          imageUrl: imagePaths[index % imagePaths.length],
          content: 'image:${imagePaths[index % imagePaths.length]}',
        );
      },
    );

    final List<GalleryItem> dynamicIcons = List.generate(
      100,
      (index) {
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
          Icons.account_balance,
          Icons.alarm,
          Icons.attach_money,
          Icons.beach_access,
          Icons.bed,
          Icons.book,
          Icons.build,
          Icons.business,
          Icons.camera_alt,
          Icons.car_rental,
          Icons.celebration,
          Icons.child_friendly,
          Icons.cloud,
          Icons.computer,
          Icons.cookie,
          Icons.coronavirus,
          Icons.credit_card,
          Icons.deck,
          Icons.directions_bus,
          Icons.dinner_dining,
          Icons.diversity_3,
          Icons.drive_eta,
          Icons.edit,
          Icons.emoji_events,
          Icons.escalator_warning,
          Icons.favorite,
          Icons.feedback,
          Icons.flight,
          Icons.folder,
          Icons.forest,
          Icons.group,
          Icons.gavel,
          Icons.handyman,
          Icons.healing,
          Icons.headphones,
          Icons.help,
          Icons.home_work,
          Icons.hot_tub,
          Icons.icecream,
          Icons.keyboard,
          Icons.local_cafe,
          Icons.local_dining,
          Icons.local_florist,
          Icons.local_hospital,
          Icons.local_laundry_service,
          Icons.local_library,
          Icons.local_mall,
          Icons.local_movies,
          Icons.local_parking,
          Icons.local_pharmacy,
          Icons.local_pizza,
          Icons.local_post_office,
          Icons.local_shipping,
          Icons.location_on,
          Icons.lock,
          Icons.mail,
          Icons.map,
          Icons.medical_services,
          Icons.menu_book,
          Icons.mic,
          Icons.military_tech,
          Icons.monetization_on,
          Icons.money,
          Icons.more_horiz,
          Icons.motorcycle,
          Icons.movie,
          Icons.museum,
          Icons.music_note,
          Icons.nature,
          Icons.nightlight_round,
          Icons.no_food,
          Icons.park,
          Icons.pets,
          Icons.phone,
          Icons.photo_camera,
          Icons.pie_chart,
          Icons.place,
          Icons.play_arrow,
          Icons.psychology,
          Icons.public,
          Icons.qr_code,
          Icons.receipt,
          Icons.restaurant,
          Icons.school,
          Icons.science,
          Icons.security,
          Icons.self_improvement,
          Icons.send,
          Icons.settings,
          Icons.shopping_bag,
          Icons.show_chart,
          Icons.spa,
          Icons.stars,
          Icons.store,
          Icons.subway,
          Icons.supervised_user_circle,
          Icons.support,
          Icons.tag,
          Icons.taxi_alert,
          Icons.thumb_up,
          Icons.timeline,
          Icons.toys,
          Icons.traffic,
          Icons.train,
          Icons.tram,
          Icons.translate,
          Icons.trending_up,
          Icons.umbrella,
          Icons.vaccines,
          Icons.verified,
          Icons.video_call,
          Icons.volume_up,
          Icons.wallet,
          Icons.water,
          Icons.weekend,
          Icons.wifi,
          Icons.work,
          Icons.wine_bar,
          Icons.yard,
          Icons.zoom_in,
          Icons.zoom_out,
        ];
        return GalleryItem(
          type: ItemType.icon,
          iconData: icons[index % icons.length],
          content: 'icon:${icons[index % icons.length].codePoint.toString()}',
        );
      },
    );

    final List<GalleryItem> dynamicEmojis = List.generate(
      100,
      (index) {
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
          '🎉',
          '🎂',
          '🎁',
          '🎈',
          '🎊',
          '🎀',
          '🪄',
          '💖',
          '⭐',
          '✨',
          '🍎',
          '🍊',
          '🍋',
          '🍉',
          '🍇',
          '🍓',
          '🍒',
          '🍑',
          '🍍',
          '🥝',
          '🍕',
          '🍔',
          '🍟',
          '🍣',
          '🍜',
          '🍝',
          '🌮',
          '🍳',
          '🍩',
          '🍪',
          '☕',
          '🍵',
          '🥂',
          '🍻',
          '🥛',
          '🥤',
          '🍦',
          '🍫',
          '🍬',
          '🍭',
          '🏠',
          '🏢',
          '🏫',
          '🏥',
          '🏦',
          '🏪',
          '🏭',
          '🏛️',
          '🏰',
          '💒',
          '🚗',
          '🚕',
          '🚌',
          '🚃',
          '🚄',
          '🚂',
          '🚀',
          '✈️',
          '🚢',
          '⚓',
          '🐶',
          '🐱',
          '🐭',
          '🐹',
          '🐰',
          '🐻',
          '🐼',
          '🐨',
          '🐯',
          '🦁',
          '🌻',
          '🌹',
          '🌷',
          '🌸',
          '🌼',
          '🌳',
          '🌲',
          '🌴',
          '🌵',
          '🌾',
          '☀️',
          '☁️',
          '🌧️',
          '⛈️',
          '❄️',
          '🌈',
          '⚡',
          '🌬️',
          '🍂',
          '🍁',
          '📚',
          '📝',
          '📊',
          '📈',
          '📉',
          '⏰',
          '📆',
          '🗓️',
          '📍',
          '💡',
          '🎵',
          '🎶',
          '🎤',
          '🎧',
          '🎸',
          '🥁',
          '🎹',
          '🎷',
          '🎺',
          '🎻',
          '💻',
          '📱',
          '⌨️',
          '🖱️',
          '🖨️',
          '💾',
          '💿',
          '📞',
          '🔋',
          '🔌',
          '❤️',
          '🧡',
          '💛',
          '💚',
          '💙',
          '💜',
          '🤎',
          '🖤',
          '🤍',
          '💔',
          '😀',
          '😂',
          '😅',
          '😊',
          '😇',
          '🥰',
          '😍',
          '🤩',
          '😘',
          '😗',
          '🤫',
          '🤔',
          '🤗',
          '😬',
          '😮',
          '😴',
          '😷',
          '🤒',
          '🤕',
          '🤮',
        ];
        return GalleryItem(
          type: ItemType.emoji,
          emoji: emojis[index % emojis.length],
          content: 'emoji:${emojis[index % emojis.length]}',
        );
      },
    );

    if (mounted) {
      setState(() {
        galleryData = [
          const GalleryItem(type: ItemType.addPhoto, content: 'addPhoto'),
          ...fixedThumbnails,
          ..._uploadedImages,
          ...dynamicImages,
          ...dynamicIcons,
          ...dynamicEmojis,
        ];
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;

    if (mounted) {
      setState(() {
        _isPickingImage = true;
      });
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Bild zuschneiden',
                toolbarColor: AppColors.famkaBlue,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Bild zuschneiden',
            ),
          ],
        );

        if (croppedFile != null) {
          final directory = await getApplicationDocumentsDirectory();
          final String newPath =
              '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          final File newImage = await File(croppedFile.path).copy(newPath);

          if (mounted) {
            setState(() {
              _uploadedImages.add(GalleryItem(
                  type: ItemType.image,
                  imageUrl: newImage.path,
                  content: 'image:${newImage.path}'));
              _updateGalleryData();
            });
          }
          await _saveUploadedImages();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text('Fehler beim Auswählen/Zuschneiden des Bildes: $e'),
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGalleryItem(GalleryItem item) {
    return GestureDetector(
      onTap: () {
        if (item.type == ItemType.addPhoto) {
          _showImageSourceDialog();
        } else {
          Navigator.pop(context, item.content);
        }
      },
      onLongPress:
          item.type == ItemType.image && !item.imageUrl!.startsWith('assets/')
              ? () => _deleteImage(item)
              : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppColors.famkaYellow,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: _getImageWidget(item),
        ),
      ),
    );
  }

  Widget _getImageWidget(GalleryItem item) {
    switch (item.type) {
      case ItemType.image:
        if (item.imageUrl != null && item.imageUrl!.startsWith('assets/')) {
          return Image.asset(
            item.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 40,
                color: AppColors.famkaRed),
          );
        } else if (item.imageUrl != null) {
          return Image.file(
            File(item.imageUrl!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 40,
                color: AppColors.famkaRed),
          );
        }
        return const Icon(Icons.broken_image,
            size: 40, color: AppColors.famkaRed);
      case ItemType.emoji:
        return Center(
          child: Text(
            item.emoji!,
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
      case ItemType.icon:
        return Center(
          child: Icon(
            item.iconData!,
            size: 48,
            color: AppColors.famkaGreen,
          ),
        );
      case ItemType.addPhoto:
        return const Center(
          child: Icon(
            Icons.add_a_photo,
            size: 50,
            color: AppColors.famkaBlue,
          ),
        );
      default:
        return const Center(child: Text('Ungültig'));
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
            child: const Align(
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
                  return _buildGalleryItem(item);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationThreeCalendar(
        widget.db,
        currentUser: widget.db.currentUser,
        initialGroup: widget.db.currentGroup,
        initialIndex: 2,
        auth: widget.auth,
      ),
    );
  }
}
