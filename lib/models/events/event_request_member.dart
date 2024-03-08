class EventRequestMember {
  String image;
  String phone;
  String name;
  String status;
  int attendees;
  int id;

  EventRequestMember({
    required this.image,
    required this.phone,
    required this.name,
    required this.status,
    required this.id,
    required this.attendees,
  });

  factory EventRequestMember.fromMap(Map<String, dynamic> map) {
    return EventRequestMember(
      image: map['image'] as String,
      phone: map['phone'] as String,
      name: map['name'] as String,
      status: map['status'] as String,
      id: map['id'] as int,
      attendees: map['attendees'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'phone': phone,
      'name': name,
      'status': status,
      'id': id,
      'attendees': attendees,
    };
  }
}
