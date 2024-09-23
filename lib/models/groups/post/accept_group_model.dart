class AcceptGroupModel {
  final int groupId;
  final int userId;
  final String permissionType;
  final int groupUserAddedBy;

  const AcceptGroupModel({
    required this.groupId,
    required this.userId,
    this.permissionType = 'm',
    required this.groupUserAddedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      "group_id": groupId,
      "user_id": userId,
      "permission_type": permissionType,
      "group_user_added_by": groupUserAddedBy,
    };
  }
}
