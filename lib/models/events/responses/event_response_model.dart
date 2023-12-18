class EventResponseModel {
  final int id;
  final String banner;
  final String category;
  final String name;
  final String description;
  final String date;
  final String venue;
  final String startTime;
  final String endTime;
  final String hostPic;
  final int hostId;
  final bool eventType;
  final String hostName;
  final int capacity;
  final int filledCapacity;

  EventResponseModel({
    required this.id,
    required this.banner,
    required this.category,
    required this.name,
    required this.description,
    required this.date,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.hostPic,
    required this.hostId,
    required this.eventType,
    required this.hostName,
    required this.capacity,
    required this.filledCapacity,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'banner': banner,
      'category': category,
      'name': name,
      'description': description,
      'date': date,
      'venue': venue,
      'start_time': startTime,
      'end_time': endTime,
      'host_pic': hostPic,
      'host_id': hostId,
      'event_type': eventType,
      'host_name': hostName,
      'capacity': capacity,
      'filled_capacity': filledCapacity,
    };
  }

  factory EventResponseModel.fromMap(Map<String, dynamic> map) {
    return EventResponseModel(
      id: map['id'] as int,
      banner: map['banner'] as String,
      category: map['category'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      date: map['date'] as String,
      venue: map['venue'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      hostPic: map['host_pic'] as String,
      hostId: map['host_id'] as int,
      eventType: map['event_type'] as bool,
      hostName: map['host_name'] as String,
      capacity: map['capacity'] as int,
      filledCapacity: map['filled_capacity'] as int,
    );
  }
}
