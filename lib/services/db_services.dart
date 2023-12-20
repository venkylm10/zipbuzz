import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/events/posts/event_post_model.dart';
import 'package:zipbuzz/models/events/requests/user_events_request_model.dart';
import 'package:zipbuzz/models/events/responses/event_response_model.dart';
import 'package:zipbuzz/models/interests/posts/user_interests_post_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_update_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_id_request_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/models/user/post/user_details_model.dart';
import 'package:zipbuzz/models/user/post/user_post_model.dart';
import 'package:zipbuzz/models/user/post/user_socials_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
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
  DBServices(
      {required FirebaseDatabase database, required Ref ref, required DioServices dioServices})
      : _database = database,
        _dioServices = dioServices,
        _ref = ref;

  final box = GetStorage();

  Future<void> sendMessage(
      {required int eventId,
      required String messageId,
      required Map<String, dynamic> message}) async {
    try {
      await _database
          .ref(DatabaseConstants.chatRoomCollection)
          .child(eventId.toString())
          .child(messageId)
          .set(message);
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  Stream<DatabaseEvent> getMessages({required int eventId}) {
    return _database.ref(DatabaseConstants.chatRoomCollection).child(eventId.toString()).onValue;
  }

  Future<void> createEvent(EventPostModel eventPostModel) async {
    await _dioServices.postEvent(eventPostModel);
  }

  Future<void> createUser({required UserModel user}) async {
    try {
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

      final userSocials = UserSocialsModel(
        instagram: user.instagramId ?? "null",
        linkedin: user.linkedinId ?? "null",
        twitter: user.twitterId ?? "null",
      );

      final userPostModel = UserPostModel(userDetails: userDetails, userSocials: userSocials);
      final res = await _dioServices.createUser(userPostModel);
      if (res['status'] == "success") {
        final box = GetStorage();
        box.write('user_details', userDetails.toMap());

        _ref.read(userProvider.notifier).update((state) => state.copyWith(id: res['id']));
        box.write(BoxConstants.login, true);
        box.write("id", res['id'] as int);
        NavigationController.routeOff(route: PersonalisePage.id);
      } else {
        throw "FAILED TO CREATE USER";
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateUser(UserDetailsUpdateRequestModel userDetailsUpdateRequestModel) async {
    await _dioServices.updateUserDetails(userDetailsUpdateRequestModel);
  }

  Future<int> getUserId(UserIdRequestModel userIdRequestModel) async {
    return await _dioServices.getUserId(userIdRequestModel);
  }

  Future<void> getUserData(UserDetailsRequestModel userDetailsRequestModel) async {
    try {
      final res = await _dioServices.getUserData(userDetailsRequestModel);
      if (res['status'] == "success") {
        debugPrint("USERDATA RESPONSE $res");
        final userDetails = UserDetailsModel.fromMap(res['data']);
        final interests = (res['interests'] as List).map((e) => e.toString()).toList();
        final userSocials = UserSocialsModel.fromMap(res['socials']);
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
              instagramId: userSocials.instagram,
              linkedinId: userSocials.linkedin,
              twitterId: userSocials.twitter,
            );
        _ref.read(newEventProvider.notifier).updateHostId(userDetailsRequestModel.userId);
        _ref.read(userProvider.notifier).update((state) => updatedUser);
        debugPrint("UPDATED USER DATA${_ref.read(userProvider).toMap()}");
        box.write('user_details', userDetails.toMap());
        box.write('user_interests', updatedUser.interests);
      } else {
        showSnackBar(message: "Failed to get userdata");
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(message: e.toString());
    }
  }

  Future<void> postUserInterests(UserInterestPostModel userInterestPostModel) async {
    try {
      debugPrint("POSTING USER INTERESTS");
      final res = await _dioServices.postUserInterests(userInterestPostModel);
      if (res['status'] == "success") {
        _ref
            .read(userProvider.notifier)
            .update((state) => state.copyWith(interests: userInterestPostModel.interests));
        NavigationController.routeOff(route: Home.id);
        debugPrint("POSTED USER INTERESTS SUCCESSFULLY");
      } else {
        showSnackBar(message: "Failed to post interests");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<EventModel>> getUserEvents(UserEventsRequestModel userEventsRequestModel) async {
    if (box.read(BoxConstants.guestUser) == null) {
      try {
        final list = await _dioServices.getUserEvents(userEventsRequestModel);
        final events = list.map((e) {
          final res = EventResponseModel.fromMap(e as Map<String, dynamic>);
          final eventModel = EventModel(
              id: res.id,
              title: res.name,
              hostId: res.hostId,
              coHostIds: [],
              guestIds: [],
              location: res.venue,
              date: res.date,
              startTime: res.startTime,
              endTime: res.endTime,
              attendees: res.filledCapacity,
              category: res.category,
              favourite: false,
              bannerPath: res.banner,
              iconPath: allInterests[res.category] ?? allInterests['Hiking']!,
              about: res.description,
              isPrivate: res.eventType,
              capacity: res.capacity,
              imageUrls: [],
              privateGuestList: true,
              hostName: res.hostName,
              hostPic: res.hostPic);
          return eventModel;
        }).toList();
        return events;
      } catch (e) {
        debugPrint(e.toString());
        return [];
      }
    }
    return guestEventsList;
  }
}
