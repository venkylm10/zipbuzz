import 'package:zipbuzz/models/user_model/post/user_details_model.dart';
import 'package:zipbuzz/models/user_model/post/user_socials_model.dart';

class UserPostModel {
  UserPostModel({
    required this.userDetails,
    required this.userSocials,
  });
  late final UserDetailsModel userDetails;
  late final UserSocialsModel userSocials;

  UserPostModel.fromJson(Map<String, dynamic> json) {
    userDetails = UserDetailsModel.fromJson(json['user_details']);
    userSocials = UserSocialsModel.fromJson(json['user_socials']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['user_details'] = userDetails.toJson();
    data['user_socials'] = userSocials.toJson();
    return data;
  }
}
