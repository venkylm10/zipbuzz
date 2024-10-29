class LogTicketModel {
  final int eventId;
  final int userId;
  final String ticketDetails;
  final double paymentAmount;
  final String guestComment;

  LogTicketModel({
    required this.eventId,
    required this.userId,
    required this.ticketDetails,
    required this.paymentAmount,
    required this.guestComment,
  });

  factory LogTicketModel.fromJson(Map<String, dynamic> json) {
    return LogTicketModel(
      eventId: json['event_id'],
      userId: json['user_id'],
      ticketDetails: json['ticket_details'],
      paymentAmount: json['payment_amount'],
      guestComment: json['guest_comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'user_id': userId,
      'ticket_details': ticketDetails,
      'payment_amount': paymentAmount,
      'guest_comment': guestComment,
    };
  }
}
