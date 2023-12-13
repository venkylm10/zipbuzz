import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/events/posts/event_post_model.dart';
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

  Future<Map<String, dynamic>> createUser(UserPostModel userPostModel) async {
    try {
      final response =
          await dio.post(DioConstants.createUser, data: userPostModel.toJson());
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
      final response = await dio.get(DioConstants.postUserInterests,
          data: userInterestPostModel.toJson());
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
        return UserInterestPostModel.fromJson(response.data).interests;
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
      final response = await dio.get(DioConstants.getUserId,
          data: userIdRequestModel.toMap());
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

  Future<Map<String, dynamic>> getUserData(
      UserDetailsRequestModel userDetailsRequestModel) async {
    debugPrint("GETTING USER DATA");
    try {
      final response = await dio.get(DioConstants.getUserDetails,
          data: userDetailsRequestModel.toJson());
      return response.data as Map<String, dynamic>;
    } catch (error) {
      debugPrint('Error in postUserInterests: $error');
      throw Exception('Failed to post user interests');
    }
  }

  Future<void> postEvent(EventPostModel eventPostModel) async {
    debugPrint("POSTING EVENT");
    try {
      print(eventPostModel.toJson());

      final response =
          await dio.post(DioConstants.postEvent, data: eventPostModel.toJson());
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
}
