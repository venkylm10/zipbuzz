class UserIdRequestModel {
  final String email;
  final String? deviceToken;
  const UserIdRequestModel({
    required this.email,
    required this.deviceToken,
  });

  UserIdRequestModel copyWith({
    String? email,
    String? deviceToken,
  }) {
    return UserIdRequestModel(
      email: email ?? this.email,
      deviceToken: deviceToken ?? this.deviceToken,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'device_token': deviceToken,
    };
  }

  factory UserIdRequestModel.fromMap(Map<String, dynamic> map) {
    return UserIdRequestModel(
      email: map['email'] as String,
      deviceToken: map['device_token'] as String,
    );
  }
}
