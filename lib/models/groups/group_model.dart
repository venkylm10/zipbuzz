class GroupModel {
  final int id;
  final String name;
  final String description;
  final String groupUrl;
  final String image;
  final bool listed;
  final DateTime creationTime;
  final DateTime? updatedTime;
  final int createdByUserId;
  final int lastUpdatedByUserId;
  final int communityId;
  final bool archived;
  final DateTime? archiveDate;
  final int? archivedByUserId;
  final String banner;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.groupUrl,
    required this.image,
    required this.listed,
    required this.creationTime,
    this.updatedTime,
    required this.createdByUserId,
    required this.lastUpdatedByUserId,
    required this.communityId,
    required this.archived,
    this.archiveDate,
    this.archivedByUserId,
    required this.banner,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['group_name'],
      description: json['group_description'],
      groupUrl: json['group_url'],
      image: json['group_image'],
      listed: json['group_listed'],
      creationTime: DateTime.parse(json['group_creation_time']),
      updatedTime:
          json['group_updated_time'] != null ? DateTime.parse(json['group_updated_time']) : null,
      createdByUserId: json['group_created_by_user_id'],
      lastUpdatedByUserId: json['group_last_updated_by_user_id'],
      communityId: json['community_id'],
      archived: json['group_archived'],
      archiveDate:
          json['group_archive_date'] != null ? DateTime.parse(json['group_archive_date']) : null,
      archivedByUserId: json['group_archived_by_user_id'],
      banner: json['group_banner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_name': name,
      'group_description': description,
      'group_url': groupUrl,
      'group_image': image,
      'group_listed': listed,
      'group_creation_time': creationTime.toIso8601String(),
      'group_updated_time': updatedTime,
      'group_created_by_user_id': createdByUserId,
      'group_last_updated_by_user_id': lastUpdatedByUserId,
      'community_id': communityId,
      'group_archived': archived,
      'group_archive_date': archiveDate,
      'group_archived_by_user_id': archivedByUserId,
      'group_banner': banner,
    };
  }

  GroupModel copyWith({
    int? id,
    String? name,
    String? description,
    String? groupUrl,
    String? image,
    bool? listed,
    DateTime? creationTime,
    DateTime? updatedTime,
    int? createdByUserId,
    int? lastUpdatedByUserId,
    int? communityId,
    bool? archived,
    DateTime? archiveDate,
    int? archivedByUserId,
    String? banner,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      groupUrl: groupUrl ?? this.groupUrl,
      image: image ?? this.image,
      listed: listed ?? this.listed,
      creationTime: creationTime ?? this.creationTime,
      updatedTime: updatedTime ?? this.updatedTime,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      lastUpdatedByUserId: lastUpdatedByUserId ?? this.lastUpdatedByUserId,
      communityId: communityId ?? this.communityId,
      archived: archived ?? this.archived,
      archiveDate: archiveDate ?? this.archiveDate,
      archivedByUserId: archivedByUserId ?? this.archivedByUserId,
      banner: banner ?? this.banner,
    );
  }
}
