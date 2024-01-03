import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/user/requests/user_id_request_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/widgets/auth_gate.dart';
import 'package:zipbuzz/widgets/common/loader.dart';

final authServicesProvider = Provider((ref) => AuthServices(
    auth: ref.read(authProvider), ref: ref, googleSignIn: ref.read(googleSignInProvider)));

class AuthServices {
  final FirebaseAuth _auth;
  final Ref _ref;
  final GoogleSignIn _googleSignIn;
  AuthServices({required FirebaseAuth auth, required Ref ref, required GoogleSignIn googleSignIn})
      : _auth = auth,
        _ref = ref,
        _googleSignIn = googleSignIn;

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final box = GetStorage();
        final googleAuth = await googleUser.authentication;
        final authCredential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
        final credentials = await _auth.signInWithCredential(authCredential);
        UserModel newUser;
        final location = _ref.read(userLocationProvider);
        newUser = UserModel(
          id: 1,
          name: _auth.currentUser?.displayName ?? '',
          mobileNumber: _auth.currentUser?.phoneNumber ?? '${location.countryDialCode}9999999999',
          email: _auth.currentUser?.email ?? '',
          imageUrl: _ref.read(defaultsProvider).profilePictureUrl,
          handle: "",
          isAmbassador: false,
          about: "New to Zipbuzz",
          eventsHosted: 0,
          rating: 0.toDouble(),
          zipcode: location.zipcode,
          interests: [],
          eventUids: [],
          pastEventUids: [],
          instagramId: "null",
          linkedinId: "null",
          twitterId: "null",
          city: location.city,
          country: location.country,
          countryDialCode: location.countryDialCode,
        );

        if (credentials.additionalUserInfo!.isNewUser) {
          _ref.read(loadingTextProvider.notifier).reset();
          navigatorKey.currentState!.pushNamedAndRemoveUntil(PersonalisePage.id, (route) => false);
          return;
        } else {
          // getting id
          final id = await _ref
              .read(dbServicesProvider)
              .getUserId(UserIdRequestModel(email: newUser.email));
          // storing id
          box.write(BoxConstants.id, id);
          box.write(BoxConstants.login, true);
          _ref.read(newEventProvider.notifier).updateHostId(id);
          _ref.read(newEventProvider.notifier).updateHostName(newUser.name);
          _ref.read(newEventProvider.notifier).updateHostPic(newUser.imageUrl);

          // Back to AuthGate
          navigatorKey.currentState!.pushNamedAndRemoveUntil(AuthGate.id, (route) => false);

          return;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
      await _auth.signOut();
      final box = GetStorage();
      box.remove(BoxConstants.login);
      box.remove(BoxConstants.guestUser);
      navigatorKey.currentState!.pushNamedAndRemoveUntil(AuthGate.id, (route) => false);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
