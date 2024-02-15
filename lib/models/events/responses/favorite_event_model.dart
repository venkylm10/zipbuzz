class FavoriteEventModel {
  int eventId;
  String image;
  String category;
  String name;
  String description;
  String date;
  String venue;
  String startTime;
  String endTime;
  String hostName;
  String hostPic;
  int hostId;
  bool eventType;
  int capacity;
  int filledCapacity;
  String inviteUrl;
  String status;

  FavoriteEventModel({
    required this.eventId,
    required this.image,
    required this.category,
    required this.name,
    required this.description,
    required this.date,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.hostName,
    required this.hostPic,
    required this.hostId,
    required this.eventType,
    required this.capacity,
    required this.filledCapacity,
    this.inviteUrl = "",
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'event_id': eventId,
      'image': image,
      'category': category,
      'name': name,
      'description': description,
      'date': date,
      'venue': venue,
      'start_time': startTime,
      'end_time': endTime,
      'host_name': hostName,
      'host_pic': hostPic,
      'host_id': hostId,
      'event_type': eventType,
      'capacity': capacity,
      'filled_capacity': filledCapacity,
      "invite_url": inviteUrl,
      "status": status,
    };
  }

  factory FavoriteEventModel.fromMap(Map<String, dynamic> map) {
    return FavoriteEventModel(
      eventId: map['event_id'] as int,
      image: map['image'] as String,
      category: map['category'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      date: map['date'] as String,
      venue: map['venue'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      hostName: map['host_name'] as String,
      hostPic: map['host_pic'] as String,
      hostId: map['host_id'] as int,
      eventType: map['event_type'] as bool,
      capacity: map['capacity'] as int,
      filledCapacity: map['filled_capacity'] as int,
      inviteUrl: map['invite_url'] ?? "",
      status: map['status'] ?? "nothing",
    );
  }
}
