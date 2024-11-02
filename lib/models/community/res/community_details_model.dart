class CommunityDetailsModel {
  final int id;
  final String communityName;
  final String communityDescription;
  final String communityUrl;
  final String communityImage;
  final bool communityListed;
  final String communityBanner;
  final DateTime communityCreationTime;
  final DateTime? communityUpdatedTime;
  final int communityCreatedByUserId;
  final int communityLastUpdatedByUserId;
  final bool communityArchived;
  final DateTime? communityArchiveDate;
  final int communityArchivedByUserId;

  CommunityDetailsModel({
    required this.id,
    required this.communityName,
    required this.communityDescription,
    required this.communityUrl,
    required this.communityImage,
    required this.communityListed,
    required this.communityBanner,
    required this.communityCreationTime,
    this.communityUpdatedTime,
    required this.communityCreatedByUserId,
    required this.communityLastUpdatedByUserId,
    required this.communityArchived,
    this.communityArchiveDate,
    required this.communityArchivedByUserId,
  });

  factory CommunityDetailsModel.fromJson(Map<String, dynamic> json) {
    return CommunityDetailsModel(
      id: json['id'],
      communityName: json['community_name'],
      communityDescription: json['community_description'],
      communityUrl: json['community_url'],
      communityImage: json['community_image'],
      communityListed: json['community_listed'],
      communityBanner: json['community_banner'],
      communityCreationTime: DateTime.parse(json['community_creation_time']),
      communityUpdatedTime: json['community_updated_time'] != null
          ? DateTime.parse(json['community_updated_time'])
          : null,
      communityCreatedByUserId: json['community_created_by_user_id'],
      communityLastUpdatedByUserId: json['community_last_updated_by_user_id'],
      communityArchived: json['community_archived'],
      communityArchiveDate: json['community_archive_date'] != null
          ? DateTime.parse(json['community_archive_date'])
          : null,
      communityArchivedByUserId: json['community_archived_by_user_id'],
    );
  }
}
