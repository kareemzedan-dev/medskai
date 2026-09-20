import 'dart:convert';

class GroupModel {
  String? groupId;
  String? name;
  String? description;
  String? iconUrl;
  int membersCount = 0;
  int discussionsCount = 0;

  GroupModel({
    this.groupId,
    this.name,
    this.description,
    this.iconUrl,
    this.membersCount = 0,
    this.discussionsCount = 0,
  });

  GroupModel.fromJson(Map<String, dynamic> json) {
    groupId = json['group_id']?.toString();
    name = json['name']?.toString() ?? '';
    description = json['description']?.toString() ?? '';
    iconUrl = json['icon_url']?.toString() ?? '';

    if (json['stats'] != null && json['stats'] is Map) {
      membersCount = int.tryParse(json['stats']['members_count']?.toString() ?? '0') ?? 0;
      discussionsCount = int.tryParse(json['stats']['discussions_count']?.toString() ?? '0') ?? 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'stats': {
        'members_count': membersCount,
        'discussions_count': discussionsCount,
      }
    };
  }
}
