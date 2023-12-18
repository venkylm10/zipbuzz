class UserInterestPostModel {
  UserInterestPostModel({
    required this.userId,
    required this.interests,
  });
  late final int userId;
  late final List<String> interests;

  UserInterestPostModel.fromMap(Map<String, dynamic> json) {
    userId = json['user_id'];
    interests = List.castFrom<dynamic, String>(json['interests']);
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['user_id'] = userId;
    data['interests'] = interests;
    return data;
  }
}
