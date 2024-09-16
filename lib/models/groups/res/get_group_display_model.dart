import 'package:zipbuzz/models/groups/group_model.dart';

class GroupDisplayResModel {
  final GroupModel group;
  const GroupDisplayResModel({required this.group});

  factory GroupDisplayResModel.fromJson(Map<String, dynamic> json) {
    return GroupDisplayResModel(
      group: GroupModel.fromJson(json['group_data']),
    );
  }
}
