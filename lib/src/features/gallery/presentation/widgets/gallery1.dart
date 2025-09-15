import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famka_app/src/common/image_upload_service.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/item_data.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';

class Gallery extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;

  const Gallery(this.db, {super.key, required this.auth});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final List<GalleryItem> _uploadedImages = [];
  bool _isPickingImage = false;

  static const String _imagePathsKey = 'uploadedImagePaths';

  List<GalleryItem> galleryData = [];

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
        if (path.startsWith('http://') || path.startsWith('https://')) {
          loadedItems.add(
              GalleryItem(type: ItemType.image, imageUrl: path, content: path));
        } else {
          final file = File(path);
          if (await file.exists()) {
            loadedItems.add(GalleryItem(
                type: ItemType.image, imageUrl: path, content: 'image:$path'));
          } else {
            // Datei nicht gefunden, wird ignoriert.
          }
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
    // Löschen in der Galerie entfernt das Bild nur lokal aus der Galerie-Liste.
    // Die Datenbank bleibt unverändert. Die endgültige Löschung erfolgt erst,
    // wenn das Bild auch aus dem Kalender entfernt wurde und bei niemandem mehr in der Galerie ist.
    if (itemToDelete.type != ItemType.image ||
        itemToDelete.imageUrl == null ||
        itemToDelete.imageUrl!.startsWith('assets/')) {
      return;
    }

    final bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.deleteImageTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.famkaBlack,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.deleteImageDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: ButtonLinearGradient(
                          buttonText:
                              AppLocalizations.of(context)!.deleteImageButton,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          AppLocalizations.of(context)!.cancelButton,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmDelete) {
      try {
        if (itemToDelete.imageUrl!.startsWith('http://') ||
            itemToDelete.imageUrl!.startsWith('https://')) {
          try {
            final ref =
                FirebaseStorage.instance.refFromURL(itemToDelete.imageUrl!);
            await ref.delete();
      // Bild erfolgreich aus Firebase Storage gelöscht.
          } on FirebaseException catch (e) {
            // Fehler beim Löschen aus Firebase Storage werden ignoriert.
          }
        } else {
          final file = File(itemToDelete.imageUrl!);
          if (await file.exists()) {
            await file.delete();
          }
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
            SnackBar(
              backgroundColor: AppColors.famkaCyan,
              content: Text(AppLocalizations.of(context)!.imageDeletedSuccess),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.famkaRed,
              content: Text(
                  AppLocalizations.of(context)!.imageDeleteError(e.toString())),
            ),
          );
        }
      }
    }
  }

  void _updateGalleryData() {
    final List<GalleryItem> dynamicImages =
        GalleryData.getDynamicImagesGalleryItems();
    // final List<GalleryItem> dynamicIcons =
    //     GalleryData.getDynamicIconsGalleryItems();
    final List<GalleryItem> dynamicEmojis =
        GalleryData.getDynamicEmojisGalleryItems();

    if (mounted) {
      setState(() {
        galleryData = [
          const GalleryItem(type: ItemType.addPhoto, content: 'addPhoto'),
          ...GalleryData.fixedThumbnails,
          ..._uploadedImages,
          ...dynamicImages,
          // ...dynamicIcons,
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
      // Vergewissern, dass der Benutzer angemeldet ist
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
  // Kein Benutzer angemeldet. Bitte zuerst anmelden.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.famkaRed,
              content:
                  Text('Sie müssen angemeldet sein, um Bilder hochzuladen.'),
            ),
          );
        }
        return;
      }

      // Manchmal müssen wir das Auth-Token aktualisieren
      try {
        await user.getIdToken(true); // Token aktualisieren
  // Auth-Token aktualisiert.
      } catch (e) {
        // Fehler beim Aktualisieren des Auth-Tokens werden ignoriert.
      }

      final String userId = user.uid;

      final ImageUploadService uploadService = ImageUploadService();
      final String? uploadedImageUrl = await uploadService.pickAndUploadImage(
        source: source,
        userId: userId,
        uploadPathPrefix: 'event_gallery_images',
      );

      if (uploadedImageUrl != null) {
        if (mounted) {
          setState(() {
            if (uploadedImageUrl.startsWith('http://') ||
                uploadedImageUrl.startsWith('https://')) {
              _uploadedImages.add(GalleryItem(
                  type: ItemType.image,
                  imageUrl: uploadedImageUrl,
                  content: uploadedImageUrl));
            } else {
              _uploadedImages.add(GalleryItem(
                  type: ItemType.image,
                  imageUrl: uploadedImageUrl,
                  content: 'image:$uploadedImageUrl'));
            }
            _updateGalleryData();
          });
        }
        await _saveUploadedImages();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.famkaCyan,
              content: Text(
                  AppLocalizations.of(context)!.imageUploadSuccessSelectNow),
            ),
          );
        }
      } else {
  // Bild-Upload abgebrochen oder fehlgeschlagen.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.famkaRed,
              content: Text(AppLocalizations.of(context)!.imageUploadAborted),
            ),
          );
        }
      }
    } catch (e) {
  // Fehler beim Bild-Upload oder Benutzer-ID-Abruf.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text(
                AppLocalizations.of(context)!.imageUploadError(e.toString())),
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
                title: Text(AppLocalizations.of(context)!.gallerySourceGallery),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(AppLocalizations.of(context)!.gallerySourceCamera),
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
        } else if (item.imageUrl != null &&
            (item.imageUrl!.startsWith('http://') ||
                item.imageUrl!.startsWith('https://'))) {
          return Image.network(
            item.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 40,
                color: AppColors.famkaRed),
          );
        } else if (item.imageUrl != null) {
          return FutureBuilder<bool>(
            future: File(item.imageUrl!).exists(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == true) {
                return Image.file(
                  File(item.imageUrl!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: AppColors.famkaRed),
                );
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == false) {
                return const Icon(Icons.broken_image,
                    size: 40, color: AppColors.famkaRed);
              }
              return const CircularProgressIndicator();
            },
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
      // default-Klausel entfernt, da alle Fälle abgedeckt sind
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
            height: 100,
            width: double.infinity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: HeadlineK(
                screenHead: AppLocalizations.of(context)?.piktogrammeLabe ??
                    'Piktogramme',
              ),
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
