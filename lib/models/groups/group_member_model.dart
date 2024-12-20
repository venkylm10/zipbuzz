import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/extensions.dart';

class GroupMemberModel {
  final int userId;
  final String name;
  final String phone;
  final GroupPermissionType permissionType;
  final String profilePicture;
  final DateTime relatedTime;

  GroupMemberModel({
    required this.userId,
    required this.name,
    required this.phone,
    required this.permissionType,
    required this.profilePicture,
    required this.relatedTime,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    GroupPermissionType permissionType;
    switch (json['group_user_permission_type']) {
      case 'o' || 'a':
        permissionType = GroupPermissionType.admin;
        break;
      case 'i':
        permissionType = GroupPermissionType.invite;
        break;
      case 'p':
        permissionType = GroupPermissionType.pending;
        break;
      default:
        permissionType = GroupPermissionType.member;
    }
    return GroupMemberModel(
      userId: json['user_id'],
      name: json['username'].toString().formattedName,
      phone: json['phone'],
      permissionType: permissionType,
      profilePicture: json['profile_picture'] == 'zipbuzz-null'
          ? Defaults.contactAvatarUrl
          : json['profile_picture'],
      relatedTime: DateTime.parse(json['related_time']).toLocal(),
    );
  }
}

enum GroupPermissionType {
  admin,
  member,
  invite,
  pending,
}

extension GroupPermissionTypeExtension on GroupPermissionType {
  String get short {
    switch (this) {
      case GroupPermissionType.admin:
        return 'a';
      case GroupPermissionType.member:
        return 'm';
      case GroupPermissionType.invite:
        return 'i';
      case GroupPermissionType.pending:
        return 'p';
    }
  }
}
