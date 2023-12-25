import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/models/events/event_request_member.dart';
import 'package:zipbuzz/models/events/posts/event_invite_post_model.dart';
import 'package:zipbuzz/models/events/posts/event_post_model.dart';
import 'package:zipbuzz/models/events/requests/edit_event_model.dart';
import 'package:zipbuzz/models/events/requests/event_members_request_model.dart';
import 'package:zipbuzz/models/events/requests/user_events_request_model.dart';
import 'package:zipbuzz/models/events/responses/event_resonse_modal_class.dart';
import 'package:zipbuzz/models/interests/posts/user_interests_post_model.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_update_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_id_request_model.dart';
import 'package:zipbuzz/utils/constants/dio_contants.dart';
import 'package:zipbuzz/models/user/post/user_post_model.dart';

final dioServicesProvider = Provider((ref) => DioServices());

class DioServices {
  Dio dio = Dio(
    BaseOptions(
      baseUrl: DioConstants.baseUrl,
      connectTimeout: const Duration(seconds: 7),
      receiveTimeout: const Duration(seconds: 7),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  final box = GetStorage();

  Future<Map<String, dynamic>> createUser(UserPostModel userPostModel) async {
    try {
      final response = await dio.post(DioConstants.createUser, data: userPostModel.toMap());
      return response.data as Map<String, dynamic>;
    } catch (error) {
      debugPrint('Error in postUser: $error');
      throw ('Failed to post user');
    }
  }

  Future<Map<String, dynamic>> getMasterInterests() async {
    try {
      final response = await dio.get(DioConstants.masterInterests);
      return response.data as Map<String, dynamic>;
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

  Future<List<String>> getInterests(int id) async {
    try {
      final response = await dio.get(DioConstants.getUserInterests, data: {
        "user_id": id,
      });

      if (response.data[DioConstants.status] == DioConstants.success) {
        return UserInterestPostModel.fromMap(response.data).interests;
      } else {
        return [];
      }
    } catch (error) {
      debugPrint('Error in getInterests: $error');
      throw Exception('Failed to get interests');
    }
  }

  Future<int> getUserId(UserIdRequestModel userIdRequestModel) async {
    try {
      final response = await dio.get(DioConstants.getUserId, data: userIdRequestModel.toMap());
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
      final response =
          await dio.get(DioConstants.getUserDetails, data: userDetailsRequestModel.toMap());
      debugPrint("GETTING USER DATA COMPLETE");
      box.write('user_details', response.data['data']);
      box.write('user_interests', response.data['interests']);
      box.write('user_socials', response.data['socials']);
      return response.data as Map<String, dynamic>;
    } catch (error) {
      debugPrint("GETTING USER DATA FAILED");
      debugPrint(error.toString());
      if (box.hasData('user_details')) {
        debugPrint("LOADING USER DATA FROM LOCAL STORAGE");
        final details = box.read('user_details') as Map<String, dynamic>;
        final interests = box.read('user_interests') as List;
        final socials = box.read('user_socials') as Map<String, dynamic>;
        final res = {
          "status": "success",
          "data": details,
          "interests": interests.map((e) => e.toString()).toList(),
          "socials": socials,
        };
        return res;
      } else {
        throw Exception('FAILED TO GET USER DATA');
      }
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

  Future<List> getUserEvents(UserEventsRequestModel userEventsRequestModel) async {
    try {
      debugPrint("GETTING USER EVENTS");
      final response =
          await dio.get(DioConstants.getUserEvents, data: userEventsRequestModel.toMap());
      if (response.data[DioConstants.status] == DioConstants.success) {
        final list = response.data['data'] as List;
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

  Future<void> sendEventInvite(EventInvitePostModel eventInvitePostModel) async {
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
      final res =
          await dio.get(DioConstants.getEventMembers, data: eventMembersRequestModel.toMap());
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
      final res = await dio.get(DioConstants.getEventRequests, data: {"event_id": eventId});
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

  Future<void> editUserStatus(int id, String status) async {
    try {
      await dio.put(DioConstants.editUserStatus, data: {"user_event_id": id, "status": status});
      debugPrint("Updated user status");
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Failed to get event requests");
    }
  }
}
