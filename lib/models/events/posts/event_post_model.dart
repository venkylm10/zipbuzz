class EventPostModel {
  EventPostModel({
    required this.banner,
    required this.category,
    required this.name,
    required this.description,
    required this.date,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.hostId,
    required this.hostName,
    required this.hostPic,
    required this.eventType,
    required this.capacity,
    required this.filledCapacity,
  });
  late final String banner;
  late final String category;
  late final String name;
  late final String description;
  late final String date;
  late final String venue;
  late final String startTime;
  late final String endTime;
  late final int hostId;
  late final String hostName;
  late final String hostPic;
  late final bool eventType;
  late final int capacity;
  late final int filledCapacity;

  EventPostModel.fromMap(Map<String, dynamic> json) {
    banner = json['banner'];
    category = json['category'];
    name = json['name'];
    description = json['description'];
    date = json['date'];
    venue = json['venue'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    hostId = json['host_id'];
    hostName = json['host_name'];
    hostPic = json['host_pic'];
    eventType = json['event_type'];
    capacity = json['capacity'];
    filledCapacity = json['filled_capacity'];
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['banner'] = banner;
    data['category'] = category;
    data['name'] = name;
    data['description'] = description;
    data['date'] = date;
    data['venue'] = venue;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['host_id'] = hostId;
    data['host_name'] = hostName;
    data['host_pic'] = hostPic;
    data['event_type'] = eventType;
    data['capacity'] = capacity;
    data['filled_capacity'] = filledCapacity;
    return data;
  }
}
