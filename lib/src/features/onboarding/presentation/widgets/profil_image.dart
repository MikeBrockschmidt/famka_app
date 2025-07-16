import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_cropper/image_cropper.dart'; // Korrekter Import für image_cropper
import 'package:flutter/foundation.dart'; // Für debugPrint

// Importiere die neue Enum-Definition
import 'package:famka_app/src/common/image_selection_context.dart'; // <--- WICHTIG: PFAD MUSS KORREKT SEIN

class ProfilImage extends StatefulWidget {
  final DatabaseRepository db;
  final String? currentAvatarUrl;
  final ValueChanged<String>? onAvatarSelected;
  final ImageSelectionContext
      contextType; // <--- NEU: Der Kontext-Typ ersetzt dialogTitle

  const ProfilImage(
    this.db, {
    super.key,
    this.currentAvatarUrl,
    this.onAvatarSelected,
    this.contextType =
        ImageSelectionContext.profile, // <--- Standardwert ist 'profile'
  });

  @override
  State<ProfilImage> createState() => _ProfilImageState();
}

class _ProfilImageState extends State<ProfilImage> {
  String? _displayImageUrl;
  bool _isPickingImage = false;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Map für die vordefinierten Bilder nach Kontext
  // Diese Liste ist jetzt zentral hier definiert und wird je nach Kontext genutzt.
  final Map<ImageSelectionContext, List<String>> _predefinedAvatarsByContext = {
    ImageSelectionContext.profile: [
      'assets/fotos/default.jpg', // Standard-Profilbild
      'assets/fotos/Melanie.jpg',
      'assets/fotos/Max.jpg',
      'assets/fotos/Martha.jpg',
      'assets/fotos/boyd.jpg',
    ],
    ImageSelectionContext.group: [
      'assets/fotos/Familie.jpg', // Standard-Gruppenbild
      'assets/fotos/nature.jpg',
      'assets/fotos/cityscape.jpg',
      // Füge hier spezifische Gruppenbilder hinzu
    ],
    ImageSelectionContext.event: [
      'assets/fotos/birthday.jpg', // Standard-Eventbilder
      'assets/fotos/party.jpg',
      // Füge hier spezifische Eventbilder hinzu
    ],
    ImageSelectionContext.other: [
      'assets/fotos/default.jpg', // Fallback
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
    // Wichtig: Auch contextType prüfen, falls sich der Kontext dynamisch ändert
    if (widget.currentAvatarUrl != oldWidget.currentAvatarUrl ||
        widget.contextType != oldWidget.contextType) {
      setState(() {
        _displayImageUrl = widget.currentAvatarUrl;
      });
    }
  }

  // Diese Methode liefert den dynamischen Titel
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

  // Diese Methode liefert die dynamischen Asset-Pfade
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
                    _getDialogTitle(), // <--- HIER WIRD DER DYNAMISCHE TITEL VERWENDET
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
                  // <--- HIER WERDEN DIE DYNAMISCHEN BILDER VERWENDET
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

      XFile? pickedFile;
      if (selectedSourceOrAssetPath == 'gallery') {
        // ImagePicker begrenzt die initiale Größe, bevor es an den Cropper geht
        pickedFile = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
            maxWidth: 800,
            maxHeight: 800);
      } else if (selectedSourceOrAssetPath == 'camera') {
        // ImagePicker begrenzt die initiale Größe, bevor es an den Cropper geht
        pickedFile = await picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 80,
            maxWidth: 800,
            maxHeight: 800);
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

      if (pickedFile != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 80,
          maxWidth: 400, // <--- NEU: Maximale Breite auf 400 Pixel setzen
          maxHeight: 400, // <--- NEU: Maximale Höhe auf 400 Pixel setzen
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle:
                  _getDialogTitle(), // <--- AUCH HIER DYNAMISCHER TITEL
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset
                  .square, // **WICHTIG: Quadratisch erzwingen**
              lockAspectRatio: true, // **WICHTIG: Seitenverhältnis sperren**
            ),
            IOSUiSettings(
              title: _getDialogTitle(), // <--- AUCH HIER DYNAMISCHER TITEL
              aspectRatioLockEnabled:
                  true, // **WICHTIG: Seitenverhältnis sperren**
              aspectRatioPresets: [
                CropAspectRatioPreset
                    .square, // **WICHTIG: NUR quadratisch anbieten**
              ],
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

        File imageFile = File(croppedFile.path);

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
            // <--- HIER WIRD DER KONTEXT FÜR DEN SPEICHERPFAD GENUTZT
            case ImageSelectionContext.profile:
              storagePath =
                  'users/$userId/profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
              break;
            case ImageSelectionContext.group:
              // Für Gruppenbilder benötigen wir hier die Gruppen-ID.
              // Da diese nicht direkt im ProfilImage-Widget verfügbar ist,
              // verwenden wir einen generischen Pfad oder du müsstest die groupId
              // als weiteren Parameter an ProfilImage übergeben.
              // Vorerst ein generischer Gruppenpfad:
              storagePath =
                  'groups/images/${DateTime.now().millisecondsSinceEpoch}.jpg';
              break;
            case ImageSelectionContext.event:
              // Für Eventbilder benötigen wir hier die Event-ID.
              // Vorerst ein generischer Eventpfad:
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

          UploadTask uploadTask = storageRef.putFile(imageFile);

          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            print(
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
    } else if (File(effectiveDisplayUrl).existsSync()) {
      imageProvider = FileImage(File(effectiveDisplayUrl));
    } else {
      imageProvider = const AssetImage('assets/fotos/default.jpg');
    }

    return Transform.translate(
      offset: const Offset(0, -20),
      child: GestureDetector(
        onTap: _isPickingImage ? null : _pickImageAndUpload,
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
