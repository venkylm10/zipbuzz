import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/models/events/event_request_member.dart';
import 'package:zipbuzz/models/events/join_request_model.dart';
import 'package:zipbuzz/models/events/posts/add_fav_event_model_class.dart';
import 'package:zipbuzz/models/events/posts/event_invite_post_model.dart';
import 'package:zipbuzz/models/events/posts/event_post_model.dart';
import 'package:zipbuzz/models/events/posts/make_request_model.dart';
import 'package:zipbuzz/models/events/requests/edit_event_model.dart';
import 'package:zipbuzz/models/events/requests/event_members_request_model.dart';
import 'package:zipbuzz/models/events/requests/user_events_request_model.dart';
import 'package:zipbuzz/models/events/responses/event_members_response_model.dart';
import 'package:zipbuzz/models/interests/posts/user_interests_post_model.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/models/onboarding_page_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_update_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_id_request_model.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/dio_contants.dart';
import 'package:zipbuzz/models/user/post/user_post_model.dart';

final dioServicesProvider = Provider((ref) => DioServices(ref: ref));

class DioServices {
  final Ref ref;
  DioServices({required this.ref});
  Dio dio = Dio(
    BaseOptions(
      baseUrl: DioConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${GetStorage().read(BoxConstants.accessToken)}',
      },
    ),
  );
  final box = GetStorage();

  static Future<void> getToken() async {
    final res = await Dio(
      BaseOptions(
        baseUrl: DioConstants.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    ).get(DioConstants.getTokenApi);

    final token = res.data['token'] as String;
    GetStorage().write(BoxConstants.accessToken, token);
  }

  // send event urls
  Future<void> sendEventUrls(int eventId, List<TextEditingController> urls,
      List<TextEditingController> hyperLinkName) async {
    if (urls.length == 1) {
      if (urls.first.text.trim().isEmpty || hyperLinkName.first.text.trim().isEmpty) {
        return;
      }
    }
    try {
      for (int i = 0; i < urls.length; i++) {
        await dio.post(
          DioConstants.sendEventUrls,
          data: {
            "event_id": eventId,
            "event_url": urls[i].text,
            "url_name": hyperLinkName[i].text,
          },
        );
      }
    } catch (e) {
      debugPrint("Error sending event urls: $e");
    }
  }

  // make request
  Future<void> makeRequest(MakeRequestModel model) async {
    try {
      await dio.post(DioConstants.makeRequests, data: model.toMap());
    } catch (e) {
      debugPrint("Error sending user request: $e");
    }
  }

  // increase count
  Future<void> increaseCommentCount(int eventId) async {
    try {
      await dio.post(DioConstants.increaseComment, data: {"event_id": eventId});
    } catch (e) {
      debugPrint("Error increasing comment count: $e");
    }
  }

  Future<void> increaseDecision(int eventId, String decicion) async {
    try {
      await dio
          .post(DioConstants.increaseDecision, data: {"event_id": eventId, "decision": decicion});
    } catch (e) {
      debugPrint("Error decision increasing: $e");
    }
  }

  // delete event images
  Future<void> deleteEventImages(List<String> images) async {
    try {
      await dio.put(DioConstants.updateEventImages, data: {"event_images": images});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // notification
  Future<List<NotificationData>> getNotifications() async {
    try {
      final response = kIsWeb
          ? await dio.post(DioConstants.getNotificationsWeb, data: {
              "user_id": ref.read(userProvider).id,
            })
          : await dio.get(DioConstants.getNotifications, data: {
              "user_id": ref.read(userProvider).id,
            });
      final list = response.data['notification_data'] as List;
      return list.map((e) => NotificationData.fromMap(e)).toList();
    } catch (e) {
      debugPrint(e.toString());
      return <NotificationData>[];
    }
  }

  Future<void> updateNotification(int notificationId, String notificationType) async {
    debugPrint({
      "notification_id": notificationId,
      "notification_type": notificationType,
    }.toString());
    try {
      await dio.put(DioConstants.updateNotification, data: {
        "notification_id": notificationId,
        "notification_type": notificationType,
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // phone check
  Future<bool> checkPhone(String phoneNumber) async {
    try {
      final res = kIsWeb
          ? await dio.post(
              DioConstants.phoneCheck,
              data: {"phone": phoneNumber},
            )
          : await dio.get(
              DioConstants.phoneCheck,
              data: {"phone": phoneNumber},
            );
      debugPrint("check phone: $phoneNumber ${res.data}");
      if (res.data['message'] == "User not found") {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get country code
  Future<String?> getCountryCode() async {
    try {
      final response = await dio.get(DioConstants.countryCode);
      return response.data['countryCode'].toString();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Fetch onboarding details
  Future<void> updateOnboardingDetails() async {
    try {
      final response = await dio.get(DioConstants.onboardingDetails);
      final list = response.data['onboarding_data'] as List;
      final pageDetails = list.map((e) => OnboardingPageModel.fromMap(e)).toList();
      ref.read(onboardingDetailsProvider.notifier).update((state) => pageDetails);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Failed to get onboarding details");
    }
  }

  Future<Map<String, dynamic>> createUser(UserPostModel userPostModel) async {
    try {
      final response = await dio.post(DioConstants.createUser, data: userPostModel.toMap());
      return response.data as Map<String, dynamic>;
    } catch (error) {
      debugPrint('Error in postUser: $error');
      throw ('Failed to post user');
    }
  }

  Future<String> postUserImage(File image) async {
    final userId = box.read(BoxConstants.id) as int;
    final imageName = image.path.split('/').last;

    final formData = FormData.fromMap({
      "media": await MultipartFile.fromFile(image.path, filename: imageName),
      "user_id": userId,
    });
    try {
      final res = await dio.post(DioConstants.postUserImage, data: formData);
      debugPrint("Posted user image");
      return res.data['pic_url'] as String;
    } catch (error) {
      debugPrint('Error in putUserImage: $error');
      throw ('Failed to put user image');
    }
  }

  Future<String> postEventBanner(File image) async {
    final imageName = image.path.split('/').last;
    final formData = FormData.fromMap({
      "media": await MultipartFile.fromFile(image.path, filename: imageName),
    });
    try {
      final res = await dio.post(DioConstants.postEventBanner, data: formData);
      debugPrint("Posted Event Banner");
      return res.data['pic_url'] as String;
    } catch (error) {
      debugPrint('Error in postEventBanner: $error');
      throw ('Failed to post Event Banner');
    }
  }

  Future<void> postEventImages(int eventId, List<File> images) async {
    try {
      List<MultipartFile> imageFiles = [];

      for (int i = 0; i < images.length; i++) {
        final imageName = images[i].path.split('/').last;
        imageFiles.add(await MultipartFile.fromFile(images[i].path, filename: imageName));
      }
      final formData = FormData.fromMap({
        "medias": imageFiles,
        "event_id": eventId.toString(),
      });
      await dio.post(DioConstants.postEventImages, data: formData);
    } catch (error) {
      debugPrint('Error in postEventImages: $error');
      throw ('Failed to post Event Images');
    }
  }

  Future<List<InterestModel>> getAllInterests() async {
    try {
      final response = await dio.get(DioConstants.allCategories);
      var list = <InterestModel>[];
      for (var item in (response.data['category_data'] as List)) {
        list.add(InterestModel.fromMap(item as Map<String, dynamic>));
      }
      list.sort((a, b) => a.activity.compareTo(b.activity));
      return list;
    } catch (error) {
      debugPrint('Error in getMasterInterests: ${error.toString()}');
      throw Exception('Failed to get master interests');
    }
  }

  Future<Map<String, dynamic>> postUserInterests(
      UserInterestPostModel userInterestPostModel) async {
    try {
      final response =
          await dio.post(DioConstants.postUserInterests, data: userInterestPostModel.toMap());
      return response.data as Map<String, dynamic>;
    } catch (error) {
      debugPrint('Error in postUserInterests: $error');
      throw Exception('Failed to post user interests');
    }
  }

  Future<int> getUserId(UserIdRequestModel userIdRequestModel) async {
    try {
      final response = await dio.post(
        DioConstants.getUserId,
        data: userIdRequestModel.toMap(),
      );
      // : await dio.get(
      //     DioConstants.getUserId,
      //     data: userIdRequestModel.toMap(),
      //   );
      if (response.data[DioConstants.status] == DioConstants.success) {
        return response.data['user_id'];
      } else {
        throw response.data['message'];
      }
    } catch (e) {
      debugPrint('Error in getUserId: $e');
      throw Exception('Failed to get user id');
    }
  }

  Future<Map<String, dynamic>> getUserData(UserDetailsRequestModel userDetailsRequestModel) async {
    debugPrint("GETTING USER DATA");

    try {
      final response = kIsWeb
          ? await dio.post(
              DioConstants.getUserDetailsWeb,
              data: userDetailsRequestModel.toMap(),
            )
          : await dio.get(
              DioConstants.getUserDetails,
              data: userDetailsRequestModel.toMap(),
            );
      debugPrint("GETTING USER DATA COMPLETE");
      return response.data as Map<String, dynamic>;
    } catch (error) {
      debugPrint("GETTING USER DATA FAILED");
      debugPrint(error.toString());
      throw Exception('FAILED TO GET USER DATA');
    }
  }

  Future<int> postEvent(EventPostModel eventPostModel) async {
    debugPrint("POSTING EVENT");
    debugPrint(eventPostModel.toMap().toString());
    try {
      final response = await dio.post(DioConstants.postEvent, data: eventPostModel.toMap());
      if (response.data[DioConstants.status] == DioConstants.success) {
        debugPrint("POSTING EVENT SUCESSFULL");
        return response.data['id'] as int;
      } else {
        throw "POSTING EVENT FAILED";
      }
    } catch (e) {
      debugPrint("POSTING EVENT FAILED");
      debugPrint(e.toString());
      throw "POSTING EVENT FAILED";
    }
  }

  Future<void> editEvent(EditEventRequestModel editEventRequestModel) async {
    debugPrint("EDITING EVENT");
    debugPrint(editEventRequestModel.toMap().toString());
    try {
      final response = await dio.put(DioConstants.editEvent, data: editEventRequestModel.toMap());
      if (response.data[DioConstants.status] == DioConstants.success) {
        debugPrint("POSTING UPDATED EVENT SUCESSFULL");
      } else {
        throw "EDITING EVENT FAILED";
      }
    } catch (e) {
      debugPrint("EDITING EVENT FAILED");
      debugPrint(e.toString());
      throw "EDITING EVENT FAILED";
    }
  }

  Future<List> fetchEvents(UserEventsRequestModel userEventsRequestModel) async {
    try {
      debugPrint("GETTING ALL EVENTS");
      final data = userEventsRequestModel.toMap();
      final response = kIsWeb
          ? await dio.post(DioConstants.fetchEvents, data: data)
          : await dio.get(DioConstants.fetchEvents, data: data);
      if (response.data[DioConstants.status] == DioConstants.success) {
        final list = response.data['data'] as List;
        // print(response.data['data']);
        debugPrint("GETTING ALL EVENTS SUCCESSFULL");
        return list;
      } else {
        throw 'FAILED TO GET ALL EVENTS';
      }
    } catch (e) {
      debugPrint("FAILED TO GET ALL EVENTS$e");
      throw 'FAILED TO GET ALL EVENTS';
    }
  }

  Future<List> fetchUserEvents() async {
    try {
      debugPrint("GETTING USER EVENTS");
      final data = {
        'user_id': ref.read(userProvider).id,
      };
      final response = await dio.get(DioConstants.fetchUserEvents, data: data);
      if (response.data[DioConstants.status] == DioConstants.success) {
        final list = response.data['data'] as List;
        // print(response.data['data']);
        debugPrint("GETTING USER EVENTS SUCCESSFULL");
        return list;
      } else {
        throw 'FAILED TO GET USER EVENTS';
      }
    } catch (e) {
      debugPrint("FAILED TO GET USER EVENTS$e");
      throw 'FAILED TO GET USER EVENTS';
    }
  }

  Future<Map<String, dynamic>> getEventDetails(int eventId) async {
    try {
      debugPrint("GETTING EVENT DETAILS");
      final userId = box.read(BoxConstants.id) as int;
      final response = kIsWeb
          ? await dio
              .post(DioConstants.getEventDetails, data: {"event_id": eventId, "user_id": userId})
          : await dio
              .get(DioConstants.getEventDetails, data: {"event_id": eventId, "user_id": userId});
      if (response.data[DioConstants.status] == DioConstants.success) {
        debugPrint("GETTING EVENT DETAILS SUCCESSFULL");
        return (response.data['event_details'] as List)[0] as Map<String, dynamic>;
      } else {
        throw 'FAILED TO GET EVENT DETAILS';
      }
    } catch (e) {
      debugPrint("FAILED TO GET EVENT DETAILS: $e");

      throw 'FAILED TO GET EVENT DETAILS';
    }
  }

  Future<List> getUserFavoriteEvents(UserEventsRequestModel userEventsRequestModel) async {
    try {
      debugPrint("GETTING USER EVENTS");
      final response = kIsWeb
          ? await dio.post(DioConstants.getUserFavoriteEventsWeb,
              data: userEventsRequestModel.toMap())
          : await dio.get(DioConstants.getUserFavoriteEvents, data: userEventsRequestModel.toMap());
      if (response.data[DioConstants.status] == DioConstants.success) {
        final list = response.data['favorite_events'] as List;
        debugPrint("GETTING USER EVENTS SUCCESSFULL");
        return list;
      } else {
        throw 'FAILED TO GET USER EVENTS';
      }
    } catch (e) {
      debugPrint(e.toString());
      throw 'FAILED TO GET USER EVENTS';
    }
  }

  Future<void> addEventToFavorite(AddEventToFavoriteModelClass model) async {
    try {
      debugPrint("ADDING EVENT TO FAVORITE");
      final response = await dio.post(DioConstants.addEventToFavorite, data: model.toMap());
      if (response.data[DioConstants.status] == DioConstants.success) {
        debugPrint("ADDING EVENT TO FAVORITE SUCCESSFULL");
      } else {
        throw "ADDING EVENT TO FAVORITE FAILED";
      }
    } catch (e) {
      debugPrint("ADDING EVENT TO FAVORITE FAILED: $e");
    }
  }

  Future<void> removeEventFromFavorite(AddEventToFavoriteModelClass model) async {
    try {
      debugPrint("REMOVING EVENT FROM FAVORITE");
      final response = await dio.put(DioConstants.addEventToFavorite, data: model.toMap());
      if (response.data[DioConstants.status] == DioConstants.success) {
        debugPrint("REMOVING EVENT FROM FAVORITE SUCCESSFULL");
      } else {
        throw "REMOVING EVENT FROM FAVORITE FAILED";
      }
    } catch (e) {
      debugPrint("REMOVING EVENT FROM FAVORITE FAILED: $e");
    }
  }

  void sendEventInvite(EventInvitePostModel eventInvitePostModel) async {
    if (eventInvitePostModel.phoneNumbers.isNotEmpty) {
      try {
        debugPrint("SENDING EVENT INVITE");
        await dio.post(DioConstants.sendInvitation, data: eventInvitePostModel.toMap());
        debugPrint("SENDING EVENT INVITE SUCCESSFULL");
      } catch (e) {
        debugPrint("ERROR SENDING EVENT INVITE: $e");
      }
    }
  }

  Future<void> updateUserDetails(
      UserDetailsUpdateRequestModel userDetailsUpdateRequestModel) async {
    try {
      debugPrint("UPDATING USER DETAILS");
      final res = await dio.put(DioConstants.updateUserDetails,
          data: userDetailsUpdateRequestModel.toMap());
      if (res.data[DioConstants.status] == DioConstants.success) {
        debugPrint("UPDATING USER DETAILS SUCCESSFULL");
      } else {
        debugPrint("UPDATING USER DETAILS FAILED");
      }
    } catch (e) {
      debugPrint("UPDATING USER DETAILS FAILED");
      debugPrint(e.toString());
    }
  }

  Future<void> updateUserInterests(UserInterestsUpdateModel userInterestsUpdateModel) async {
    try {
      debugPrint("UPDATING USER INTERESTS");
      final res = await dio.put(
        DioConstants.updateUserInterests,
        data: userInterestsUpdateModel.toMap(),
      );
      if (res.data[DioConstants.status] == DioConstants.success) {
        debugPrint("UPDATING USER INTERESTS SUCCESSFULL");
      } else {
        debugPrint("UPDATING USER INTERESTS FAILED");
      }
    } catch (e) {
      debugPrint("UPDATING USER INTERESTS FAILED");
      debugPrint(e.toString());
    }
  }

  Future<List<EventInviteMember>> getEventMembers(
      EventMembersRequestModel eventMembersRequestModel) async {
    try {
      final res = kIsWeb
          ? await dio.post(DioConstants.getEventMembers, data: eventMembersRequestModel.toMap())
          : await dio.get(DioConstants.getEventMembers, data: eventMembersRequestModel.toMap());
      if (res.data[DioConstants.status] == DioConstants.success) {
        return EventMembersResponseModel.fromMap(res.data).eventMembers;
      } else {
        throw Exception("Failed to get event members");
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Failed to get event members");
    }
  }

  Future<List<EventRequestMember>> getEventRequestMembers(int eventId) async {
    try {
      final res = kIsWeb
          ? await dio.post(DioConstants.getEventRequestsWeb, data: {"event_id": eventId})
          : await dio.get(DioConstants.getEventRequests, data: {"event_id": eventId});
      if (res.data[DioConstants.status] == DioConstants.success) {
        final list = res.data['event_members'] as List;
        final requests = list.map((e) => EventRequestMember.fromMap(e)).toList();
        return requests;
      } else {
        throw Exception("Failed to get event requests");
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Failed to get event requests");
    }
  }

  Future<void> editUserStatus(int eventId, int userId, String status) async {
    try {
      await dio.put(
        DioConstants.editUserStatus,
        data: {"event_id": eventId, "user_id": userId, "status": status},
      );
      debugPrint("Updated user status");
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Failed to get event requests");
    }
  }

  Future<bool> requestToJoinEvent(JoinEventRequestModel joinEventRequestModel) async {
    try {
      final res =
          await dio.post(DioConstants.requestToJoinEvent, data: joinEventRequestModel.toMap());
      if (res.data[DioConstants.status] == DioConstants.success) {
        debugPrint("REQUEST SENT SUCCESSFULL");
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return false;
  }

  Future<void> addClonedImage(int eventId, String imageUrl) async {
    await dio.post(DioConstants.addClonedImageApi, data: {
      "event_id": eventId,
      "media_url": imageUrl,
    });
  }
}
