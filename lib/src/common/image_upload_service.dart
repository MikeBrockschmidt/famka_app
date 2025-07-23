// lib/src/common/image_upload_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_auth/firebase_auth.dart'; // Für User ID
import 'package:flutter/material.dart'; // Für Colors.deepOrange etc.

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();

  /// Wählt ein Bild aus, schneidet es zu, komprimiert es und lädt es zu Firebase Storage hoch.
  /// Gibt die Download-URL zurück oder null bei Fehler/Abbruch.
  Future<String?> pickAndUploadImage({
    required ImageSource source,
    required String userId,
    required String
        uploadPathPrefix, // z.B. 'event_images' oder 'profile_images'
  }) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null; // Abgebrochen

      // Bild zuschneiden
      final croppedFile = await _cropper.cropImage(
        sourcePath: pickedFile.path,
        // Nur quadratischen Zuschnitt als Option anbieten
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Bild zuschneiden',
            toolbarColor: Colors
                .deepOrange, // Hier können Sie Ihre gewünschte Farbe einstellen
            toolbarWidgetColor: Colors.white,
            initAspectRatio:
                CropAspectRatioPreset.square, // Standardmäßig auf Quadrat
            lockAspectRatio: true, // Seitenverhältnis auf Quadrat erzwingen
          ),
          IOSUiSettings(
            title: 'Bild zuschneiden',
            aspectRatioPickerButtonHidden:
                true, // Seitenverhältnis-Auswahl auf iOS ausblenden
            resetButtonHidden: true, // Reset-Button auf iOS ausblenden
          ),
        ],
      );

      if (croppedFile == null) return null; // Zuschneiden abgebrochen

      // Bild komprimieren auf 400x400px
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = p.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        targetPath,
        minWidth: 400, // NEU: Komprimierung auf 400px Breite
        minHeight: 400, // NEU: Komprimierung auf 400px Höhe
        quality: 85,
      );

      if (compressedFile == null) {
        print('❌ Komprimierung fehlgeschlagen.');
        return null;
      }

      final file = File(compressedFile.path);
      final String fileName = p.basename(file.path);
      final String uploadPath = '$uploadPathPrefix/$userId/$fileName';

      // Referenz für Firebase Storage erstellen
      final ref = _storage.ref().child(uploadPath);

      // Datei hochladen
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print(
            '✅ Bild erfolgreich zu Firebase Storage hochgeladen: $downloadUrl');
        // Temporäre komprimierte Datei löschen
        if (await file.exists()) {
          await file.delete();
        }
        return downloadUrl;
      } else {
        print('❌ Fehler beim Hochladen des Bildes: ${snapshot.state}');
        return null;
      }
    } on FirebaseException catch (e) {
      print('❌ Firebase Fehler beim Hochladen: $e');
      return null;
    } catch (e) {
      print('❌ Allgemeiner Fehler beim Hochladen: $e');
      return null;
    }
  }
}
