class EditGroupModel {
  final int userId;
  final int groupId;
  final String name;
  final String description;
  final String groupUrl;
  final String banner;
  final String image;
  final bool listed;

  EditGroupModel({
    required this.userId,
    required this.groupId,
    required this.name,
    required this.description,
    required this.banner,
    required this.image,
    required this.listed,
    this.groupUrl = 'zipbuzz-null',
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'group_id': groupId,
      'group_name': name,
      'group_description': description,
      'group_url': groupUrl,
      'group_banner': banner,
      'group_image': image,
      'group_listed': listed,
    };
  }
}
