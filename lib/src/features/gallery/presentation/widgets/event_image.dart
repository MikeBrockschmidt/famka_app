import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/foundation.dart';

import 'package:famka_app/src/common/image_selection_context.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class EventImage extends StatefulWidget {
  final DatabaseRepository db;
  final String? currentAvatarUrl;
  final ValueChanged<String>? onAvatarSelected;
  final ImageSelectionContext contextType;
  final double? displayRadius;
  final bool applyTransformOffset;
  final bool isInteractive;

  const EventImage(
    this.db, {
    super.key,
    this.currentAvatarUrl,
    this.onAvatarSelected,
    this.contextType = ImageSelectionContext.profile,
    this.displayRadius,
    this.applyTransformOffset = true,
    this.isInteractive = false,
  });

  @override
  State<EventImage> createState() => _EventImageState();
}

class _EventImageState extends State<EventImage> {
  String? _displayImageUrl;
  bool _isPickingImage = false;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  final Map<ImageSelectionContext, List<String>> _predefinedAvatarsByContext = {
    ImageSelectionContext.profile: [
      'assets/grafiken/Familie.jpg',
      'assets/grafiken/mann.png',
      'assets/grafiken/frau.png',
      'assets/grafiken/frau-blau.png',
      'assets/fotos/boyd.jpg',
    ],
    ImageSelectionContext.group: [
      'assets/grafiken/Familie.jpg',
      'assets/grafiken/gruppe-blau.png',
      'assets/grafiken/gruppe-pink.png',
      'assets/grafiken/gruppe-gruen.png',
      'assets/grafiken/gruppe-rot.png',
    ],
    ImageSelectionContext.event: [
      // 'assets/fotos/birthday.jpg',
      // 'assets/fotos/party.jpg',
    ],
    ImageSelectionContext.other: [
      'assets/fotos/boyd.jpg',
    ],
  };

  @override
  void initState() {
    super.initState();
    _displayImageUrl = widget.currentAvatarUrl;
  }

