import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
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
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

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

  final box = GetStorage();

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final box = GetStorage();
        final googleAuth = await googleUser.authentication;
        final authCredential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
        final credentials = await _auth.signInWithCredential(authCredential);

        if (credentials.additionalUserInfo!.isNewUser) {
          _ref.read(loadingTextProvider.notifier).reset();
          var location = _ref.read(userLocationProvider);
          location = _ref.read(userLocationProvider);
          final auth = _ref.read(authProvider);
          UserModel newUser = UserModel(
            id: 1,
            name: auth.currentUser?.displayName ?? '',
            mobileNumber: "+11234567890",
            email: auth.currentUser?.email ?? '',
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
          // creating new user
          _ref.read(loadingTextProvider.notifier).updateLoadingText("Signing Up...");
          await _ref.read(dbServicesProvider).createUser(user: newUser);
          debugPrint("USER CREATED SUCCESSFULLY");
          _ref.read(loadingTextProvider.notifier).reset();
          final id = await _ref.read(dbServicesProvider).getUserId(
                UserIdRequestModel(
                  email: _ref.read(authProvider).currentUser!.email ?? "",
                  deviceToken: box.read(BoxConstants.deviceToken),
                ),
              );
          // storing id
          box.write(BoxConstants.id, id);
          box.write(BoxConstants.login, true);
          await _ref.read(dbServicesProvider).getUserData(UserDetailsRequestModel(userId: id));
          navigatorKey.currentState!.pushNamedAndRemoveUntil(PersonalisePage.id, (route) => false);
          return;
        } else {
          // getting id
          final id = await _ref.read(dbServicesProvider).getUserId(
                UserIdRequestModel(
                  email: _ref.read(authProvider).currentUser!.email ?? "",
                  deviceToken: box.read(BoxConstants.deviceToken),
                ),
              );
          // storing id
          box.write(BoxConstants.id, id);
          box.write(BoxConstants.login, true);
          _ref.read(newEventProvider.notifier).updateHostId(id);

          // Back to AuthGate
          navigatorKey.currentState!.pushNamedAndRemoveUntil(AuthGate.id, (route) => false);

          return;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {

    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    User user = userCredential.user!;

    if(user.email == null){
      Get.snackbar(
        "Something Went Wrong",
        "Email Doesn\'t Exist In Apple ID",
      );
    }

    else if(userCredential.additionalUserInfo!.isNewUser){


      _ref.read(loadingTextProvider.notifier).reset();
      var location = _ref.read(userLocationProvider);
      location = _ref.read(userLocationProvider);
      // final auth = _ref.read(authProvider);
      UserModel newUser = UserModel(
        id: 1,
        name: user.displayName ?? '',
        mobileNumber: "+11234567890",
        email: user.email ?? '',
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
      // creating new user
      _ref.read(loadingTextProvider.notifier).updateLoadingText("Signing Up...");
      await _ref.read(dbServicesProvider).createUser(user: newUser);
      debugPrint("USER CREATED SUCCESSFULLY");
      _ref.read(loadingTextProvider.notifier).reset();
      final id = await _ref.read(dbServicesProvider).getUserId(
        UserIdRequestModel(
          email: user.email ?? "",
          deviceToken: box.read(BoxConstants.deviceToken),
        ),
      );
      // storing id
      box.write(BoxConstants.id, id);
      box.write(BoxConstants.login, true);
      await _ref.read(dbServicesProvider).getUserData(UserDetailsRequestModel(userId: id));
      navigatorKey.currentState!.pushNamedAndRemoveUntil(PersonalisePage.id, (route) => false);
      return;


    }else {

      // getting id
      final id = await _ref.read(dbServicesProvider).getUserId(
        UserIdRequestModel(
          email: user.email ?? "",
          deviceToken: box.read(BoxConstants.deviceToken),
        ),
      );
      // storing id
      box.write(BoxConstants.id, id);
      box.write(BoxConstants.login, true);
      _ref.read(newEventProvider.notifier).updateHostId(id);

      // Back to AuthGate
      navigatorKey.currentState!.pushNamedAndRemoveUntil(AuthGate.id, (route) => false);

      return;
    }

  }



  Future<void> signOut() async {
    final box = GetStorage();
    if (box.read(BoxConstants.guestUser) != null) {
      box.remove(BoxConstants.login);
      box.remove(BoxConstants.guestUser);
      navigatorKey.currentState!.pushNamedAndRemoveUntil(AuthGate.id, (route) => false);
      return;
    }
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      box.remove(BoxConstants.login);
      box.remove(BoxConstants.guestUser);
      navigatorKey.currentState!.pushNamedAndRemoveUntil(AuthGate.id, (route) => false);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
