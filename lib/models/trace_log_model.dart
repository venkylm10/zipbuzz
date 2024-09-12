import 'package:zipbuzz/utils/action_code.dart';

class TraceLogModel {
  final int? eventId;
  final int? groupId;
  final int? communityId;
  final int userId;
  final ActionCode actionCode;
  final String actionDetails;
  final bool successFlag;

  const TraceLogModel({
    this.eventId,
    this.groupId,
    this.communityId,
    required this.userId,
    required this.actionCode,
    required this.actionDetails,
    required this.successFlag,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "user_id": userId,
      "action_code": actionCode.name,
      "action_details": actionDetails,
      "success_flag": successFlag ? "Success" : "Failure",
    };
    if (eventId != null) {
      data['event_id'] = eventId!;
    }
    if (groupId != null) {
      data['group_id'] = groupId!;
    }
    if (communityId != null) {
      data['community_id'] = communityId!;
    }
    return data;
  }
}
