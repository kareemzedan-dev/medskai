class NotificationModel {
  String? notification_id;
  String? name;
  String? type;
  String? title;
  String? content;
  String? image;
  String? status;
  String? source;
  String? date_reminder;
  String? date_created;

  NotificationModel({
    this.notification_id,
    this.name,
    this.type,
    this.title,
    this.content,
    this.image,
    this.status,
    this.source,
    this.date_reminder,
    this.date_created
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    notification_id = json["notification_id"]?.toString();
    name = json['name']?.toString();
    type = json['type']?.toString();
    title = json['title']?.toString();
    content = json['content']?.toString();
    image = json['image']?.toString();
    status = json['status']?.toString();
    source = json['source']?.toString();
    date_reminder = json['date_reminder']?.toString();
    date_created = json['date_created']?.toString();
  }

  String get formattedDateCreated {
    if (date_created == null || date_created!.isEmpty) return '';
    try {
      final dt = DateTime.parse(date_created!);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      final val = date_created!;
      final timeRegex = RegExp(r'(\d{1,2}):(\d{2}):(\d{2})');
      if (timeRegex.hasMatch(val)) {
        return val.replaceAllMapped(timeRegex, (match) => '${match.group(1)}:${match.group(2)}');
      }
      return val;
    }
  }
}
