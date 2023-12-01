import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zipbuzz/services/firebase_providers.dart';

final authServicesProvider = Provider((ref) => AuthServices(
    auth: ref.read(authProvider),
    ref: ref,
    googleSignIn: ref.read(googleSignInProvider)));

class AuthServices {
  final FirebaseAuth _auth;
  final Ref _ref;
  final GoogleSignIn _googleSignIn;
  const AuthServices(
      {required FirebaseAuth auth,
      required Ref ref,
      required GoogleSignIn googleSignIn})
      : _auth = auth,
        _ref = ref,
        _googleSignIn = googleSignIn;

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final authCredential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
        await _auth.signInWithCredential(authCredential);
      }
    } catch (e) {
      
    }
  }
}
