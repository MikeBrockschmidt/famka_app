import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';

enum ItemType { emoji, icon, image }

class Gallery extends StatefulWidget {
  final DatabaseRepository db;

  const Gallery(this.db, {super.key});

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

  late final List<GalleryItem> galleryData;

  @override
  void initState() {
    super.initState();
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
    galleryData = [...fixedThumbnails, ...dynamicData];
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
                      Navigator.pop(context, item.content);
                    },
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
                        child: Builder(
                          builder: (innerContext) {
                            if (item.type == ItemType.emoji &&
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
      bottomNavigationBar: BottomNavigationThreeCalendar(widget.db),
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
