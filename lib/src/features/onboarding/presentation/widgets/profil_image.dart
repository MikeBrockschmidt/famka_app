import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilImage extends StatefulWidget {
  final DatabaseRepository db;
  final String? currentAvatarUrl;
  final ValueChanged<String>? onAvatarSelected;

  const ProfilImage(this.db,
      {super.key, this.currentAvatarUrl, this.onAvatarSelected});

  @override
  State<ProfilImage> createState() => _ProfilImageState();
}

class _ProfilImageState extends State<ProfilImage> {
  String? _displayImageUrl;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _displayImageUrl = widget.currentAvatarUrl;
  }

  @override
  void didUpdateWidget(covariant ProfilImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAvatarUrl != oldWidget.currentAvatarUrl) {
      setState(() {
        _displayImageUrl = widget.currentAvatarUrl;
      });
    }
  }

  Future<void> _pickImageLocally() async {
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
        maxWidth: 200,
        maxHeight: 200,
      );

      if (pickedFile != null) {
        final String localPath = pickedFile.path;

        if (widget.onAvatarSelected != null) {
          widget.onAvatarSelected!(localPath);
        }
        setState(() {
          _displayImageUrl = localPath;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profilbild ausgewählt und lokal angezeigt.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kein Bild ausgewählt.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler bei der Bildauswahl: $e'),
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
    final String effectiveDisplayUrl =
        (_displayImageUrl == null || _displayImageUrl!.isEmpty)
            ? 'assets/fotos/default.jpg'
            : _displayImageUrl!;

    ImageProvider imageProvider;
    if (effectiveDisplayUrl.startsWith('http')) {
      imageProvider = NetworkImage(effectiveDisplayUrl);
    } else if (effectiveDisplayUrl.startsWith('assets/')) {
      imageProvider = AssetImage(effectiveDisplayUrl);
    } else {
      imageProvider = FileImage(File(effectiveDisplayUrl));
    }

    return Transform.translate(
      offset: const Offset(0, -20),
      child: GestureDetector(
        onTap: _isPickingImage ? null : _pickImageLocally,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: AppColors.famkaGreen,
              backgroundImage: imageProvider,
            ),
            if (_isPickingImage)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            else if (_displayImageUrl == null ||
                _displayImageUrl!.isEmpty ||
                _displayImageUrl!.startsWith('assets/fotos/default.jpg'))
              const Icon(
                Icons.camera_alt,
                size: 48,
                color: Colors.white70,
              ),
          ],
        ),
      ),
    );
  }
}
