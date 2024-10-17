class EventRequestMember {
  String image;
  String phone;
  String name;
  String status;
  int attendees;
  int id;
  int userId;
  int totalAmount;

  EventRequestMember({
    required this.image,
    required this.phone,
    required this.name,
    required this.status,
    required this.id,
    required this.attendees,
    required this.userId,
    required this.totalAmount,
  });

  factory EventRequestMember.fromMap(Map<String, dynamic> map) {
    final nameSplits = map['name'].toString().split(' ');
    final name = nameSplits.length > 1 ? "${nameSplits[0]} ${nameSplits[1][0]}." : nameSplits[0];
    return EventRequestMember(
      image: map['image'] as String,
      phone: map['phone'] as String,
      name: name,
      status: map['status'] as String,
      id: map['id'] as int,
      attendees: map['attendees'] as int,
      userId: map['user_id'] as int,
      totalAmount: map['total_amount'] as int,
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
      'user_id': userId,
      'total_amount': totalAmount,
    };
  }
}
