import 'package:zipbuzz/models/groups/res/description_model.dart';

class CommunityAndGroupRes {
  final List<DescriptionModel> groups;
  final List<DescriptionModel> communities;

  const CommunityAndGroupRes({required this.groups, required this.communities});

  factory CommunityAndGroupRes.fromJson(Map<String, dynamic> json) {
    List<DescriptionModel> groups = [];
    List<DescriptionModel> communities = [];
    if (json['query_results'] != null) {
      for (var e in (json['query_results'] as List)) {
        if (e['type'] == 'group') {
          groups.add(DescriptionModel.fromJson(e));
        } else {
          communities.add(DescriptionModel.fromJson(e));
        }
      }
    }

    return CommunityAndGroupRes(groups: groups, communities: communities);
  }
}
