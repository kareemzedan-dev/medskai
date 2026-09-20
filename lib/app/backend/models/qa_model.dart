class QaQuestionModel {
  int? id;
  int? courseId;
  int? studentId;
  String? subject;
  String? question;
  String? answer;
  String? status;
  String? date;

  QaQuestionModel({
    this.id,
    this.courseId,
    this.studentId,
    this.subject,
    this.question,
    this.answer,
    this.status,
    this.date,
  });

  QaQuestionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    courseId = json['course_id'] is int ? json['course_id'] : int.tryParse(json['course_id']?.toString() ?? '');
    studentId = json['student_id'] is int ? json['student_id'] : int.tryParse(json['student_id']?.toString() ?? '');
    subject = json['subject']?.toString();
    question = json['question']?.toString();
    answer = json['answer']?.toString();
    status = json['status']?.toString();
    date = json['date']?.toString() ?? json['created_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['course_id'] = courseId;
    data['student_id'] = studentId;
    data['subject'] = subject;
    data['question'] = question;
    data['answer'] = answer;
    data['status'] = status;
    data['date'] = date;
    return data;
  }
}
