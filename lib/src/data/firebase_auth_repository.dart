import 'package:firebase_auth/firebase_auth.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;
import 'dart:math' show Random;
import 'dart:convert' show utf8;
import 'package:crypto/crypto.dart' show sha256;

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
    await GoogleSignIn.instance.initialize();
    final GoogleSignInAccount googleUser =
        await GoogleSignIn.instance.authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final credential =
        GoogleAuthProvider.credential(idToken: googleAuth.idToken);
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Future<UserCredential> signInWithApple() async {
    // Für nicht-iOS Plattformen eine Fehlermeldung werfen
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

      print('FirebaseAuthRepository: Starting Apple Sign-In with nonce: ${nonce.substring(0, 8)}...');

      // Apple Sign-In anfordern
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      print('FirebaseAuthRepository: Apple credential received, identityToken: ${appleCredential.identityToken?.substring(0, 20)}...');

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
      );

      print('FirebaseAuthRepository: Created OAuth credential, attempting Firebase sign-in...');

      // Mit Firebase authentifizieren
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      print('FirebaseAuthRepository: Firebase sign-in successful for user: ${userCredential.user?.uid}');

      // Wenn es ein neuer Benutzer ist und Name verfügbar ist, aktualisiere das Profil
      final firebaseUser = userCredential.user;
      if (userCredential.additionalUserInfo?.isNewUser == true &&
          firebaseUser != null &&
          (appleCredential.givenName != null ||
              appleCredential.familyName != null)) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty) {
          await firebaseUser.updateDisplayName(displayName);
          print('FirebaseAuthRepository: Updated display name to: $displayName');
        }
      }

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      print('FirebaseAuthRepository: Apple authorization error: ${e.code} - ${e.message}');
      throw FirebaseAuthException(
        code: e.code.toString(),
        message: 'Apple Sign-In authorization failed: ${e.message}',
      );
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthRepository: Firebase auth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('FirebaseAuthRepository: Unexpected Apple Sign-In error: $e');
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
    final result = List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
    print('FirebaseAuthRepository: Generated nonce with length: ${result.length}');
    return result;
  }

  /// SHA256 hash des [input] String
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    final result = digest.toString();
    print('FirebaseAuthRepository: SHA256 hash generated, length: ${result.length}');
    return result;
  }
}
