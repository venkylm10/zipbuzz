class AddCommunityModel {
  final String communityName;
  final String communityDescription;
  final String communityImage;
  final String communityBanner;
  final int userId;
  final bool communityListed = true;

  AddCommunityModel({
    required this.communityName,
    required this.communityDescription,
    required this.communityImage,
    required this.communityBanner,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      "community_name": communityName,
      "community_description": communityDescription,
      "community_image": communityImage,
      "community_banner": communityBanner,
      "user_id": userId,
      "community_listed": communityListed,
    };
  }
}
