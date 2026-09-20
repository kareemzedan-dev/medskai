/// Model for lesson/course discussion comments.
class DiscussionModel {
  int? id;
  int? courseId;
  int? lessonId;
  String? authorName;
  String? authorAvatar;
  String? content;
  String? date;
  int? parentId;
  bool? isInstructor;
  List<DiscussionModel> replies;

  DiscussionModel({
    this.id,
    this.courseId,
    this.lessonId,
    this.authorName,
    this.authorAvatar,
    this.content,
    this.date,
    this.parentId,
    this.isInstructor,
    this.replies = const [],
  });

  factory DiscussionModel.fromJson(Map<String, dynamic> json) {
    List<DiscussionModel> repliesList = [];
    if (json['replies'] is List) {
      for (var reply in json['replies']) {
        if (reply is Map<String, dynamic>) {
          repliesList.add(DiscussionModel.fromJson(reply));
        }
      }
    }

    return DiscussionModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      courseId: int.tryParse(json['course_id']?.toString() ?? ''),
      lessonId: int.tryParse(json['lesson_id']?.toString() ?? ''),
      authorName: json['author_name']?.toString() ?? json['author']?.toString(),
      authorAvatar: json['author_avatar']?.toString() ?? json['avatar_url']?.toString(),
      content: json['content']?.toString(),
      date: json['date']?.toString() ?? json['date_created']?.toString(),
      parentId: int.tryParse(json['parent']?.toString() ?? '0'),
      isInstructor: json['is_instructor'] == true || json['is_instructor'] == 1,
      replies: repliesList,
    );
  }

  String get formattedDate {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date!);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 30) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return date ?? '';
    }
  }
}
