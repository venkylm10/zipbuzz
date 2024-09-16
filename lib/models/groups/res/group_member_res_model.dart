import 'package:zipbuzz/models/groups/group_member_model.dart';

class GroupMemberResModel {
  final List<GroupMemberModel> admins;
  final List<GroupMemberModel> members;
  final List<GroupMemberModel> invites;

  GroupMemberResModel({
    required this.admins,
    required this.members,
    required this.invites,
  });

  factory GroupMemberResModel.fromJson(Map<String, dynamic> json) {
    final List<GroupMemberModel> admins = [];
    final List<GroupMemberModel> members = [];
    final List<GroupMemberModel> invites = [];
    final userList = json['users'] as List;
    for (final user in userList) {
      final model = GroupMemberModel.fromJson(user);
      if (model.permissionType == GroupPermissionType.admin) {
        admins.add(model);
      } else if (model.permissionType == GroupPermissionType.invite) {
        invites.add(model);
      } else {
        members.add(model);
      }
    }
    return GroupMemberResModel(
      admins: admins,
      members: members,
      invites: invites,
    );
  }
}
