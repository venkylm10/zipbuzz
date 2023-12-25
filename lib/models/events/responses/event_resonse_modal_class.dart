import 'package:zipbuzz/models/events/event_invite_members.dart';

class EventMembersResponseModel {
  String status;
  List<EventInviteMember> eventMembers;

  EventMembersResponseModel({
    required this.status,
    required this.eventMembers,
  });

  factory EventMembersResponseModel.fromMap(Map<String, dynamic> map) {
    return EventMembersResponseModel(
      status: map['status'],
      eventMembers: List<EventInviteMember>.from(
        (map['event_members'] as List)
            .map(
              (member) => EventInviteMember.fromMap(member),
            )
            .toList(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'event_members': eventMembers.map((member) => member.toMap()).toList(),
    };
  }
}
