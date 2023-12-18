class UserSocialsModel {
  UserSocialsModel({
    required this.instagram,
    required this.linkedin,
    required this.twitter,
  });
  late final String instagram;
  late final String linkedin;
  late final String twitter;

  UserSocialsModel.fromMap(Map<String, dynamic> json) {
    instagram = json['instagram'];
    linkedin = json['linkedin'];
    twitter = json['twitter'];
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['instagram'] = instagram;
    data['linkedin'] = linkedin;
    data['twitter'] = twitter;
    return data;
  }
}
