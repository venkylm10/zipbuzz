class CreateGroupModel {
  final int userId;
  final int communityId;
  final String groupName;
  final String groupDescription;
  final String groupImage;
  final String groupBanner;
  final bool groupListed;

  CreateGroupModel({
    required this.userId,
    this.communityId = 1,
    required this.groupName,
    required this.groupDescription,
    required this.groupImage,
    required this.groupBanner,
    required this.groupListed,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'community_id': communityId,
      'group_name': groupName,
      'group_description': groupDescription,
      'group_image': groupImage,
      'group_banner': groupBanner,
      'group_listed': groupListed,
    };
  }
}
