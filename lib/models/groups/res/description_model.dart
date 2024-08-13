class DescriptionModel {
  final int id;
  final String name;
  final String description;
  final String type;
  final bool archive;

  DescriptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.archive,
  });

  factory DescriptionModel.fromJson(Map<String, dynamic> json) {
    return DescriptionModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      archive: json['archive'],
    );
  }
}
