class InviteGroupMemberModel {
  final int groupId;
  final int userId;
  final String title;
  final String inviteName;
  final String phoneNumber;
  final String invitingUserName;

  const InviteGroupMemberModel({
    required this.groupId,
    required this.userId,
    required this.title,
    required this.inviteName,
    required this.phoneNumber,
    required this.invitingUserName,
  });

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'user_id': userId,
      'title': title,
      'invite_name': inviteName,
      'phone_number': phoneNumber,
      'json_body': "$invitingUserName has invite you to a new group",
    };
  }
}
