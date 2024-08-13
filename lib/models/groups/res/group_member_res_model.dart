import 'package:zipbuzz/models/groups/group_member_model.dart';

class GroupMemberResModel {
  final List<GroupMemberModel> admins;
  final List<GroupMemberModel> members;

  GroupMemberResModel({
    required this.admins,
    required this.members,
  });

  factory GroupMemberResModel.fromJson(Map<String, dynamic> json) {
    final List<GroupMemberModel> admins = [];
    final List<GroupMemberModel> members = [];
    final userList = json['users'] as List;
    for (final user in userList) {
      final model = GroupMemberModel.fromJson(user);
      if (model.permissionType == GroupPermissionType.admin) {
        admins.add(model);
      } else {
        members.add(model);
      }
    }
    return GroupMemberResModel(
      admins: admins,
      members: members,
    );
  }
}
