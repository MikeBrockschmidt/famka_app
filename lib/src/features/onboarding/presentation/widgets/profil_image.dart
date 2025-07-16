import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/foundation.dart'; // Für debugPrint

class ProfilImage extends StatefulWidget {
  final DatabaseRepository db;
  final String? currentAvatarUrl;
  final ValueChanged<String>? onAvatarSelected;
  final String dialogTitle; // <--- HIER WIRD 'dialogTitle' HINZUGEFÜGT

  const ProfilImage(
    this.db, {
    super.key,
    this.currentAvatarUrl,
    this.onAvatarSelected,
    this.dialogTitle = 'Profilbild auswählen', // <--- UND HIER IM KONSTRUKTOR
  });

  @override
  State<ProfilImage> createState() => _ProfilImageState();
}

class _ProfilImageState extends State<ProfilImage> {
  String? _displayImageUrl;
  bool _isPickingImage = false;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // NEU: Liste der vordefinierten Profilbilder
  final List<String> _predefinedProfileAvatars = const [
    'assets/fotos/default.jpg',
    'assets/fotos/Melanie.jpg',
    'assets/fotos/Max.jpg',
    'assets/fotos/Martha.jpg',
    'assets/fotos/boyd.jpg',
    // Füge hier weitere Asset-Pfade hinzu, die du für Profilbilder verwenden möchtest
  ];

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

  Future<void> _pickImageAndUpload() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final picker = ImagePicker();

      // Rückgabetyp des BottomSheets ist jetzt String?, da wir Asset-Pfade oder 'gallery'/'camera' zurückgeben.
      final String? selectedSourceOrAssetPath =
          await showModalBottomSheet<String?>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Für die Ausrichtung der Überschrift
              children: <Widget>[
                Padding(
                  // Titel des Dialogs
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget
                        .dialogTitle, // <--- HIER WIRD DER NEUE PARAMETER VERWENDET
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Aus Galerie wählen'),
                  onTap: () {
                    Navigator.pop(
                        context, 'gallery'); // Signalisiert Auswahl aus Galerie
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Foto aufnehmen'),
                  onTap: () {
                    Navigator.pop(
                        context, 'camera'); // Signalisiert Auswahl per Kamera
                  },
                ),
                // NEU: Standardbilder (Assets)
                if (_predefinedProfileAvatars.isNotEmpty) ...[
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
                    height:
                        80, // Feste Höhe für die horizontale Liste der Bilder
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _predefinedProfileAvatars.length,
                      itemBuilder: (context, index) {
                        final assetPath = _predefinedProfileAvatars[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context,
                                assetPath); // Gibt den Asset-Pfad zurück
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: AssetImage(assetPath),
                              // Optional: Fehler-Debugging für Asset-Bilder
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
                  // Abbrechen-Button
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(
                          context, null); // Dialog schließen ohne Auswahl
                    },
                    // Der Text-Stil für "Abbrechen" wurde hier bereits auf famkaGrey und labelSmall angepasst
                    child: Text(
                      'Abbrechen',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.famkaGrey,
                          ),
                    ),
                  ),
                ),
                SizedBox(
                    height: MediaQuery.of(context)
                        .padding
                        .bottom), // Platz für Safe Area auf iOS
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
      // Unterscheidung, ob Kamera/Galerie gewählt oder ein Asset-Pfad zurückgegeben wurde
      if (selectedSourceOrAssetPath == 'gallery') {
        pickedFile = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
            maxWidth: 800,
            maxHeight: 800);
      } else if (selectedSourceOrAssetPath == 'camera') {
        pickedFile = await picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 80,
            maxWidth: 800,
            maxHeight: 800);
      } else if (selectedSourceOrAssetPath.startsWith('assets/')) {
        // Ein Asset-Bild wurde ausgewählt – KEIN Upload oder Zuschneiden nötig
        if (widget.onAvatarSelected != null) {
          widget.onAvatarSelected!(selectedSourceOrAssetPath);
        }
        setState(() {
          _displayImageUrl = selectedSourceOrAssetPath;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Profilbild erfolgreich als Standardbild gesetzt.')),
          );
        }
        return; // Wichtig: Hier beenden, da keine weitere Verarbeitung für Assets
      }

      // **AB HIER STARTET DER VORHANDENE CODE FÜR ZUSCHNEIDEN UND UPLOAD**
      // Dieser Teil wird nur ausgeführt, wenn pickedFile != null (also von Kamera/Galerie)
      if (pickedFile != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 80,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Bild zuschneiden',
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Bild zuschneiden',
              aspectRatioLockEnabled: true,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
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
          String storagePath =
              'users/$userId/profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
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
                  content: Text(
                      'Profilbild erfolgreich hochgeladen und aktualisiert.')),
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
        // Dies wird ausgeführt, wenn ImagePicker kein Bild von Kamera/Galerie zurückgibt
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
