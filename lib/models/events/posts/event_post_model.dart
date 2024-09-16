class EventPostModel {
  EventPostModel(
      {required this.banner,
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
      required this.guestList,
      required this.isPrivate,
      this.groupId = 0,
      this.groupName = 'zipbuzz-null'});
  final String banner;
  final String category;
  final String name;
  final String description;
  final String date;
  final String venue;
  final String startTime;
  final String endTime;
  final int hostId;
  final String hostName;
  final String hostPic;
  final bool eventType;
  final int capacity;
  final int filledCapacity;
  final bool guestList;
  final bool isPrivate;
  final int? groupId;
  final String? groupName;

  factory EventPostModel.fromMap(Map<String, dynamic> json) {
    return EventPostModel(
      banner: json['banner'],
      category: json['category'],
      name: json['name'],
      description: json['description'],
      date: json['date'],
      venue: json['venue'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      hostId: json['host_id'],
      hostName: json['host_name'],
      hostPic: json['host_pic'],
      eventType: json['event_type'],
      capacity: json['capacity'],
      filledCapacity: json['filled_capacity'],
      guestList: json['guest_list'],
      isPrivate: json['is_private'],
    );
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
    data['guest_list'] = guestList;
    data['is_private'] = isPrivate;
    data['group_id'] = groupId;
    data['group_name'] = groupName;
    return data;
  }
}
