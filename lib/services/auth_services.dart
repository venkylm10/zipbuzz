import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_id_request_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';

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
        box.remove(BoxConstants.login);
        box.remove(BoxConstants.guestUser);
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
          NavigationController.routeOff(route: PersonalisePage.id);
          return;
        } else {
          // getting id
          final id = await _ref
              .read(dbServicesProvider)
              .getUserId(UserIdRequestModel(email: newUser.email));
          // storing id
          box.write('id', id);
          _ref.read(newEventProvider.notifier).updateHostId(id);
          _ref.read(newEventProvider.notifier).updateHostName(newUser.name);
          _ref.read(newEventProvider.notifier).updateHostPic(newUser.imageUrl);

          // updating user locally
          _ref.read(userProvider.notifier).update((state) => newUser.copyWith(id: id));

          // getting userdata
          await _ref.read(dbServicesProvider).getUserData(UserDetailsRequestModel(userId: id));
          box.write(BoxConstants.login, true);
          await _ref.read(userLocationProvider.notifier).getCurrentLocation();
          final location = _ref.read(userLocationProvider);
          _ref.read(userProvider.notifier).update(
                (state) => state.copyWith(
                  zipcode: location.zipcode,
                  city: location.city,
                  country: location.country,
                  countryDialCode: location.countryDialCode,
                ),
              );
          await _ref.read(contactsServicesProvider).updateAllContacts();

          // user details updated successfully, navigate to Home
          NavigationController.routeOff(route: Home.id);
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
      await _auth.signOut();
      final box = GetStorage();
      box.remove(BoxConstants.login);
      box.remove(BoxConstants.guestUser);
      NavigationController.routeOff(route: WelcomePage.id);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
