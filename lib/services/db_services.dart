import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/events/posts/event_post_model.dart';
import 'package:zipbuzz/models/events/requests/edit_event_model.dart';
import 'package:zipbuzz/models/events/requests/event_members_request_model.dart';
import 'package:zipbuzz/models/events/requests/user_events_request_model.dart';
import 'package:zipbuzz/models/events/responses/event_response_model.dart';
import 'package:zipbuzz/models/events/responses/favorite_event_model.dart';
import 'package:zipbuzz/models/interests/posts/user_interests_post_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_update_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_id_request_model.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/models/user/post/user_details_model.dart';
import 'package:zipbuzz/models/user/post/user_post_model.dart';
import 'package:zipbuzz/models/user/post/user_socials_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';
import 'package:zipbuzz/widgets/event_details_page/event_host_guest_list.dart';

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

  Future<void> setAppleUserEmail({required String uid, required String email}) async {
    try {
      await _database.ref('appleUsers/$uid').set({
        "email": email,
      });
    } catch (error) {
      debugPrint('Error Adding Apple User Email: $error');
    }
  }

  Future<String?> getAppleUserEmail({required String uid}) async {
    try {
      DataSnapshot dataSnapshot = await _database.ref('appleUsers/$uid').get();

      if (dataSnapshot.value != null) {
        final email = (dataSnapshot.value as Map)['email'];
        return email;
      }
      return null;
    } catch (error) {
      debugPrint('Error fetching Apple user email: $error');
      return null;
    }
  }

  Future<int> getCommentCount({required int eventId}) async {
    int count = 0;
    DataSnapshot dataSnapshot = await _database.ref('chatRooms').child(eventId.toString()).get();
    if (dataSnapshot.exists) {
      count = dataSnapshot.children.length;
    }
    return count;
  }

  Stream<DatabaseEvent> getMessages({required int eventId}) {
    return _database.ref(DatabaseConstants.chatRoomCollection).child(eventId.toString()).onValue;
  }

  Future<int> createEvent(EventPostModel eventPostModel) async {
    return await _dioServices.postEvent(eventPostModel);
  }

  Future<void> editEvent(EditEventRequestModel editEventRequestModel) async {
    return await _dioServices.editEvent(editEventRequestModel);
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
        deviceToken: kIsWeb ? "zipbuzz-null" : box.read(BoxConstants.deviceToken),
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
        box.write(BoxConstants.id, res['id'] as int);
        NavigationController.routeOff(route: PersonalisePage.id);
      } else {
        throw "FAILED TO CREATE USER";
      }
    } catch (e) {
      debugPrint("FAILED TO CREATE USER $e");
    }
  }

  Future<void> updateUser(UserDetailsUpdateRequestModel userDetailsUpdateRequestModel) async {
    await _dioServices.updateUserDetails(userDetailsUpdateRequestModel);
    await setAppleUserEmail(
      uid: _ref.read(authProvider).currentUser!.uid,
      email: userDetailsUpdateRequestModel.email,
    );
  }

  Future<int?> getUserId(UserIdRequestModel userIdRequestModel) async {
    return await _dioServices.getUserId(userIdRequestModel);
  }

  Future<void> getUserData(UserDetailsRequestModel userDetailsRequestModel) async {
    try {
      final res = await _dioServices.getUserData(userDetailsRequestModel);
      if (res['status'] == "success") {
        final userDetails = UserDetailsModel.fromMap(res['data']);
        var homeTabInterests = <InterestModel>[];
        final interests = (res['interests'] as List).map((e) {
          final interest = InterestModel.fromMap(e);
          homeTabInterests.add(interest);
          return interest.activity;
        }).toList();
        _ref.read(homeTabControllerProvider.notifier).updateCurrentInterests(homeTabInterests);
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
              country: _ref.read(userLocationProvider).country,
              countryDialCode: _ref.read(userLocationProvider).countryDialCode,
              notificationCount: userDetails.notificationCount,
            );
        _ref.read(newEventProvider.notifier).updateHostId(userDetailsRequestModel.userId);
        _ref.read(userProvider.notifier).update((state) => updatedUser);
        debugPrint("CURRENT USER DATA${_ref.read(userProvider).toMap()}");
        final location = _ref.read(userLocationProvider);
        _ref.read(userLocationProvider.notifier).updateState(location.copyWith(
              zipcode: _ref.read(userProvider).zipcode,
            ));
        box.write(BoxConstants.id, _ref.read(userProvider).id);
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

        debugPrint("POSTED USER INTERESTS SUCCESSFULLY");
      } else {
        showSnackBar(message: "Failed to post interests");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<EventModel>> getAllEvents(UserEventsRequestModel userEventsRequestModel) async {
    try {
      final list = await _dioServices.fetchEvents(userEventsRequestModel);
      final userEvents = list;
      final events = userEvents.map((e) {
        final res = EventResponseModel.fromMap(e);
        // for (var e in interestIcons.entries.toList()) {
        //   print("[${e.key}] : ${e.value}");
        // }
        // print(res.category);
        final eventModel = EventModel(
          id: res.id,
          title: res.name,
          hostId: res.hostId,
          coHostIds: [],
          location: res.venue,
          date: res.date,
          startTime: res.startTime,
          endTime: res.endTime,
          attendees: res.filledCapacity,
          category: res.category,
          isFavorite: res.isFavorite,
          bannerPath: res.banner,
          iconPath: interestIcons[res.category]!,
          about: res.description,
          isPrivate: res.isPrivate,
          privateGuestList: !res.guestList,
          capacity: res.capacity,
          imageUrls: res.images.map((e) => e.imageUrl).toList(),
          hostName: res.hostName,
          hostPic: res.hostPic,
          eventMembers: [],
          inviteUrl: res.inviteUrl,
          status: res.status,
          userDeviceToken: res.userDeviceToken,
          hyperlinks: res.hyperlinks,
          notificationId: res.notificationId,
        );
        return eventModel;
      }).toList();
      return events..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      debugPrint("Error In Getting Events: $e");
      return [];
    }
  }

  Future<List<EventModel>> getUserEvents() async {
    if (box.read(BoxConstants.guestUser) == null) {
      try {
        final list = await _dioServices.fetchUserEvents();
        final events = list.map((e) {
          final res = EventResponseModel.fromMap(e);
          // for (var e in interestIcons.entries.toList()) {
          //   print("[${e.key}] : ${e.value}");
          // }
          // print(res.category);
          final eventModel = EventModel(
            id: res.id,
            title: res.name,
            hostId: res.hostId,
            coHostIds: [],
            location: res.venue,
            date: res.date,
            startTime: res.startTime,
            endTime: res.endTime,
            attendees: res.filledCapacity,
            category: res.category,
            isFavorite: res.isFavorite,
            bannerPath: res.banner,
            iconPath: interestIcons[res.category]!,
            about: res.description,
            isPrivate: res.isPrivate,
            privateGuestList: !res.guestList,
            capacity: res.capacity,
            imageUrls: res.images.map((e) => e.imageUrl).toList(),
            hostName: res.hostName,
            hostPic: res.hostPic,
            eventMembers: [],
            inviteUrl: res.inviteUrl,
            status: res.status,
            userDeviceToken: res.userDeviceToken,
            hyperlinks: res.hyperlinks,
            notificationId: res.notificationId,
          );
          return eventModel;
        }).toList();
        return events..sort((a, b) => a.date.compareTo(b.date));
      } catch (e) {
        debugPrint("Error In Getting Events: $e");
        return [];
      }
    }
    // return guestEventsList;
    return [];
  }

  Future<EventModel> getEventDetails(int eventId) async {
    final e = await _dioServices.getEventDetails(eventId);
    final res = EventResponseModel.fromMap(e);
    final eventModel = EventModel(
      id: res.id,
      title: res.name,
      hostId: res.hostId,
      coHostIds: [],
      location: res.venue,
      date: res.date,
      startTime: res.startTime,
      endTime: res.endTime,
      attendees: res.filledCapacity,
      category: res.category,
      isFavorite: res.isFavorite,
      bannerPath: res.banner,
      iconPath: interestIcons[res.category]!,
      about: res.description,
      isPrivate: res.isPrivate,
      privateGuestList: !res.guestList,
      capacity: res.capacity,
      imageUrls: res.images.map((e) => e.imageUrl).toList(),
      hostName: res.hostName,
      hostPic: res.hostPic,
      eventMembers: [],
      inviteUrl: res.inviteUrl,
      status: res.status,
      userDeviceToken: res.userDeviceToken,
      hyperlinks: res.hyperlinks,
      notificationId: res.notificationId,
    );
    showSnackBar(message: "Event Details Loaded Successfully");
    return eventModel;
  }

  Future<List<EventModel>> getUserFavoriteEvents(
      UserEventsRequestModel userEventsRequestModel) async {
    if (box.read(BoxConstants.guestUser) == null) {
      try {
        final list = await _dioServices.getUserFavoriteEvents(userEventsRequestModel);
        final events = list.map((e) async {
          final res = FavoriteEventModel.fromMap(e as Map<String, dynamic>);
          final members =
              await _dioServices.getEventMembers(EventMembersRequestModel(eventId: res.eventId));
          final fav = FavoriteEventModel.fromMap(e);
          final eventModel = EventModel(
            id: fav.eventId,
            title: fav.name,
            hostId: fav.hostId,
            coHostIds: [],
            location: fav.venue,
            date: fav.date,
            startTime: fav.startTime,
            endTime: fav.endTime,
            attendees: fav.filledCapacity,
            category: fav.category,
            isFavorite: true,
            bannerPath: fav.image,
            iconPath: interestIcons[fav.category]!,
            about: fav.description,
            isPrivate: fav.eventType,
            capacity: fav.capacity,
            imageUrls: [],
            privateGuestList: true,
            hostName: fav.hostName,
            hostPic: fav.hostPic,
            eventMembers: members,
            inviteUrl: fav.inviteUrl,
            status: fav.status,
            userDeviceToken: fav.userDeviceToken,
            hyperlinks: fav.hyperlinks,
            notificationId: fav.notificationId,
          );
          return eventModel;
        }).toList();
        return await Future.wait(events)
          ..sort((a, b) => a.date.compareTo(b.date));
      } catch (e) {
        debugPrint("Error getting favorite events: $e");
        return [];
      }
    }
    // return guestEventsList;
    return [];
  }

  Future<void> getEventRequestMembers(int eventId) async {
    final requests = await _dioServices.getEventRequestMembers(eventId);
    _ref.read(eventRequestMembersProvider.notifier).update((state) => requests);
  }
}
