class MakeRequestModel {
  int eventId;
  String name;
  String phoneNumber;
  int members;
  int userId;

  MakeRequestModel({
    required this.userId,
    required this.eventId,
    required this.name,
    required this.phoneNumber,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'event_id': eventId,
      'name': name,
      'phone_number': phoneNumber,
      'members': members,
    };
  }

  static MakeRequestModel fromMap(Map<String, dynamic> map) {
    return MakeRequestModel(
      userId: map['user_id'],
      eventId: map['event_id'],
      name: map['name'],
      phoneNumber: map['phone_number'],
      members: map['members'],
    );
  }
}
