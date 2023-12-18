import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/models/events/posts/event_invite_post_model.dart';
import 'package:zipbuzz/models/events/posts/event_post_model.dart';
import 'package:zipbuzz/models/events/requests/user_events_request_model.dart';
import 'package:zipbuzz/models/interests/posts/user_interests_post_model.dart';
import 'package:zipbuzz/models/user_model/requests/user_details_request_model.dart';
import 'package:zipbuzz/models/user_model/requests/user_id_request_model.dart';
import 'package:zipbuzz/utils/constants/dio_contants.dart';
import 'package:zipbuzz/models/user_model/post/user_post_model.dart';

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

  Future<Map<String, dynamic>> postUserInterests(UserInterestPostModel userInterestPostModel) async {
    try {
      final response = await dio.post(DioConstants.postUserInterests, data: userInterestPostModel.toMap());
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
      final response = await dio.get(DioConstants.getUserDetails, data: userDetailsRequestModel.toMap());
      debugPrint("GETTING USER DATA COMPLETE");
      return response.data as Map<String, dynamic>;
    } catch (error) {
      debugPrint("GETTING USER DATA FAILED");
      debugPrint(error.toString());
      if (box.hasData('user_details')) {
        debugPrint("LOADING USER DATA FROM LOCAL STORAGE");
        final details = box.read('user_details') as Map<String, dynamic>;
        final interests = box.read('user_interests') as List;
        final res = {
          "status": "success",
          "data": details,
          "interests": interests.map((e) => e.toString()).toList(),
        };
        return res;
      } else {
        throw Exception('FAILED TO GET USER DATA');
      }
    }
  }

  Future<void> postEvent(EventPostModel eventPostModel) async {
    debugPrint("POSTING EVENT");
    try {
      final response = await dio.post(DioConstants.postEvent, data: eventPostModel.toMap());
      if (response.data[DioConstants.status] == DioConstants.success) {
        debugPrint("POSTING EVENT SUCESSFULL");
      } else {
        debugPrint("POSTING EVENT FAILED");
      }
    } catch (e) {
      debugPrint("POSTING EVENT FAILED");
      debugPrint(e.toString());
    }
  }

  Future<List> getUserEvents(UserEventsRequestModel userEventsRequestModel) async {
    try {
      debugPrint("GETTING USER EVENTS");
      final response = await dio.get(DioConstants.getUserEvents, data: userEventsRequestModel.toMap());
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
    try {
      debugPrint("SENDING EVENT INVITE");
      await dio.post(DioConstants.sendInvitation, data: eventInvitePostModel.toMap());
    } catch (e) {
      debugPrint("ERROR SENDING EVENT INVITE: $e");
    }
  }
}
