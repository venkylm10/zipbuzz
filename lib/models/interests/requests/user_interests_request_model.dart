class UserInterestsRequestModel {
  UserInterestsRequestModel({
    required this.userId,
  });
  late final int userId;

  UserInterestsRequestModel.fromMap(Map<String, dynamic> json) {
    userId = json['user_id'];
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['user_id'] = userId;
    return data;
  }
}
