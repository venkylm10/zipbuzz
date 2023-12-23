import 'package:zipbuzz/models/events/event_member_model.dart';

class EventResponseModalClass {
  String status;
  List<EventMemberModel> eventMembers;

  EventResponseModalClass({
    required this.status,
    required this.eventMembers,
  });

  factory EventResponseModalClass.fromMap(Map<String, dynamic> map) {
    return EventResponseModalClass(
      status: map['status'],
      eventMembers: List<EventMemberModel>.from(
        (map['event_members'] as List)
            .map(
              (member) => EventMemberModel.fromMap(member),
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
