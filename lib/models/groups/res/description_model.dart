class DescriptionModel {
  final int id;
  final String name;
  final String description;
  final int creatorId;
  final String type;
  final bool archive;
  final String profileImage;

  DescriptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.type,
    required this.archive,
    required this.profileImage,
  });

  factory DescriptionModel.fromJson(Map<String, dynamic> json) {
    return DescriptionModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      creatorId: json['creator_id'],
      type: json['type'],
      archive: json['archive'],
      profileImage: json['profile_image'],
    );
  }
}
