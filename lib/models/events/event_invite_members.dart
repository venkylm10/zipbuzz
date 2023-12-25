class EventInviteMember {
  String image;
  String phone;
  String name;

  EventInviteMember({
    required this.image,
    required this.phone,
    required this.name,
  });

  factory EventInviteMember.fromMap(Map<String, dynamic> map) {
    return EventInviteMember(
      image: map['image'] as String,
      phone: map['phone'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'phone': phone,
      'name': name,
    };
  }
}
