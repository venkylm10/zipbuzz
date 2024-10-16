class EditEventRequestModel {
  final int eventId;
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
  final bool isPrivate;
  final bool guestList;
  final String paypalLink;
  final String venmoLink;

  EditEventRequestModel({
    required this.eventId,
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
    required this.isPrivate,
    required this.guestList,
    required this.paypalLink,
    required this.venmoLink,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'event_id': eventId,
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
      'is_private': isPrivate,
      'guest_list': guestList,
      'paypal_link': paypalLink,
      'venmo_link': venmoLink,
    };
  }
}
