import 'package:crypto/crypto.dart' show sha256;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert' show utf8;
import 'dart:io' show Platform;
import 'dart:math' show Random;

class FirebaseAuthRepository implements AuthRepository {
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges();
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      // Vereinfachte Web-Implementierung
      try {
        print('🔥 Starting Google Sign-In for web...');
        
        // Erstelle Google Auth Provider ohne zusätzliche Konfiguration
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        
        print('🔥 Attempting signInWithPopup...');
        final result = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        
        print('🔥 Google Sign-In successful: ${result.user?.email}');
        return result;
        
      } on FirebaseAuthException catch (e) {
        print('🔥 Firebase Auth Error: ${e.code} - ${e.message}');
        print('🔥 Full error: $e');
        
        // Spezifische Fehlermeldungen
        switch (e.code) {
          case 'auth/unauthorized-domain':
            throw FirebaseAuthException(
              code: 'unauthorized_domain',
              message: 'Die Domain famka.web.app ist nicht autorisiert.\n\n'
                  'Lösung:\n'
                  '1. Gehe zu Firebase Console\n'
                  '2. Authentication → Settings → Authorized domains\n'
                  '3. Füge "famka.web.app" hinzu',
            );
          case 'auth/operation-not-allowed':
            throw FirebaseAuthException(
              code: 'google_not_enabled',
              message: 'Google Sign-In ist nicht aktiviert.\n\n'
                  'Lösung:\n'
                  '1. Gehe zu Firebase Console\n'
                  '2. Authentication → Sign-in method\n'
                  '3. Aktiviere Google Provider',
            );
          case 'auth/popup-blocked':
          case 'auth/popup-closed-by-user':
            throw FirebaseAuthException(
              code: 'popup_issue',
              message: 'Popup-Problem. Bitte erlauben Sie Popups oder versuchen Sie es erneut.',
            );
          default:
            // Gebe den ursprünglichen Fehler mit mehr Details weiter
            throw FirebaseAuthException(
              code: e.code,
              message: 'Google Sign-In Fehler: ${e.message}\n\n'
                  'Fehler-Code: ${e.code}\n'
                  'Details: $e',
            );
        }
      } catch (e) {
        print('🔥 Unexpected error: $e');
        throw FirebaseAuthException(
          code: 'unknown_error',
          message: 'Unerwarteter Fehler beim Google Sign-In: $e',
        );
      }
    }

    // Mobile Implementierung – FirebaseAuth mit Google Provider
    try {
      print('🔥 Starting Google Sign-In for mobile (provider)...');

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      final result =
          await FirebaseAuth.instance.signInWithProvider(googleProvider);

      print('🔥 Mobile Google Sign-In successful: ${result.user?.email}');
      return result;
    } on FirebaseAuthException catch (e) {
      print('🔥 Firebase Auth Error (mobile): ${e.code} - ${e.message}');
      switch (e.code) {
        case 'sign_in_canceled':
          throw FirebaseAuthException(
            code: 'sign_in_canceled',
            message: 'Google Sign-In wurde abgebrochen',
          );
        case 'network-request-failed':
          throw FirebaseAuthException(
            code: 'network_error',
            message: 'Netzwerkfehler. Bitte überprüfen Sie Ihre Internetverbindung.',
          );
        default:
          rethrow;
      }
    } catch (e) {
      print('🔥 Unexpected error (mobile): $e');
      throw FirebaseAuthException(
        code: 'google-signin-failed',
        message: 'Google Sign-In fehlgeschlagen: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserCredential> signInWithApple() async {
    // Für Web und nicht-iOS Plattformen eine Fehlermeldung werfen
    if (kIsWeb) {
      throw FirebaseAuthException(
        code: 'unsupported_platform',
        message: 'Apple Sign-In is not supported on web platforms.',
      );
    }
    
    // Check for iOS only on non-web platforms
    if (!Platform.isIOS) {
      throw FirebaseAuthException(
        code: 'unsupported_platform',
        message: 'Apple Sign-In is only supported on iOS devices.',
      );
    }

    try {
      // Apple Sign-In Prozess starten
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Apple Sign-In anfordern
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Validierung der Apple Credentials
      if (appleCredential.identityToken == null) {
        throw FirebaseAuthException(
          code: 'missing-identity-token',
          message: 'Apple Sign-In failed: No identity token received.',
        );
      }

      // OAuthCredential für Firebase erstellen
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Mit Firebase authentifizieren
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      // Wenn es ein neuer Benutzer ist und Name verfügbar ist, aktualisiere das Profil
      final firebaseUser = userCredential.user;
      if (userCredential.additionalUserInfo?.isNewUser == true &&
          firebaseUser != null &&
          (appleCredential.givenName != null ||
              appleCredential.familyName != null)) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await firebaseUser.updateDisplayName(displayName);
        }
      }

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      throw FirebaseAuthException(
        code: e.code.toString(),
        message: 'Apple Sign-In authorization failed: ${e.message}',
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'apple-signin-error',
        message: 'Apple Sign-In failed: $e',
      );
    }
  }

  // Hilfsfunktionen für Apple Sign-In
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// SHA256 hash des [input] String
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
