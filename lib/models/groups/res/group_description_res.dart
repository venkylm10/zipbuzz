class GroupDescriptionRes {
  final List<GroupDescriptionModel> results;
  const GroupDescriptionRes({required this.results});

  factory GroupDescriptionRes.fromJson(Map<String, dynamic> json) {
    return GroupDescriptionRes(
      results:
          (json['query_results'] as List).map((e) => GroupDescriptionModel.fromJson(e)).toList(),
    );
  }
}

class GroupDescriptionModel {
  final int id;
  final String groupName;
  final String groupDescription;
  final String groupProfileImage;

  const GroupDescriptionModel({
    required this.id,
    required this.groupName,
    required this.groupDescription,
    required this.groupProfileImage,
  });

  factory GroupDescriptionModel.fromJson(Map<String, dynamic> json) {
    return GroupDescriptionModel(
      id: json["id"],
      groupName: json['group_name'],
      groupDescription: json['group_description'],
      groupProfileImage: json['group_profile_image'],
    );
  }
}
