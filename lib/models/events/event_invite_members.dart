class EventInviteMember {
  String image;
  String phone;
  String name;
  String status;

  EventInviteMember({
    required this.image,
    required this.phone,
    required this.name,
    required this.status,
  });

  factory EventInviteMember.fromMap(Map<String, dynamic> map) {
    final nameSplits = map['name'].toString().split(' ');
    final name = nameSplits.length > 1 ? "${nameSplits[0]} ${nameSplits[1][0]}." : nameSplits[0];
    return EventInviteMember(
      image: map['image'] as String,
      phone: map['phone'] as String,
      name: name,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'phone': phone,
      'name': name,
      'status': status,
    };
  }
}
