class GroupMemberModel {
  final int userId;
  final String name;
  final GroupPermissionType permissionType;

  GroupMemberModel({
    required this.userId,
    required this.name,
    required this.permissionType,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    GroupPermissionType permissionType;
    switch (json['group_user_permission_type']) {
      case 'o' || 'a':
        permissionType = GroupPermissionType.admin;
        break;
      default:
        permissionType = GroupPermissionType.member;
    }
    return GroupMemberModel(
      userId: json['user_id'],
      name: json['username'],
      permissionType: permissionType,
    );
  }
}

enum GroupPermissionType {
  admin,
  member,
}
