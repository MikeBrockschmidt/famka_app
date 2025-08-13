import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();

  Future<String?> pickAndUploadImage({
    required ImageSource source,
    required String userId,
    required String uploadPathPrefix,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null;

      final croppedFile = await _cropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Bild zuschneiden',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Bild zuschneiden',
            aspectRatioPickerButtonHidden: true,
            resetButtonHidden: true,
          ),
        ],
      );

      if (croppedFile == null) return null;

      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = p.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        targetPath,
        minWidth: 400,
        minHeight: 400,
        quality: 85,
      );

      if (compressedFile == null) {
        print('❌ Komprimierung fehlgeschlagen.');
        return null;
      }

      final file = File(compressedFile.path);
      final String fileName = p.basename(file.path);
      final String uploadPath = '$uploadPathPrefix/$userId/$fileName';

      // Stellen Sie sicher, dass der Benutzer angemeldet ist und das Auth-Token aktuell ist
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          // Token aktualisieren
          await user.getIdToken(true);
        } catch (e) {
          print('❌ Fehler beim Aktualisieren des Auth-Tokens: $e');
        }
      }

      final ref = _storage.ref().child(uploadPath);

      // Metadaten hinzufügen (kann bei Berechtigungsproblemen helfen)
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toString(),
        },
      );

      final uploadTask = ref.putFile(file, metadata);
      print('Uploading file to $uploadPath');
      final snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print(
            '✅ Bild erfolgreich zu Firebase Storage hochgeladen: $downloadUrl');
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
