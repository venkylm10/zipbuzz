class EventRequestMember {
  String image;
  String phone;
  String name;
  String status;
  int id;

  EventRequestMember({
    required this.image,
    required this.phone,
    required this.name,
    required this.status,
    required this.id,
  });

  factory EventRequestMember.fromMap(Map<String, dynamic> map) {
    return EventRequestMember(
      image: map['image'] as String,
      phone: map['phone'] as String,
      name: map['name'] as String,
      status: map['status'] as String,
      id: map['id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'phone': phone,
      'name': name,
      'status': status,
      'id': id,
    };
  }
}
