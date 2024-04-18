class MakeRequestModel {
  int eventId;
  String name;
  String phoneNumber;
  int members;
  int userId;
  bool userDecision;

  MakeRequestModel({
    required this.userId,
    required this.eventId,
    required this.name,
    required this.phoneNumber,
    required this.members,
    this.userDecision = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'event_id': eventId,
      'name': name,
      'phone_number': phoneNumber,
      'members': members,
      "user_decision": userDecision ? "yes" : "no",
    };
  }

  static MakeRequestModel fromMap(Map<String, dynamic> map) {
    return MakeRequestModel(
      userId: map['user_id'],
      eventId: map['event_id'],
      name: map['name'],
      phoneNumber: map['phone_number'],
      members: map['members'],
      userDecision: map['user_decision'] == "yes",
    );
  }
}
