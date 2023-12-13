class UserInterestResponseModel {
  UserInterestResponseModel({
    required this.status,
    required this.interests,
  });
  late final String status;
  late final List<String> interests;

  UserInterestResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    interests = List.castFrom<dynamic, String>(json['interests']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['interests'] = interests;
    return data;
  }
}