  @override
  void didUpdateWidget(covariant EventImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAvatarUrl != oldWidget.currentAvatarUrl ||
        widget.contextType != oldWidget.contextType) {
      setState(() {
        _displayImageUrl = widget.currentAvatarUrl;
      });
    }
  }

  String _getDialogTitle() {
    switch (widget.contextType) {
      case ImageSelectionContext.profile:
        return 'Profilbild auswählen';
      case ImageSelectionContext.group:
        return 'Gruppenbild auswählen';
      case ImageSelectionContext.event:
        return 'Eventbild auswählen';
      case ImageSelectionContext.other:
      default:
        return 'Bild auswählen';
    }
  }

  List<String> _getPredefinedAvatars() {
    return _predefinedAvatarsByContext[widget.contextType] ??
        _predefinedAvatarsByContext[ImageSelectionContext.other]!;
  }

  Future<void> _pickImageAndUpload() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final picker = ImagePicker();

      final String? selectedSourceOrAssetPath =
          await showModalBottomSheet<String?>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _getDialogTitle(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Aus Galerie wählen'),
                  onTap: () {
                    Navigator.pop(context, 'gallery');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Foto aufnehmen'),
                  onTap: () {
                    Navigator.pop(context, 'camera');
                  },
                ),
                if (_getPredefinedAvatars().isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Oder aus Standardbildern wählen:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _getPredefinedAvatars().length,
                      itemBuilder: (context, index) {
                        final assetPath = _getPredefinedAvatars()[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context, assetPath);
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: AssetImage(assetPath),
                              onBackgroundImageError: (exception, stackTrace) {
                                debugPrint(
                                    'Fehler beim Laden des Asset-Bildes $assetPath: $exception');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                    child: Text(
                      'Abbrechen',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.famkaGrey,
                          ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        },
      );

      if (selectedSourceOrAssetPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bildauswahl abgebrochen.')),
          );
        }
        return;
      }

      XFile? pickedXFile;
      if (selectedSourceOrAssetPath == 'gallery') {
        pickedXFile = await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 90);
      } else if (selectedSourceOrAssetPath == 'camera') {
        pickedXFile = await picker.pickImage(
            source: ImageSource.camera, imageQuality: 90);
      } else if (selectedSourceOrAssetPath.startsWith('assets/')) {
        if (widget.onAvatarSelected != null) {
          widget.onAvatarSelected!(selectedSourceOrAssetPath);
        }
        setState(() {
          _displayImageUrl = selectedSourceOrAssetPath;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Bild erfolgreich als Standardbild gesetzt.')),
          );
        }
        return;
      }

      if (pickedXFile != null) {
        File initialImageFile = File(pickedXFile.path);

        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: initialImageFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 80,
          maxWidth: 800,
          maxHeight: 800,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: _getDialogTitle(),
              // ignore: use_build_context_synchronously
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: _getDialogTitle(),
              aspectRatioLockEnabled: true,
            ),
          ],
        );

        if (croppedFile == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zuschneiden abgebrochen.')),
            );
          }
          return;
        }

        XFile? compressedXFile;

        if (!kIsWeb) {
          final Directory tempDir = await getTemporaryDirectory();
          final String targetPath = p.join(
            tempDir.path,
            "${DateTime.now().millisecondsSinceEpoch}_compressed.jpg",
          );

          compressedXFile = await FlutterImageCompress.compressAndGetFile(
            croppedFile.path,
            targetPath,
            quality: 70,
            minWidth: 400,
            minHeight: 400,
            format: CompressFormat.jpeg,
          );
        }

        File? finalImageToUpload;
        if (kIsWeb) {
          finalImageToUpload = File(croppedFile.path);
        } else if (compressedXFile != null) {
          finalImageToUpload = File(compressedXFile.path);
        } else {
          finalImageToUpload = File(croppedFile.path);
        }

        final User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Fehler: Keine Benutzer-ID verfügbar. Bitte melden Sie sich an.')),
            );
          }
          return;
        }
        String userId = user.uid;

        try {
          String storagePath;
          switch (widget.contextType) {
            case ImageSelectionContext.profile:
              storagePath =
                  'users/$userId/profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
              break;
            case ImageSelectionContext.group:
              storagePath =
                  'groups/images/${DateTime.now().millisecondsSinceEpoch}.jpg';
              break;
            case ImageSelectionContext.event:
              storagePath =
                  'events/images/${DateTime.now().millisecondsSinceEpoch}.jpg';
              break;
            case ImageSelectionContext.other:
            default:
              storagePath =
                  'uploads/${DateTime.now().millisecondsSinceEpoch}.jpg';
              break;
          }

          Reference storageRef = _storage.ref().child(storagePath);

          UploadTask uploadTask = storageRef.putFile(finalImageToUpload);

          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            debugPrint(
                'Upload-Fortschritt: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
          });

          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();

          if (widget.onAvatarSelected != null) {
            widget.onAvatarSelected!(downloadUrl);
          }
          setState(() {
            _displayImageUrl = downloadUrl;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Bild erfolgreich hochgeladen und aktualisiert.')),
            );
          }
        } on FirebaseException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Fehler beim Upload zu Firebase Storage: ${e.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unerwarteter Fehler beim Bild-Upload: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
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
            content: Text('Fehler bei der Bildauswahl oder Zuschneiden: $e'),
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

  Widget _buildImageContent() {
    final String effectiveDisplayUrl =
        (_displayImageUrl == null || _displayImageUrl!.isEmpty)
            ? 'assets/fotos/default.jpg'
            : _displayImageUrl!;

    final double effectiveSideLength = (widget.displayRadius ?? 70) * 2;
    final double effectiveBorderRadius = 0.0;

    return GestureDetector(
      onTap: widget.isInteractive
          ? (_isPickingImage ? null : _pickImageAndUpload)
          : null,
      child: SizedBox(
        width: effectiveSideLength,
        height: effectiveSideLength,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: Stack(
            alignment: Alignment.center,
            children: [
              effectiveDisplayUrl.startsWith('http')
                  ? Image.network(effectiveDisplayUrl,
                      fit: BoxFit.cover,
                      width: effectiveSideLength,
                      height: effectiveSideLength)
                  : effectiveDisplayUrl.startsWith('assets/')
                      ? Image.asset(effectiveDisplayUrl,
                          fit: BoxFit.cover,
                          width: effectiveSideLength,
                          height: effectiveSideLength)
                      : File(effectiveDisplayUrl).existsSync()
                          ? Image.file(File(effectiveDisplayUrl),
                              fit: BoxFit.cover,
                              width: effectiveSideLength,
                              height: effectiveSideLength)
                          : Image.asset('assets/grafiken/famka-kreis.png',
                              fit: BoxFit.contain,
                              width: effectiveSideLength,
                              height: effectiveSideLength),
              if (_isPickingImage)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              else if (_displayImageUrl == null ||
                  _displayImageUrl!.isEmpty ||
                  _displayImageUrl!
                      .startsWith('assets/grafiken/famka-kreis.png'))
                Icon(
                  Icons.camera_alt,
                  size: effectiveSideLength * 0.75,
                  color: Colors.white70,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.applyTransformOffset
        ? Transform.translate(
            offset: const Offset(0, -20),
            child: _buildImageContent(),
          )
        : _buildImageContent();
  }
}
