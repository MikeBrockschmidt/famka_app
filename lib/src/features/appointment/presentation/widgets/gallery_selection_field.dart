import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/gallery1.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/data/auth_repository.dart'; // NEU: Import AuthRepository

class GallerySelectionField extends StatefulWidget {
  const GallerySelectionField({
    super.key,
    required this.db,
    this.initialSelectedContent,
    required this.onChanged,
    required this.auth, // NEU: AuthRepository als Parameter hinzugefügt
  });

  final DatabaseRepository db;
  final String? initialSelectedContent;
  final ValueChanged<String?> onChanged;
  final AuthRepository auth; // NEU: AuthRepository als Attribut hinzugefügt

  @override
  State<GallerySelectionField> createState() => _GallerySelectionFieldState();
}

class _GallerySelectionFieldState extends State<GallerySelectionField> {
  String? _selectedGalleryItemContent;

  @override
  void initState() {
    super.initState();
    _selectedGalleryItemContent = widget.initialSelectedContent;
  }

  @override
  void didUpdateWidget(covariant GallerySelectionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedContent != oldWidget.initialSelectedContent) {
      _selectedGalleryItemContent = widget.initialSelectedContent;
    }
  }

  Widget _buildSelectedGalleryItem() {
    if (_selectedGalleryItemContent == null ||
        _selectedGalleryItemContent!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_selectedGalleryItemContent!.startsWith('emoji:')) {
      final emoji = _selectedGalleryItemContent!.substring(6);
      return Center(
        child: Text(
          emoji,
          style: const TextStyle(
            fontSize: 28,
            color: AppColors.famkaGreen,
            fontFamilyFallback: [
              'Apple Color Emoji',
              'Noto Color Emoji',
              'Segoe UI Emoji',
            ],
          ),
        ),
      );
    } else if (_selectedGalleryItemContent!.startsWith('icon:')) {
      final iconCodePoint =
          int.tryParse(_selectedGalleryItemContent!.substring(5));
      if (iconCodePoint != null) {
        return Center(
          child: Icon(
            IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
            size: 28,
            color: AppColors.famkaGreen,
          ),
        );
      }
    } else if (_selectedGalleryItemContent!.startsWith('image:')) {
      final imageUrl = _selectedGalleryItemContent!.substring(6);
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _openGallery() async {
    final selectedContent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Gallery(
          widget.db,
          auth: widget.auth, // KORREKTUR: auth-Parameter übergeben
        ),
      ),
    );
    if (selectedContent != null && selectedContent is String) {
      setState(() {
        _selectedGalleryItemContent = selectedContent;
      });
      widget.onChanged(selectedContent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openGallery,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.image, color: Colors.black),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Foto oder Piktogramm hinzufügen',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.black),
                  ),
                ),
                if (_selectedGalleryItemContent != null &&
                    _selectedGalleryItemContent!.isNotEmpty)
                  GestureDetector(
                    onTap: _openGallery,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppColors.famkaYellow, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildSelectedGalleryItem(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 1),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                'Das ausgewählte Zeichen ersetzt in der Kalenderansicht den Titel des Termins.',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
