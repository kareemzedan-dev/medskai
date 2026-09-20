class UserModel  {
  int? user_id;
  String? user_login;
  String? user_email;
  String? user_display_name;

  UserModel({
    this.user_id,
    this.user_login,
    this.user_email,
    this.user_display_name,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    if (json['user_id'] != null) {
      user_id = int.tryParse(json['user_id']?.toString() ?? '') ?? 0;
    }
    user_login = json['user_login']?.toString();
    user_email = json['user_email']?.toString();
    user_display_name = json['user_display_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = user_id;
    data['user_login'] = user_login;
    data['user_email'] = user_email;
    data['user_display_name'] = user_display_name;
    return data;
  }
}
