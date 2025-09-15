import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/foundation.dart';

import 'package:famka_app/src/common/image_selection_context.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:famka_app/gen_l10n/app_localizations.dart';

class ProfilImage extends StatefulWidget {
  final DatabaseRepository db;
  final String? currentAvatarUrl;
  final ValueChanged<String>? onAvatarSelected;
  final ImageSelectionContext contextType;

  const ProfilImage(
    this.db, {
    super.key,
    this.currentAvatarUrl,
    this.onAvatarSelected,
    this.contextType = ImageSelectionContext.profile,
  });

  @override
  State<ProfilImage> createState() => _ProfilImageState();
}

class _ProfilImageState extends State<ProfilImage> {
  String? _displayImageUrl;
  bool _isPickingImage = false;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  final Map<ImageSelectionContext, List<String>> _predefinedAvatarsByContext = {
    ImageSelectionContext.profile: [
      'assets/grafiken/mann-pink.png',
      'assets/grafiken/mann.png',
      'assets/grafiken/frau.png',
      'assets/grafiken/frau-blau.png',
      'assets/fotos/boyd.jpg',
    ],
    ImageSelectionContext.group: [
      'assets/grafiken/Familie.jpg',
      'assets/grafiken/family.jpg',
      'assets/grafiken/familienbande.jpg',
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
  void didUpdateWidget(covariant ProfilImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAvatarUrl != oldWidget.currentAvatarUrl ||
        widget.contextType != oldWidget.contextType) {
      setState(() {
        _displayImageUrl = widget.currentAvatarUrl;
      });
    }
  }

  String _getDialogTitle() {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations == null) return 'Select Image';

    switch (widget.contextType) {
      case ImageSelectionContext.profile:
        return appLocalizations.selectProfileImage;
      case ImageSelectionContext.group:
        return appLocalizations.selectGroupImage;
      case ImageSelectionContext.event:
        return appLocalizations.selectEventImage;
      case ImageSelectionContext.other:
      default:
        return appLocalizations.selectImage;
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
      final appLocalizations = AppLocalizations.of(context);

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
                  title: Text(appLocalizations?.selectFromGallery ??
                      'Select from Gallery'),
                  onTap: () {
                    Navigator.pop(context, 'gallery');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(appLocalizations?.takePhoto ?? 'Take Photo'),
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
                      appLocalizations?.chooseFromStandard ??
                          'Or choose from standard images:',
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
                                    'Error loading asset image $assetPath: $exception');
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
                      appLocalizations?.cancelSelection ?? 'Cancel',
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
            SnackBar(
                content: Text(appLocalizations?.imageSelectionCancelled ??
                    'Image selection cancelled.')),
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
            SnackBar(
                content: Text(appLocalizations?.standardImageSet ??
                    'Image successfully set as standard image.')),
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
              SnackBar(
                  content: Text(appLocalizations?.croppingCancelled ??
                      'Cropping cancelled.')),
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
            quality: 100,
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
              SnackBar(
                  content: Text(appLocalizations?.noUserIdError ??
                      'Error: No user ID available. Please sign in.')),
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
              SnackBar(
                  content: Text('Image successfully uploaded and updated.')),
            );
          }
        } on FirebaseException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Error uploading to Firebase Storage: ${e.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unexpected error during image upload: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    appLocalizations?.noImageSelected ?? 'No image selected.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error in image selection or cropping: $e'),
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
            ? 'assets/grafiken/HI-blau.jpg'
            : _displayImageUrl!;

    Widget avatarWidget;
    if (effectiveDisplayUrl.startsWith('http')) {
      // Generischer Blurhash-String (blau-grau)
      const blurHash = 'LEHV6nWB2yk8pyo0adR*.7kCMdnj';
      avatarWidget = ClipOval(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              BlurHash(
                hash: blurHash,
                imageFit: BoxFit.cover,
                duration: const Duration(milliseconds: 500),
              ),
              Image.network(
                effectiveDisplayUrl,
                fit: BoxFit.cover,
                width: 200,
                height: 200,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox.shrink();
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red, size: 48);
                },
              ),
            ],
          ),
        ),
      );
    } else if (effectiveDisplayUrl.startsWith('assets/')) {
      avatarWidget = CircleAvatar(
        radius: 100,
        backgroundColor: AppColors.famkaGreen,
        backgroundImage: AssetImage(effectiveDisplayUrl),
      );
    } else if (File(effectiveDisplayUrl).existsSync()) {
      avatarWidget = CircleAvatar(
        radius: 100,
        backgroundColor: AppColors.famkaGreen,
        backgroundImage: FileImage(File(effectiveDisplayUrl)),
      );
    } else {
      avatarWidget = const CircleAvatar(
        radius: 100,
        backgroundColor: AppColors.famkaGreen,
        backgroundImage: AssetImage('assets/grafiken/famka-kreis.png'),
      );
    }

    return Transform.translate(
      offset: const Offset(0, 0),
      child: GestureDetector(
        onTap: _isPickingImage ? null : _pickImageAndUpload,
        child: Stack(
          alignment: Alignment.center,
          children: [
            avatarWidget,
            if (_isPickingImage)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            else if (_displayImageUrl == null ||
                _displayImageUrl!.isEmpty ||
                _displayImageUrl!.startsWith('assets/grafiken/famka-kreis.png'))
              const Icon(
                Icons.camera_alt,
                size: 48,
                color: Colors.white30,
              ),
          ],
        ),
      ),
    );
  }
}
