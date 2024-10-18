import 'package:zipbuzz/utils/extensions.dart';

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
    return EventInviteMember(
      image: map['image'] as String,
      phone: map['phone'] as String,
      name: map['name'].toString().formattedName,
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
