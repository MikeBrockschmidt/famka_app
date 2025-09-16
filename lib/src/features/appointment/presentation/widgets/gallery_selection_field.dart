import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/gallery1.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

// Mapping von Icon-Namen zu Material-Icons
const Map<String, IconData> galleryIconMap = {
  'calendar': Icons.calendar_today,
  'person': Icons.person,
  'group': Icons.group,
  'star': Icons.star,
  'favorite': Icons.favorite,
  'work': Icons.work,
  'school': Icons.school,
  'pets': Icons.pets,
  'music': Icons.music_note,
  'sports': Icons.sports_soccer,
  'travel': Icons.flight,
  'shopping': Icons.shopping_cart,
  'food': Icons.restaurant,
  'home': Icons.home,
  'settings': Icons.settings,
  'lock': Icons.lock,
  'map': Icons.map,
  'phone': Icons.phone,
  'email': Icons.email,
  // ...weitere Zuordnungen nach Bedarf
};

class GallerySelectionField extends StatefulWidget {
  const GallerySelectionField({
    super.key,
    required this.db,
    this.initialSelectedContent,
    required this.onChanged,
    required this.auth,
    this.enabled = true,
  });

  final DatabaseRepository db;
  final String? initialSelectedContent;
  final ValueChanged<String?> onChanged;
  final AuthRepository auth;
  final bool enabled;

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

    if (_selectedGalleryItemContent!.startsWith('http://') ||
        _selectedGalleryItemContent!.startsWith('https://')) {
      return Image.network(
        _selectedGalleryItemContent!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.red);
        },
      );
    } else if (_selectedGalleryItemContent!.startsWith('emoji:')) {
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
      final iconName = _selectedGalleryItemContent!.substring(5);
      final iconData = galleryIconMap[iconName] ?? Icons.help_outline;
      return Center(
        child: Icon(
          iconData,
          size: 28,
          color: AppColors.famkaGreen,
        ),
      );
    } else if (_selectedGalleryItemContent!.startsWith('image:')) {
      final imageUrl = _selectedGalleryItemContent!.substring(6);
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.red);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _openGallery() async {
    if (!widget.enabled) return;
    final selectedContent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Gallery(
          widget.db,
          auth: widget.auth,
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
    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: widget.enabled ? _openGallery : null,
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
                      AppLocalizations.of(context)!.addImageTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.black),
                    ),
                  ),
                  if (_selectedGalleryItemContent != null &&
                      _selectedGalleryItemContent!.isNotEmpty)
                    GestureDetector(
                      onTap: widget.enabled ? _openGallery : null,
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
                  AppLocalizations.of(context)!.addImageDescription,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
