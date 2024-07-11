class FaqModel {
  String question;
  String answer;
  String mediaUrl;
  int sequence;
  int id;

  FaqModel({
    required this.question,
    required this.answer,
    required this.mediaUrl,
    required this.sequence,
    required this.id,
  });

  factory FaqModel.fromMap(Map<String, dynamic> map) {
    return FaqModel(
      question: map['question'],
      answer: map['answer'],
      mediaUrl: map['media_url'],
      sequence: map['sequence'],
      id: map['id'],
    );
  }
}
