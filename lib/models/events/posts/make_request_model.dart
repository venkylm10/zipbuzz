class MakeRequestModel {
  int eventId;
  String name;
  String phoneNumber;
  int members;
  int userId;
  bool userDecision;
  double totalAmount;

  MakeRequestModel({
    required this.userId,
    required this.eventId,
    required this.name,
    required this.phoneNumber,
    required this.members,
    this.userDecision = false,
    this.totalAmount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'event_id': eventId,
      'name': name,
      'phone_number': phoneNumber,
      'members': members,
      "user_decision": userDecision ? "yes" : "no",
      "total_amount": totalAmount,
    };
  }
}
