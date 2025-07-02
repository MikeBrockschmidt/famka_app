import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';

const List<String> _mockAvatarPaths = [
  'assets/fotos/Mike.jpg',
  'assets/fotos/Melanie.jpg',
  'assets/fotos/Max.jpg',
  'assets/fotos/Martha.jpg',
  'assets/fotos/boyd.jpg',
  'assets/fotos/default.jpg',
];

class ProfilImage extends StatelessWidget {
  final DatabaseRepository db;
  final String? currentAvatarUrl;
  final ValueChanged<String>? onAvatarSelected;

  const ProfilImage(this.db,
      {super.key, this.currentAvatarUrl, this.onAvatarSelected});

  Future<void> _showAvatarSelectionDialog(BuildContext context) async {
    final String? selectedPath = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Theme(
          data: Theme.of(context),
          child: Builder(
            builder: (BuildContext innerContext) {
              return AlertDialog(
                title: const Text('Avatar auswählen'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: _mockAvatarPaths.map((path) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(innerContext, path);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.famkaGreen,
                                backgroundImage: AssetImage(path),
                              ),
                              const SizedBox(width: 10),
                              Text(path.split('/').last.split('.').first),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (selectedPath != null && onAvatarSelected != null) {
      onAvatarSelected!(selectedPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String effectiveAvatarUrl = (currentAvatarUrl == null ||
            currentAvatarUrl!.isEmpty ||
            currentAvatarUrl == 'assets/images/default_group_avatar.png')
        ? 'assets/fotos/default.jpg'
        : currentAvatarUrl!;

    return Transform.translate(
      offset: const Offset(0, -20),
      child: GestureDetector(
        onTap: () => _showAvatarSelectionDialog(context),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: AppColors.famkaGreen,
              backgroundImage: AssetImage(effectiveAvatarUrl),
            ),
            const Icon(
              Icons.image,
              size: 48,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
