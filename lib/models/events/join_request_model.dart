class JoinEventRequestModel {
  int eventId;
  String name;
  String phoneNumber;
  String image;

  JoinEventRequestModel({
    required this.eventId,
    required this.name,
    required this.phoneNumber,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'name': name,
      'phone_number': phoneNumber,
      'image': image,
    };
  }

  factory JoinEventRequestModel.fromMap(Map<String, dynamic> map) {
    return JoinEventRequestModel(
      eventId: map['event_id'] as int,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      image: map['image'] as String,
    );
  }
}
