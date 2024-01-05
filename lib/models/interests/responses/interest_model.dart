class InterestModel {
  String iconUrl;
  String category;
  String bannerUrl;
  String color;

  InterestModel({
    required this.iconUrl,
    required this.category,
    required this.bannerUrl,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'icon_url': iconUrl,
      'category': category,
      'banner_url': bannerUrl,
      'color': color,
    };
  }

  factory InterestModel.fromMap(Map<String, dynamic> map) {
    return InterestModel(
      iconUrl: map['icon_url'],
      category: map['category'],
      bannerUrl: map['banner_url'],
      color: map['color'],
    );
  }
}
