class UserDetailsUpdateRequestModel {
  final int id;
  final String phoneNumber;
  final String zipcode;
  final String email;
  final String profilePicture;
  final String description;
  final String username;
  final bool isAmbassador;
  final String instagram;
  final String twitter;
  final String linkedin;

  UserDetailsUpdateRequestModel({
    required this.id,
    required this.phoneNumber,
    required this.zipcode,
    required this.email,
    required this.profilePicture,
    required this.description,
    required this.username,
    required this.isAmbassador,
    required this.instagram,
    required this.linkedin,
    required this.twitter,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pk': id,
      'phone_number': phoneNumber,
      'zipcode': zipcode,
      'email': email,
      'profile_picture': profilePicture,
      'description': description,
      'username': username,
      'is_ambassador': isAmbassador,
      'instagram': instagram,
      'linkedin': linkedin,
      'twitter': twitter,

    };
  }

  factory UserDetailsUpdateRequestModel.fromMap(Map<String, dynamic> map) {
    return UserDetailsUpdateRequestModel(
      id: map['id'] as int,
      phoneNumber: map['phone_number'] as String,
      zipcode: map['zipcode'] as String,
      email: map['email'] as String,
      profilePicture: map['profilePicture'] as String,
      description: map['description'] as String,
      username: map['username'] as String,
      isAmbassador: map['is_ambassador'] as bool,
      instagram: map['instagram'] as String,
      linkedin: map['linkedin'] as String,
      twitter: map['twitter'] as String,
    );
  }
}
