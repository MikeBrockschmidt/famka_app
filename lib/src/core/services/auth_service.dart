import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

    final GoogleSignInAuthentication googleAuth =
      googleUser.authentication;
      final credential =
          GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  Exception _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('Kein Benutzer mit dieser E-Mail-Adresse gefunden.');
        case 'wrong-password':
          return Exception('Falsches Passwort für diese E-Mail-Adresse.');
        case 'email-already-in-use':
          return Exception('Diese E-Mail-Adresse wird bereits verwendet.');
        case 'invalid-email':
          return Exception('Ungültige E-Mail-Adresse.');
        case 'weak-password':
          return Exception('Das Passwort ist zu schwach.');
        default:
          return Exception('Ein Fehler ist aufgetreten: ${e.message}');
      }
    }
    return Exception('Ein unerwarteter Fehler ist aufgetreten.');
  }
}
