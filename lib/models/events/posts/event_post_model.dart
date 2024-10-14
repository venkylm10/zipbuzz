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
    required this.guestList,
    required this.isPrivate,
    this.groupId = 0,
    this.groupName = 'zipbuzz-null',
    this.isTicketedEvent = false,
    required this.paypalLink,
    required this.venmoLink,
  });
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
  final bool isTicketedEvent;
  final String paypalLink;
  final String venmoLink;

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
    data['is_ticketed_event'] = isTicketedEvent;
    data['paypal_link'] = paypalLink;
    data['venmo_link'] = venmoLink;
    return data;
  }
}
