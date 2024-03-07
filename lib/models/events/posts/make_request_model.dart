class MakeRequestModel {
  int eventId;
  String name;
  String phoneNumber;
  int members;

  MakeRequestModel({
    required this.eventId,
    required this.name,
    required this.phoneNumber,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'name': name,
      'phone_number': phoneNumber,
      'members': members,
    };
  }

  static MakeRequestModel fromMap(Map<String, dynamic> map) {
    return MakeRequestModel(
      eventId: map['event_id'],
      name: map['name'],
      phoneNumber: map['phone_number'],
      members: map['members'],
    );
  }
}
