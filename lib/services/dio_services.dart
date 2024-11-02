import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/env.dart';
import 'package:zipbuzz/models/community/post/add_community_model.dart';
import 'package:zipbuzz/models/community/res/community_details_model.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/events/event_request_member.dart';
import 'package:zipbuzz/models/events/join_request_model.dart';
import 'package:zipbuzz/models/events/notifications/post_notification_model.dart';
import 'package:zipbuzz/models/events/posts/add_fav_event_model_class.dart';
import 'package:zipbuzz/models/events/posts/broadcast_post_model.dart';
import 'package:zipbuzz/models/events/posts/event_invite_post_model.dart';
import 'package:zipbuzz/models/events/posts/event_post_model.dart';
import 'package:zipbuzz/models/events/posts/make_request_model.dart';
import 'package:zipbuzz/models/events/posts/send_invite_notification_model.dart';
import 'package:zipbuzz/models/events/requests/edit_event_model.dart';
import 'package:zipbuzz/models/events/requests/event_members_request_model.dart';
import 'package:zipbuzz/models/events/requests/user_events_request_model.dart';
import 'package:zipbuzz/models/events/responses/event_members_response_model.dart';
import 'package:zipbuzz/models/groups/group_model.dart';
import 'package:zipbuzz/models/groups/post/accept_group_model.dart';
import 'package:zipbuzz/models/groups/post/edit_group_model.dart';
import 'package:zipbuzz/models/groups/post/invite_group_member_model.dart';
import 'package:zipbuzz/models/groups/post/create_group_model.dart';
import 'package:zipbuzz/models/groups/post/log_ticket_model.dart';
import 'package:zipbuzz/models/groups/res/community_and_group_res.dart';
import 'package:zipbuzz/models/groups/res/get_group_display_model.dart';
import 'package:zipbuzz/models/groups/res/group_description_res.dart';
import 'package:zipbuzz/models/groups/res/group_member_res_model.dart';
import 'package:zipbuzz/models/interests/posts/user_interests_post_model.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/models/onboarding_page_model.dart';
import 'package:zipbuzz/models/trace_log_model.dart';
import 'package:zipbuzz/models/user/faq_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_update_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_id_request_model.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/utils/action_code.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/dio_contants.dart';
import 'package:zipbuzz/models/user/post/user_post_model.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/pages/splash/splash_screen.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

final dioServicesProvider = Provider((ref) => DioServices(ref: ref));

class DioServices {
  final Ref ref;
  DioServices({required this.ref});
  Dio dio = Dio(
    BaseOptions(
      baseUrl: AppEnvironment.cloudFunctionBaseUrl,
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
        baseUrl: AppEnvironment.cloudFunctionBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    ).get(DioConstants.getTokenApi);

    final token = res.data['token'] as String;
    debugPrint("Token: $token");
    GetStorage().write(BoxConstants.accessToken, token);
  }

