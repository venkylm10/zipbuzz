class UserInterestsUpdateModel {
  final int userId;
  final List<String> interests;
  UserInterestsUpdateModel({
    required this.userId,
    required this.interests,
  });

  UserInterestsUpdateModel copyWith({
    int? userId,
    List<String>? interests,
  }) {
    return UserInterestsUpdateModel(
      userId: userId ?? this.userId,
      interests: interests ?? this.interests,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'interests': interests,
    };
  }

  factory UserInterestsUpdateModel.fromMap(Map<String, dynamic> map) {
    return UserInterestsUpdateModel(
      userId: map['user_id'] as int,
      interests: (map['interests'] as List).map((e) => e.toString()).toList(),
    );
  }
}
