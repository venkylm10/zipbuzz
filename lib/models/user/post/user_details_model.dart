class UserDetailsModel {
  UserDetailsModel({
    required this.phoneNumber,
    required this.zipcode,
    required this.email,
    required this.profilePicture,
    required this.description,
    required this.username,
    required this.isAmbassador,
  });
  final String phoneNumber;
  final String zipcode;
  final String email;
  final String profilePicture;
  final String description;
  final String username;
  final bool isAmbassador;


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'phone_number': phoneNumber,
      'zipcode': zipcode,
      'email': email,
      'profile_picture': profilePicture,
      'description': description,
      'username': username,
      'is_ambassador': isAmbassador,
    };
  }

  factory UserDetailsModel.fromMap(Map<String, dynamic> map) {
    return UserDetailsModel(
      phoneNumber: map['phone_number'] as String,
      zipcode: map['zipcode'] as String,
      email: map['email'] as String,
      profilePicture: map['profile_picture'] as String,
      description: map['description'] as String,
      username: map['username'] as String,
      isAmbassador: map['is_ambassador'] as bool,
    );
  }
}