  /// Get latest App version
  Future<bool> isLatestAppVersion() async {
    try {
      final res = await dio.get(DioConstants.versionMaster);
      final latestVersion = res.data['latest_version_data']['version_number'] as String;
      return latestVersion.compareTo(AppEnvironment.appVersion) <= 0;
    } catch (e) {
      debugPrint("Error getting latest version: $e");
      return true;
    }
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

  Future<void> postEventTickets(int eventId, List<String> titles, List<double> prices) async {
    for (int i = 0; i < titles.length; i++) {
      try {
        await dio.post(DioConstants.eventTickets, data: {
          "event_id": eventId,
          "ticket_name": titles[i],
          "ticket_price": prices[i],
        });
      } catch (e) {
        debugPrint("Error posting event tickets: $e");
      }
    }
    debugPrint("Posted event tickets");
  }

  Future<void> editEventTickets(List<TicketType> tickets) async {
    for (var e in tickets) {
      try {
        if (e.id == 0) continue;
        await dio.put(DioConstants.eventTickets, data: {
          'ticket_id': e.id,
          'ticket_price': e.price,
        });
      } catch (e) {
        debugPrint("Error editing event tickets: $e");
      }
    }
    debugPrint("Edited event tickets");
  }

  Future<void> deleteEventTickets(List<TicketType> tickets) async {
    for (var e in tickets) {
      try {
        if (e.id == 0) continue;
        await dio.delete(DioConstants.eventTickets, data: {
          'ticket_id': e.id,
          'ticket_price': e.price,
        });
      } catch (e) {
        debugPrint("Error deleting event tickets: $e");
      }
    }
    debugPrint("Deleted event tickets");
  }

  // make request
  Future<void> makeRequest(MakeRequestModel model) async {
    try {
      await dio.post(DioConstants.makeRequests, data: model.toMap());
      debugPrint("Request made");
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
      debugPrint("Decision increased: $decicion");
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
      rethrow;
    }
  }

  Future<void> updateUserNotification(int notificationId, String notificationType) async {
    debugPrint({
      "notification_id": notificationId,
      "notification_type": notificationType,
    }.toString());
    try {
      await dio.put(DioConstants.userNotification, data: {
        "notification_id": notificationId,
        "notification_type": notificationType,
      });
      debugPrint("Updated user notification: $notificationType");
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateUserNotificationYN(
      int hostId, int senderId, String notificationType, int eventId) async {
    final data = {
      "user_id": hostId, // host id
      "sender_id": senderId,
      "notification_type": notificationType, // yes or no
      "event_id": eventId,
    };
    try {
      await dio.post(DioConstants.userNotification, data: {
        'notification_data': data,
      });
      debugPrint("Updated notification: $notificationType");
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateRespondedNotification(int userId, int senderId,
      {int? eventId, String notificationType = 'accepted', int? groupId}) async {
    final data = {
      "user_id": userId,
      "sender_id": senderId,
      "notification_type": notificationType,
    };
    if (eventId != null) {
      data['event_id'] = eventId;
    }
    if (groupId != null) {
      data['group_id'] = groupId;
    }
    try {
      await dio.put(DioConstants.updateNotification, data: data);
      debugPrint("Updated notification");
    } catch (e) {
      debugPrint("Error updating notification : $e");
      rethrow;
    }
  }

  Future<void> postGroupNotification(PostNotificationModel model) async {
    try {
      await dio.post(DioConstants.postGroupNotification, data: {
        "notification_data": model.toMap(),
      });
      debugPrint("Posted notification");
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
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
      return res.data['user_id'] != null;
    } catch (e) {
      return false;
    }
  }

  Future<int?> getIdFromPhone(String phoneNumber) async {
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
      return res.data['user_id'];
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> checkEmail(String email) async {
    try {
      final res = await dio.post(
        DioConstants.emailCheck,
        data: {"email": email},
      );
      debugPrint("check email: $email ${res.data}");
      return res.data['user_id'] != null;
    } catch (e) {
      debugPrint(e.toString());
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
      final url = res.data['pic_url'] as String;
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.PhotoUpload,
        actionDetails: "Uploaded User Image : $url",
        successFlag: true,
      );
      traceLog(trace);
      return url;
    } catch (error) {
      debugPrint('Error in putUserImage: $error');
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.PhotoUpload,
        actionDetails: "Failed To Upload User Image",
        successFlag: false,
      );
      traceLog(trace);
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
      final url = res.data['pic_url'] as String;
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.PhotoUpload,
        actionDetails: "Uploaded Event Banner : $url",
        successFlag: true,
      );
      traceLog(trace);
      return url;
    } catch (error) {
      debugPrint('Error in postEventBanner: $error');
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.PhotoUpload,
        actionDetails: "Failed To Upload Event Banner",
        successFlag: true,
      );
      traceLog(trace);
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
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.PhotoUpload,
        actionDetails: "Uploaded Event Images",
        successFlag: true,
        eventId: eventId,
      );
      traceLog(trace);
    } catch (error) {
      debugPrint('Error in postEventImages: $error');
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.PhotoUpload,
        actionDetails: "Failed To Upload Event Images",
        successFlag: false,
        eventId: eventId,
      );
      traceLog(trace);
      throw ('Failed to post Event Images');
    }
  }

