import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/models/user_model.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/firebase_providers.dart';

final authServicesProvider = Provider((ref) => AuthServices(
    auth: ref.read(authProvider),
    ref: ref,
    googleSignIn: ref.read(googleSignInProvider)));

class AuthServices {
  final FirebaseAuth _auth;
  final Ref _ref;
  final GoogleSignIn _googleSignIn;
  AuthServices(
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
        final credentials = await _auth.signInWithCredential(authCredential);
        UserModel newUser;
        if (credentials.additionalUserInfo!.isNewUser) {
          newUser = UserModel(
            uid: _auth.currentUser?.uid ?? '',
            name: _auth.currentUser?.displayName ?? '',
            mobileNumber: "",
            email: _auth.currentUser?.email ?? '',
            imageUrl: _auth.currentUser?.photoURL ?? '',
            handle: "",
            position: "",
            about: "New to Zipbuzz",
            eventsHosted: 0,
            rating: 0.toDouble(),
            zipcode: "",
            interests: [],
            eventUids: [],
            pastEventUids: [],
            instagramId: "",
            linkedinId: "",
            twitterId: "",
            city: "",
            country: '',
            countryDialCode: '',
          );
          await _ref.read(dbServicesProvider).createUser(user: newUser);
        } else {
          newUser = (await getUserData(_ref.read(authProvider).currentUser!.uid).first)!;
        }
        _ref.read(userProvider.notifier).update((state) => newUser);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void initialiseUser(UserModel user) {
    _ref.read(userProvider.notifier).update((state) => user);
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<UserModel?> getUserData(String uid) {
    return _ref.read(dbServicesProvider).getUserData(uid).map(
      (event) {
        if (event.snapshot.exists) {
          final jsonString = jsonEncode(event.snapshot.value);
          final userMap = jsonDecode(jsonString);
          return UserModel.fromMap(userMap);
        } else {
          return null;
        }
      },
    );
  }
}
