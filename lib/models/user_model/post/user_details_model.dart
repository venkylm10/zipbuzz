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
  late final String phoneNumber;
  late final String zipcode;
  late final String email;
  late final String profilePicture;
  late final String description;
  late final String username;
  late final bool isAmbassador;

  UserDetailsModel.fromMap(Map<String, dynamic> json) {
    phoneNumber = json['phone_number'];
    zipcode = json['zipcode'];
    email = json['email'];
    profilePicture = json['profile_picture'];
    description = json['description'];
    username = json['username'];
    isAmbassador = json['is_ambassador'];
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['phone_number'] = phoneNumber;
    data['zipcode'] = zipcode;
    data['email'] = email;
    data['profile_picture'] = profilePicture;
    data['description'] = description;
    data['username'] = username;
    data['is_ambassador'] = isAmbassador;
    return data;
  }
}
