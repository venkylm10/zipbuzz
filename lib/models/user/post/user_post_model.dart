import 'package:zipbuzz/models/user/post/user_details_model.dart';
import 'package:zipbuzz/models/user/post/user_socials_model.dart';

class UserPostModel {
  UserPostModel({
    required this.userDetails,
    required this.userSocials,
  });
  late final UserDetailsModel userDetails;
  late final UserSocialsModel userSocials;

  UserPostModel.fromMap(Map<String, dynamic> json) {
    userDetails = UserDetailsModel.fromMap(json['user_details']);
    userSocials = UserSocialsModel.fromMap(json['user_socials']);
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['user_details'] = userDetails.toMap();
    data['user_socials'] = userSocials.toMap();
    return data;
  }
}
