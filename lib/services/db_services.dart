import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/controllers/user/user_controller.dart';
import 'package:zipbuzz/models/events/posts/event_post_model.dart';
import 'package:zipbuzz/models/interests/posts/user_interests_post_model.dart';
import 'package:zipbuzz/models/user_model/requests/user_details_request_model.dart';
import 'package:zipbuzz/models/user_model/requests/user_id_request_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/models/user_model/post/user_details_model.dart';
import 'package:zipbuzz/models/user_model/post/user_post_model.dart';
import 'package:zipbuzz/models/user_model/post/user_socials_model.dart';
import 'package:zipbuzz/models/user_model/user_model.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final dbServicesProvider = Provider((ref) => DBServices(
      database: ref.read(databaseProvider),
      dioServices: ref.read(dioServicesProvider),
      ref: ref,
    ));

class DBServices {
  final FirebaseDatabase _database;
  final DioServices _dioServices;
  final Ref _ref;
  const DBServices(
      {required FirebaseDatabase database,
      required Ref ref,
      required DioServices dioServices})
      : _database = database,
        _dioServices = dioServices,
        _ref = ref;

  Future<void> sendMessage(
      {required String chatRoomId,
      required String messageId,
      required Map<String, dynamic> message}) async {
    await _database
        .ref(DatabaseConstants.chatRoomCollection)
        .child(chatRoomId)
        .child(messageId)
        .set(message);
  }

  Stream<DatabaseEvent> getMessages({required String chatRoomId}) {
    return _database
        .ref(DatabaseConstants.chatRoomCollection)
        .child(chatRoomId)
        .onValue;
  }

  // Future<void> createEvent(
  //     {required String eventId,
  //     required String zipcode,
  //     required Map<String, dynamic> event}) async {
  //   await _database
  //       .ref(DatabaseConstants.eventsCollection)
  //       .child(zipcode)
  //       .child(eventId)
  //       .set(event);
  // }

  Future<void> createEvent(EventPostModel eventPostModel) async {
    await _dioServices.postEvent(eventPostModel);
  }

  Stream<DatabaseEvent> getEvents({required String zipcode}) {
    return _database
        .ref(DatabaseConstants.eventsCollection)
        .child(zipcode)
        .onValue;
  }

  Future<void> createUser({required UserModel user}) async {
    try {
      final box = GetStorage();
      debugPrint("CREATING NEW USER");

      final userDetails = UserDetailsModel(
        phoneNumber: user.mobileNumber,
        zipcode: user.zipcode,
        email: user.email,
        profilePicture: user.imageUrl,
        description: user.about,
        username: user.name,
        isAmbassador: false,
      );
      box.write('user_details', userDetails.toJson());

      final userSocials = UserSocialsModel(
        instagram: user.instagramId ?? "null",
        linkedin: user.linkedinId ?? "null",
        twitter: user.twitterId ?? "null",
      );

      final userPostModel =
          UserPostModel(userDetails: userDetails, userSocials: userSocials);
      final res = await _dioServices.createUser(userPostModel);
      if (res['status'] == "success") {
        _ref
            .read(userProvider.notifier)
            .update((state) => state.copyWith(id: res['id']));
        final box = GetStorage();
        box.write("login", true);
        box.write("id", res['id']);
        NavigationController.routeOff(route: PersonalisePage.id);
      } else {
        throw "FAILED TO CREATE USER";
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> map) async {
    await _database
        .ref(DatabaseConstants.usersCollection)
        .child(uid)
        .update(map);
  }

  Future<int> getUserId(UserIdRequestModel userIdRequestModel) async {
    return await _dioServices.getUserId(userIdRequestModel);
  }

  Future<void> getUserData(
      UserDetailsRequestModel userDetailsRequestModel) async {
    try {
      final res = await _dioServices.getUserData(userDetailsRequestModel);
      if (res['status'] == "success") {
        final userDetails = UserDetailsModel.fromJson(res['data']);
        final interests =
            (res['interests'] as List).map((e) => e.toString()).toList();
        final updatedUser = _ref.read(userProvider).copyWith(
              id: userDetailsRequestModel.userId,
              name: userDetails.username,
              mobileNumber: userDetails.phoneNumber,
              email: userDetails.email,
              imageUrl: userDetails.profilePicture,
              about: userDetails.description,
              zipcode: userDetails.zipcode,
              interests: interests,
              isAmbassador: userDetails.isAmbassador,
            );

        _ref.read(userProvider.notifier).update((state) => updatedUser);
      } else {
        showSnackBar(message: "Failed to get userdata");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> postUserInterests(
      UserInterestPostModel userInterestPostModel) async {
    try {
      final res = await _dioServices.postUserInterests(userInterestPostModel);
      if (res['status'] == "success") {
        _ref.read(userProvider.notifier).update((state) =>
            state.copyWith(interests: userInterestPostModel.interests));
        NavigationController.routeOff(route: Home.id);
      } else {
        showSnackBar(message: "Failed to post interests");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
