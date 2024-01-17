class InterestModel {
  int id;
  int sequence;
  String activity;
  String iconUrl;
  String category;
  String bannerUrl;
  String color;

  InterestModel({
    required this.id,
    required this.sequence,
    required this.activity,
    required this.iconUrl,
    required this.category,
    required this.bannerUrl,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "sequence": sequence,
      "activity": activity,
      'icon_url': iconUrl,
      'category': category,
      'banner_url': bannerUrl,
      'color': color,
    };
  }

  factory InterestModel.fromMap(Map<String, dynamic> map) {
    return InterestModel(
      id: map['id'],
      sequence: map['sequence'],
      activity: map['activity'],
      iconUrl: map['icon_url'],
      category: map['category'],
      bannerUrl: map['banner_url'],
      color: map['color'],
    );
  }
}


class UserInterestModel {
  String activity;
  String iconUrl;
  String bannerUrl;
  String color;

  UserInterestModel({
    required this.activity,
    required this.iconUrl,
    required this.bannerUrl,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      "activity": activity,
      "icon": iconUrl,
      "banner": bannerUrl,
      "color": color,
    };
  }

  factory UserInterestModel.fromMap(Map<String, dynamic> map) {
    return UserInterestModel(
      activity: map['activity'],
      iconUrl: map['icon'],
      bannerUrl: map['banner'],
      color: map['color'],
    );
  }
}
