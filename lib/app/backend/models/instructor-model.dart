class UserInstructorModel {
  int? id;
  String? username;
  String? name;
  String? email;
  String? nickname;
  String? slug;
  String? avatar_url;
  dynamic instructor_data;
  dynamic social;
  String? description;

  UserInstructorModel({
    this.id,
    this.username,
    this.name,
    this.email,
    this.nickname,
    this.slug,
    this.avatar_url,
    this.instructor_data,
    this.social,
    this.description,
  });

  UserInstructorModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] != null) {
      id = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    }
    username = json['username']?.toString();
    name = json['name']?.toString();
    email = json['email']?.toString();
    nickname = json['nickname']?.toString();
    slug = json['slug']?.toString();
    // LearnPress API returns avatar_url (string) or avatar (string)
    // WP REST API returns avatar_urls (object with sizes as keys)
    if (json['avatar_url'] != null) {
      avatar_url = json['avatar_url']?.toString();
    } else if (json['avatar'] != null) {
      avatar_url = json['avatar']?.toString();
    } else if (json['avatar_urls'] != null && json['avatar_urls'] is Map) {
      final urls = json['avatar_urls'] as Map;
      avatar_url = urls['96']?.toString() ?? urls.values.firstOrNull?.toString();
    }
    // WP REST returns description as plain string
    description = json['description']?.toString();
    if (json['instructor_data'] != null)
      instructor_data = json['instructor_data'];

    if (json['social'] != null) social = json['social'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['name'] = name;
    data['email'] = email;
    data['nickname'] = nickname;
    data['slug'] = slug;
    data['avatar_url'] = avatar_url;
    data['instructor_data'] = instructor_data;
    data['social'] = social;
    return data;
  }
}
