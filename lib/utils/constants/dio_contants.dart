class DioConstants {
  static const String baseUrl = "http://13.51.247.140";
  static const String createUser = "$baseUrl/users/create_user/";
  static const String getUserId = "$baseUrl/users/sign_in/";
  static const String getUserDetails = "$baseUrl/users/fetch_user/";
  static const String updateUserDetails = "$baseUrl/users/update_user/";
  static const String postUserImage = "$baseUrl/users/user_profile_picture/";
  static const String getAllEvents = "$baseUrl/events/fetch_events/";
  static const String getUserFavoriteEvents = '$baseUrl/events/event_favorite/';
  static const String addEventToFavorite = "$baseUrl/events/event_favorite/";
  static const String masterInterests = "$baseUrl/users/master_interest/";
  static const String postUserInterests = "$baseUrl/users/user_interest/";
  static const String getUserInterests = "$baseUrl/users/user_interest/";
  static const String updateUserInterests = "$baseUrl/users/user_interest/";
  static const String postEventBanner = "$baseUrl/events/event_banner/";
  static const String postEventImages = "$baseUrl/events/event_images/";
  static const String postEvent = "$baseUrl/events/create_event/";
  static const String editEvent = '$baseUrl/events/edit_event/';
  static const String sendInvitation = "$baseUrl/users/invite_user/";
  static const String getEventMembers = "$baseUrl/events/event_members/";
  static const String getEventRequests = "$baseUrl/events/event_request/";
  static const String editUserStatus = "$baseUrl/events/event_request/";
  static const String getLocation = "$baseUrl/users/user_location/";

  static const String status = "status";
  static const String success = "success";
}
