class UserEventsRequestModel {
  final String userId;
  const UserEventsRequestModel({required this.userId});

  UserEventsRequestModel copyWith({
    String? userId,
  }) {
    return UserEventsRequestModel(
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
    };
  }

  factory UserEventsRequestModel.fromMap(Map<String, dynamic> map) {
    return UserEventsRequestModel(
      userId: map['user_id'] as String,
    );
  }
}
