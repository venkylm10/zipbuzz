class UserIdRequestModel {
  final String email;
  const UserIdRequestModel({
    required this.email,
  });

  UserIdRequestModel copyWith({
    String? email,
  }) {
    return UserIdRequestModel(
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
    };
  }

  factory UserIdRequestModel.fromMap(Map<String, dynamic> map) {
    return UserIdRequestModel(
      email: map['email'] as String,
    );
  }
}
