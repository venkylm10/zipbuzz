import 'package:zipbuzz/utils/extensions.dart';

class EventRequestMember {
  String image;
  String phone;
  String name;
  String status;
  int attendees;
  int id;
  int userId;
  double totalAmount;
  String ticketDetails;

  EventRequestMember({
    required this.image,
    required this.phone,
    required this.name,
    required this.status,
    required this.id,
    required this.attendees,
    required this.userId,
    required this.totalAmount,
    required this.ticketDetails,
  });

  factory EventRequestMember.fromMap(Map<String, dynamic> map) {
    // "Adults : 2 @ 15.00 ; Kids: 1 @ 8.00 ; Seniors: 1 @12.00 ; Total: $10.00"
    String ticketDetails = map['ticket_details'] as String;
    final totalAmount = double.tryParse(ticketDetails.split('\$').last) ?? 0.0;
    return EventRequestMember(
      image: map['image'] as String,
      phone: map['phone'] as String,
      name: map['name'].toString().formattedName,
      status: map['status'] as String,
      id: map['id'] as int,
      attendees: map['attendees'] as int,
      userId: map['user_id'] as int,
      totalAmount: totalAmount,
      ticketDetails: ticketDetails,
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
