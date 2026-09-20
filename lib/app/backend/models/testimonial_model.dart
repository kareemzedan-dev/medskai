class TestimonialModel {
  int? id;
  String? reviewerName;
  String? reviewerTitle;
  String? avatarUrl;
  double rating = 5.0;
  String? content;

  TestimonialModel({
    this.id, this.reviewerName, this.reviewerTitle,
    this.avatarUrl, this.rating = 5.0, this.content,
  });

  TestimonialModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reviewerName = json['reviewer_name']?.toString() ?? json['name']?.toString();
    reviewerTitle = json['reviewer_title']?.toString() ?? json['title']?.toString();
    avatarUrl = json['avatar_url']?.toString() ?? json['avatar']?.toString();
    content = json['content']?.toString() ?? json['review']?.toString();

    if (json['rating'] != null) {
      if (json['rating'] is num) {
        rating = (json['rating'] as num).toDouble();
      } else if (json['rating'] is String) {
        rating = double.tryParse(json['rating']) ?? 5.0;
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'reviewer_name': reviewerName, 'reviewer_title': reviewerTitle,
      'avatar_url': avatarUrl, 'rating': rating, 'content': content,
    };
  }
}

class PlatformStatsModel {
  int studentsEnrolled;
  int classesCompleted;
  int satisfactionRate;
  int topInstructors;

  PlatformStatsModel({
    this.studentsEnrolled = 0,
    this.classesCompleted = 0,
    this.satisfactionRate = 0,
    this.topInstructors = 0,
  });

  PlatformStatsModel.fromJson(Map<String, dynamic> json) :
    studentsEnrolled = int.tryParse(json['students_enrolled']?.toString() ?? '') ?? 0,
    classesCompleted = int.tryParse(json['classes_completed']?.toString() ?? '') ?? 0,
    satisfactionRate = int.tryParse(json['satisfaction_rate']?.toString() ?? '') ?? 0,
    topInstructors = int.tryParse(json['top_instructors']?.toString() ?? '') ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'students_enrolled': studentsEnrolled,
      'classes_completed': classesCompleted,
      'satisfaction_rate': satisfactionRate,
      'top_instructors': topInstructors,
    };
  }
}