  Future<List<InterestModel>> getAllInterests() async {
    try {
      final response = await dio.get(DioConstants.allCategories);
      var list = <InterestModel>[];
      for (var item in (response.data['category_data'] as List)) {
        list.add(InterestModel.fromMap(item as Map<String, dynamic>));
        unsortedInterests.add(InterestModel.fromMap(item));
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

  Future<int?> getUserId(UserIdRequestModel userIdRequestModel) async {
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
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserData(int userId) async {
    debugPrint("GETTING USER DATA");

    try {
      final response = kIsWeb
          ? await dio.post(
              DioConstants.getUserDetailsWeb,
              data: {'user_id': userId},
            )
          : await dio.get(
              DioConstants.getUserDetails,
              data: {'user_id': userId},
            );
      debugPrint("GETTING USER DATA COMPLETE");
      return response.data as Map<String, dynamic>;
    } catch (error) {
      debugPrint("GETTING USER DATA FAILED");
      debugPrint(error.toString());
      await GetStorage().erase();
      navigatorKey.currentState!.pushNamedAndRemoveUntil(SplashScreen.id, (route) => false);
      throw Exception('FAILED TO GET USER DATA');
    }
  }

  Future<int> createEvent(EventPostModel eventPostModel) async {
    debugPrint("CREATING EVENT");
    debugPrint(eventPostModel.toMap().toString());
    try {
      final response = await dio.post(DioConstants.postEvent, data: eventPostModel.toMap());
      debugPrint("CREATING EVENT SUCESSFULL");
      int id = response.data['id'] as int;
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.CreateEvent,
        actionDetails: "Create Event",
        successFlag: true,
        eventId: id,
      );
      traceLog(trace);
      return id;
    } catch (e) {
      debugPrint("CREATING EVENT FAILED");
      debugPrint(e.toString());
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.CreateEvent,
        actionDetails: "Create Event Failed",
        successFlag: false,
      );
      traceLog(trace);
      throw "CREATING EVENT FAILED";
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
      final response = kIsWeb
          ? await dio.post(DioConstants.fetchUserEventsWeb, data: data)
          : await dio.get(DioConstants.fetchUserEvents, data: data);
      final list = response.data['data'] as List;
      debugPrint("GETTING USER EVENTS SUCCESSFULL");
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.MyEventUpcoming,
        actionDetails: "Fetch User Events",
        successFlag: true,
      );
      traceLog(trace);
      final trace2 = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.MyEventPast,
        actionDetails: "Fetch User Events",
        successFlag: true,
      );
      traceLog(trace2);
      return list;
    } catch (e) {
      debugPrint("FAILED TO GET USER EVENTS$e");
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.MyEventUpcoming,
        actionDetails: "Fetch User Events Failed",
        successFlag: false,
      );
      traceLog(trace);
      final trace2 = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.MyEventPast,
        actionDetails: "Fetch User Events Failed",
        successFlag: false,
      );
      traceLog(trace2);
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
      debugPrint("GETTING USER FAVORITE EVENTS");
      final response = kIsWeb
          ? await dio.post(DioConstants.getUserFavoriteEventsWeb,
              data: userEventsRequestModel.toMap())
          : await dio.get(DioConstants.getUserFavoriteEvents, data: userEventsRequestModel.toMap());
      if (response.data[DioConstants.status] == DioConstants.success) {
        final list = response.data['favorite_events'] as List;
        debugPrint("GETTING USER FAVORITE EVENTS SUCCESSFULL");
        return list;
      } else {
        throw 'FAILED TO GET USER FAVORITE EVENTS';
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

  Future<void> sendEventInvite(EventInvitePostModel eventInvitePostModel) async {
    if (eventInvitePostModel.phoneNumbers.isNotEmpty) {
      try {
        debugPrint("SENDING EVENT INVITE");
        await dio.post(DioConstants.sendInvitation, data: eventInvitePostModel.toMap());
        debugPrint("SENDING EVENT INVITE SUCCESSFULL");
        final user = ref.read(userProvider);
        final trace = TraceLogModel(
          userId: user.id,
          actionCode: ActionCode.EventInvSent,
          actionDetails: "Create Event Invite Success",
          successFlag: true,
          eventId: eventInvitePostModel.eventId,
        );
        traceLog(trace);
      } catch (e) {
        debugPrint("ERROR SENDING EVENT INVITE: $e");
        final user = ref.read(userProvider);
        final trace = TraceLogModel(
          userId: user.id,
          actionCode: ActionCode.EventInvSent,
          actionDetails: "Create Event Invite Failure",
          successFlag: false,
          eventId: eventInvitePostModel.eventId,
        );
        traceLog(trace);
      }
    }
  }

  Future<void> updateUserDetails(
      UserDetailsUpdateRequestModel userDetailsUpdateRequestModel) async {
    final user = ref.read(userProvider);
    final details = userDetailsUpdateRequestModel;
    final interests = details.interests.join(',');
    try {
      debugPrint("UPDATING USER DETAILS");
      await dio.put(DioConstants.updateUserDetails, data: userDetailsUpdateRequestModel.toMap());
      debugPrint("UPDATING USER DETAILS SUCCESSFULL");
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.ProfileUpdate,
        actionDetails:
            "Name=${user.id} Email=${details.email} Phone=${details.phoneNumber} Pic=${details.profilePicture} Interests=[$interests]",
        successFlag: true,
      );
      traceLog(trace);
    } catch (e) {
      debugPrint("UPDATING USER DETAILS FAILED");
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.ProfileUpdate,
        actionDetails:
            "Name=${user.id} Email=${details.email} Phone=${details.phoneNumber} Pic=${details.profilePicture} Interests=[$interests]",
        successFlag: false,
      );
      traceLog(trace);
      debugPrint(e.toString());
    }
  }

  Future<void> updateUserInterests(UserInterestsUpdateModel userInterestsUpdateModel) async {
    try {
      debugPrint("UPDATING USER INTERESTS");
      // showSnackBar(message: "Running ${userInterestsUpdateModel.toMap()}");
      final res = await dio.put(
        DioConstants.updateUserInterests,
        data: userInterestsUpdateModel.toMap(),
      );
      // showSnackBar(message: "3 ${res.data[DioConstants.status]}");
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

  Future<void> deleteAccount(int userId) async {
    await dio.post(DioConstants.deleteAccountApi, data: {
      "user_id": userId,
    });
  }

  Future<List<FaqModel>> getUserFaqs() async {
    try {
      final res = await dio.get(DioConstants.getUserFaqs);
      final list = res.data['category_data'] as List;
      return list.map((e) => FaqModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Error getting user faqs: $e");
      rethrow;
    }
  }

  Future<void> updateRsvp(int eventId, int userId, int members, String status) async {
    try {
      final data = {
        "event_id": eventId,
        "user_id": userId,
        "members": members,
        "status": status,
      };
      await dio.put(DioConstants.updateRsvp, data: data);
      debugPrint("Updated RSVP to ${status == 'pending' ? "yes" : "no"}");
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.TextSent,
        actionDetails: "Updated RSVP to ${status == 'pending' ? "yes" : "no"}",
        successFlag: true,
        eventId: eventId,
      );
      traceLog(trace);
    } catch (e) {
      debugPrint(e.toString());
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.TextSent,
        actionDetails: "Updated RSVP to ${status == 'pending' ? "yes" : "no"} Failed",
        successFlag: false,
        eventId: eventId,
      );
      traceLog(trace);
      rethrow;
    }
  }

  Future<void> sendInviteNotification(SendInviteNotificationModel model) async {
    try {
      await dio.post(DioConstants.sendInviteNotification, data: model.toMap());
      debugPrint("Invite notification sent");
      showSnackBar(message: "Invite notification sent successfully");
    } catch (e) {
      debugPrint("Error sending invite notification: $e");
      rethrow;
    }
  }

  Future<void> sendBroadcastMessage(BroadcastPostModel model) async {
    try {
      await dio.post(DioConstants.sendBroadcastMessage, data: model.toJson());
      debugPrint("Broadcast message sent");
      showSnackBar(message: "Broadcast message sent successfully");
    } catch (e) {
      debugPrint("Error sending broadcast message: $e");
      rethrow;
    }
  }

  Future<int?> sendOTP(String number) async {
    try {
      final res = await dio.get(DioConstants.sendMobileOTP, data: {
        'phone_number': number,
      });
      return res.data['otp'];
    } catch (e) {
      debugPrint("Error sending otp: $e");
      return null;
    }
  }

  // Groups

  /// Add Image To Group Before Creating To Get Image URLs
  Future<Map<String, String>> addGroupImages(File image, File banner) async {
    final form = FormData.fromMap({
      'group_image': await MultipartFile.fromFile(image.path, filename: image.path.split('/').last),
      'banner_image':
          await MultipartFile.fromFile(banner.path, filename: banner.path.split('/').last),
    });
    try {
      final res = await dio.post(DioConstants.addGroupImages, data: form);
      final imageUrl = res.data['group_image_url'] as String;
      final bannerUrl = res.data['banner_image_url'] as String;
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.PhotoUpload,
        actionDetails: "Uploaded Group Images : $imageUrl, $bannerUrl",
        successFlag: true,
      );
      traceLog(trace);
      return {
        'group_image_url': imageUrl,
        'group_banner_url': bannerUrl,
      };
    } catch (e) {
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.PhotoUpload,
        actionDetails: "Failed To Group Images",
        successFlag: false,
      );
      traceLog(trace);
      debugPrint("Error adding group images: $e");
      rethrow;
    }
  }

  /// Create Group
  Future<int> createGroup(CreateGroupModel model) async {
    try {
      final res = await dio.post(DioConstants.createGroup, data: model.toJson());
      final id = res.data['query_details']['group_id'] as int;
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.GroupCreate,
        actionDetails: "Created Group : $id",
        groupId: id,
        successFlag: true,
      );
      traceLog(trace);
      return id;
    } catch (e) {
      debugPrint("Error creating group: $e");
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.GroupCreate,
        actionDetails: "Failed To Created Group",
        successFlag: false,
      );
      traceLog(trace);
      rethrow;
    }
  }

  /// Fetch Group Descriptions
  Future<GroupDescriptionRes> getGroupDescriptions(int userId) async {
    try {
      final res = await dio.post(DioConstants.getUserGroupDescription, data: {
        'user_id': userId,
      });
      return GroupDescriptionRes.fromJson(res.data);
    } catch (e) {
      debugPrint("Error get user group descritpions : $e");
      rethrow;
    }
  }

  Future<CommunityAndGroupRes> getCommunityAndGroupsDescriptions(int userId) async {
    try {
      final res = await dio.post(DioConstants.getCommunityAndGroupsForUser, data: {
        'user_id': userId,
      });
      return CommunityAndGroupRes.fromJson(res.data);
    } catch (e) {
      debugPrint("Error get community descriptions : $e");
      rethrow;
    }
  }

  /// Fetch group display details
  Future<GroupModel> getGroupDetails(int userId, int groupId) async {
    try {
      final res = await dio.post(DioConstants.getGroupDetails, data: {
        'user_id': userId,
        'group_id': groupId,
      });
      return GroupDisplayResModel.fromJson(res.data).group;
    } catch (e) {
      debugPrint("Error get group details : $e");
      rethrow;
    }
  }

  Future<GroupMemberResModel> getGroupMembers(int groupId) async {
    try {
      final res = await dio.post(DioConstants.getGroupMembers, data: {
        'group_id': groupId,
      });
      return GroupMemberResModel.fromJson(res.data);
    } catch (e) {
      debugPrint("Error get group members : $e");
      rethrow;
    }
  }

  Future<void> archiveGroup(int userId, int groupId) async {
    try {
      await dio.post(DioConstants.archiveGroup, data: {
        'user_id': userId,
        'group_id': groupId,
      });
    } catch (e) {
      debugPrint("Error archiving group: $e");
      rethrow;
    }
  }

  Future<void> inviteToGroup(InviteGroupMemberModel model) async {
    try {
      await dio.post(DioConstants.inviteGroupMember, data: model.toJson());
      debugPrint("Invited user ${model.userId} to group ${model.groupId}");
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.GroupInvite,
        actionDetails:
            "Invited user ${model.userId} (${model.phoneNumber}) to group ${model.groupId}",
        groupId: model.groupId,
        successFlag: true,
      );
      traceLog(trace);
    } catch (e) {
      debugPrint("Error add member to group: $e");
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.GroupInvite,
        actionDetails:
            "Failed To Invite user ${model.userId} (${model.phoneNumber}) to group ${model.groupId}",
        groupId: model.groupId,
        successFlag: false,
      );
      traceLog(trace);
      rethrow;
    }
  }

  Future<void> acceptGroup(AcceptGroupModel model) async {
    try {
      await dio.post(DioConstants.acceptInvite, data: model.toJson());
      debugPrint("Accepted Group ${model.groupId}");
    } catch (e) {
      debugPrint("Error accepting group: $e");
      rethrow;
    }
  }

  Future<void> deleteGroupMember(int userId, int groupId) async {
    try {
      await dio.post(DioConstants.deleteMember, data: {
        'user_id': userId,
        'group_id': groupId,
      });
      debugPrint("Removed user $userId from group $groupId");
    } catch (e) {
      debugPrint("Error removing $userId from group $groupId : $e");
      rethrow;
    }
  }

  Future<void> updateGroupMember(int userId, int groupId, String permissionType) async {
    try {
      await dio.post(DioConstants.updateMember, data: {
        'user_id': userId,
        'group_id': groupId,
        'permission_type': permissionType,
      });
      debugPrint("Updated permission to $permissionType for user $userId in group $groupId");
    } catch (e) {
      debugPrint(
          "Error Updated permission to $permissionType for user $userId in group $groupId : $e");
      rethrow;
    }
  }

  Future<int> createGroupEvent(EventPostModel eventPostModel) async {
    debugPrint("POSTING EVENT");
    debugPrint(eventPostModel.toMap().toString());
    try {
      final response = await dio.post(DioConstants.createGroupEvent, data: eventPostModel.toMap());
      final id = response.data['id'] as int;
      debugPrint("POSTING GROUP EVENT SUCESSFULL");
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.CreateEvent,
        actionDetails: "Create Group Event Invite Success",
        successFlag: true,
        eventId: id,
        groupId: eventPostModel.groupId!,
      );
      traceLog(trace);
      return id;
    } catch (e) {
      debugPrint("POSTING GROUP EVENT FAILED");
      debugPrint(e.toString());
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.CreateEvent,
        actionDetails: "Create Group Event Invite Failed",
        successFlag: false,
        groupId: eventPostModel.groupId!,
      );
      traceLog(trace);
      throw "POSTING GROUP EVENT FAILED";
    }
  }

  Future<List> getGroupEvents(int groupId, int userId, String month) async {
    try {
      final data = {
        'group_id': groupId,
        'user_id': userId,
        'month': month,
      };
      final res = await dio.get(DioConstants.getGroupEvents, data: data);
      final events = res.data['data'] as List;
      return events;
    } catch (e) {
      debugPrint("Error getting group events: $e");
      rethrow;
    }
  }

  Future<String?> uploadInvidualGroupImage(File image, {bool profileImage = true}) async {
    try {
      final path = profileImage ? DioConstants.uploadMainImage : DioConstants.uploadBannerImage;
      final imageName = image.path.split('/').last;
      final key = profileImage ? 'group_image' : 'banner_image';
      final formData = FormData.fromMap({
        key: await MultipartFile.fromFile(image.path, filename: imageName),
      });
      final res = await dio.post(path, data: formData);
      final url = profileImage ? res.data['group_image_url'] : res.data['banner_image_url'];
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.PhotoUpload,
        actionDetails: "Uploaded Group ${profileImage ? "Profile" : "Banner"} Image : $url ",
        successFlag: true,
      );
      traceLog(trace);
      return url;
    } catch (e) {
      debugPrint("Error uploading individual group image: $e");
      final user = ref.read(userProvider);
      final trace = TraceLogModel(
        userId: user.id,
        actionCode: ActionCode.PhotoUpload,
        actionDetails: "Failed To Upload Group ${profileImage ? "Profile" : "Banner"} Image",
        successFlag: false,
      );
      traceLog(trace);
      return null;
    }
  }

  Future<void> updateGroup(EditGroupModel model) async {
    try {
      await dio.post(DioConstants.updateGroup, data: model.toJson());
    } catch (e) {
      debugPrint("Error updating group: $e");
      rethrow;
    }
  }

  void traceLog(TraceLogModel trace) async {
    try {
      await dio.post(DioConstants.traceLog, data: trace.toJson());
      debugPrint("Logged action: ${trace.actionDetails}");
    } catch (e) {
      debugPrint("Error logging: $e");
    }
  }

  Future<void> createTicketLog(LogTicketModel model) async {
    await dio.post(DioConstants.logTicket, data: model.toJson());
    debugPrint("Logged Ticket");
  }

  Future<String> addCommunityImage(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final data = FormData.fromMap({
        'community_image': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      final res = await dio.post(DioConstants.communityImage, data: data);
      return res.data['community_image_url'];
    } catch (e) {
      debugPrint("Error adding community image: $e");
      rethrow;
    }
  }

  Future<String> addCommunityBanner(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final data = FormData.fromMap({
        'community_banner': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      final res = await dio.post(DioConstants.communityBanner, data: data);
      return res.data['community_banner_url'];
    } catch (e) {
      debugPrint("Error adding community banner: $e");
      rethrow;
    }
  }

  Future<void> createCommunity(AddCommunityModel model) async {
    try {
      final res = await dio.post(DioConstants.addCommunity, data: model.toJson());
      print(res.data);
    } catch (e) {
      debugPrint("Error creating community: $e");
      rethrow;
    }
  }

  Future<CommunityDetailsModel> getCommunityDetails(int userId, int communityId) async {
    try {
      final res = await dio.post(DioConstants.getCommunityDetails, data: {
        'user_id': userId,
        'community_id': communityId,
      });
      return CommunityDetailsModel.fromJson(res.data['community_data']);
    } catch (e) {
      debugPrint("Error getting community details: $e");
      rethrow;
    }
  }
}
