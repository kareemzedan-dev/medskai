class LearningLessonModel {
  int? id;
  String? name;
  String? slug;
  String? duration;

  // String? date_created;
  // String? date_created_gmt;
  // String? date_modified;
  // String? date_modified_gmt;
  String? status;
  String? content;
  String? author;
  String? video_intro;
  MetaData? meta_data;
  LessonResult? results;
  bool? can_finish_course;
  List<QuestionModel>? questions = [];

  LearningLessonModel({this.id,
    this.name,
    this.slug,
    this.duration,
    this.status,
    this.content,
    this.author,
    this.video_intro,
    this.meta_data,
    this.can_finish_course,
    this.results,
    this.questions});

  LearningLessonModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] != null) {
      id = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    }

    name = json['name'];
    slug = json['slug'];
    duration = json['duration'];
    status = json['status'];
    content = json['content'];
    author = json['author'];
    video_intro = json['video_intro'];
    if(json['meta_data'] != null){
      meta_data = MetaData.fromJson(json['meta_data']);
    }
    if (json['results'] != null) {
      results = LessonResult.fromJson(json['results']);
    }
    if (json['can_finish_course'] != null) {
      can_finish_course = json['can_finish_course'];
    }
    if (json["questions"] is List) {
      List<QuestionModel> questionsTemp = [];
      json["questions"].forEach((element) {
        QuestionModel temp = QuestionModel.fromJson(element);
        questionsTemp.add(temp);
      });
      questions = questionsTemp;
    }
  }
}

class LessonResult {
  String? status;
  String? passing_grade;
  bool? negative_marking;
  bool? instant_check;
  int? retake_count;
  int? retaken;

  int? questions_per_page;
  bool? page_numbers;
  bool? review_questions;
  List<String>? support_options;
  int? duration;
  int? total_time;
  dynamic results;
  dynamic answered;

  LessonResult({
    this.status,
    this.passing_grade,
    this.negative_marking,
    this.instant_check,
    this.retake_count,
    this.retaken,
    this.questions_per_page,
    this.page_numbers,
    this.review_questions,
    this.support_options,
    this.duration,
    this.total_time,
    this.results,
    this.answered,
  });

  LessonResult.fromJson(Map<String, dynamic> json) {

    status = json['status'];
    passing_grade = json['passing_grade'];
    negative_marking = json['negative_marking'];
    instant_check = json['instant_check'];
    if (json['retake_count'] != null) {
      retake_count = int.tryParse(json['retake_count']?.toString() ?? '') ?? 0;
    }
    if (json['retaken'] != null) {
      retaken = int.tryParse(json['retaken']?.toString() ?? '') ?? 0;
    }

    if (json['questions_per_page'] != null) {
      questions_per_page = int.tryParse(json['questions_per_page']?.toString() ?? '') ?? 0;
    }
    page_numbers = json['page_numbers'];
    review_questions = json['review_questions'];
    if (json['total_time'] != null) {
      total_time = int.tryParse(json['total_time']?.toString() ?? '') ?? 0;
    }
    if (json['support_options'] is List) {
      List<String> supportOptions = [];
      json['support_options'].forEach((element) {
        supportOptions.add(element);
      });
      support_options = supportOptions;
    }

    if (json['duration'] != null) {
      duration = int.tryParse(json['duration']?.toString() ?? '') ?? 0;
    }
    if (json['results'] != null && json['results'] is Map) {
      final r = json['results'] as Map;
      results = {
        "graduationText": r["graduationText"],
        "graduation": r["graduation"],
        "result": r["result"],
        "passing_grade": r["passing_grade"],
        "question_count": r["question_count"],
        "question_correct": r["question_correct"],
        "question_wrong": r["question_wrong"],
        "question_empty": r["question_empty"],
        "user_mark": r["user_mark"],
        "time_spend": r["time_spend"],
      };
    }
    if (json['answered'] != null) {
      answered = json['answered'];
    }
  }
}

class MetaData {
  String? lp_duration;
  String? lp_preview;
  int? lp_passing_grade;
  String? _lp_instant_check;
  String? _lp_negative_marking;
  String? _lp_minus_skip_questions;
  int? lp_retake_count;
  int? _lp_pagination;
  bool? _lp_review;
  bool? _lp_show_correct_review;

  MetaData({this.lp_duration, this.lp_preview, this.lp_passing_grade});

  MetaData.fromJson(Map<String, dynamic> json) {
    lp_duration = json['_lp_duration'];
    lp_preview = json['_lp_preview'];
    if (json['_lp_retake_count'] != null) {
      lp_retake_count = int.tryParse(json['_lp_retake_count']?.toString() ?? '') ?? 0;
    }
    if (json['_lp_passing_grade'] != null) {
      lp_passing_grade = int.tryParse(json['_lp_passing_grade']?.toString() ?? '') ?? 0;
    }
  }
}

class QuestionModel {
  QuestionObject? object;
  int? id;
  String? title;
  String? type;
  int? point;
  String? content;
  List<OptionQuestion>? options;
  dynamic answer;
  dynamic value;
  String? hint;
  String? explanation;
  String? has_explanation;

  QuestionModel(
      {this.object, this.id, this.title, this.type, this.point, this.content,this.explanation,this.has_explanation});

  QuestionModel.fromJson(Map<String, dynamic> json) {
    if (json['object'] != null) {
      object = QuestionObject.fromJson(json['object']);
    }
    if (json['id'] != null) {
      id = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    }
    title = json['title'];
    type = json['type'];
    if (json['point'] != null) {
      point = int.tryParse(json['point']?.toString() ?? '') ?? 0;
    }
    content = json['content'];
    hint = json['hint'];
    if (json["options"] is List) {
      List<OptionQuestion> optionsTemp = [];
      json["options"].forEach((element) {
        OptionQuestion temp = OptionQuestion.fromJson(element);
        optionsTemp.add(temp);
      });
      options = optionsTemp;
    }
    explanation = json['explanation']?.toString();
    has_explanation = json['has_explanation']?.toString();
  }
}

class QuestionObject {
  String? object_type;

  QuestionObject({this.object_type});

  QuestionObject.fromJson(Map<String, dynamic> json) {
    object_type = json['object_type'];
  }
}

class OptionQuestion {
  String? title;
  String? value;
  int? uid;
  int? sorting;
  List<String>? ids;
  String? title_api;
  String? is_true;
  dynamic answers;

  OptionQuestion({
    this.title,
    this.value,
    this.uid,
    this.sorting,
    this.ids,
    this.title_api,
    this.is_true,
    this.answers});

  OptionQuestion.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
    if (json['uid'] != null) {
      uid = int.tryParse(json['uid']?.toString() ?? '') ?? 0;
    }

    if (json['ids'] is List) {
      List<String> rawIds = [];
      json['ids'].forEach((element) {
        rawIds.add(element.toString());
      });
      ids = rawIds;
    }
    if (json['answers'] != null) {
      answers = json['answers'];
    }
    title_api = json['title_api'];
    if (json["is_true"] != null) is_true = json["is_true"]?.toString();
    if (json["sorting"] != null) sorting = json["sorting"];
  }
}

class QuizModel extends LessonResult {
  List<QuestionModel>? questions;
  List<dynamic>? checked_questions = [];
  @override
  dynamic results;

  QuizModel({
    String? status,
    String? passing_grade,
    bool? negative_marking,
    bool? instant_check,
    int? retake_count,
    int? questions_per_page,
    bool? page_numbers,
    bool? review_questions,
    List<String>? support_options,
    int? duration,
    int? total_time,
    this.questions,
    this.checked_questions,
    dynamic results,
  }) : super(
    status: status,
    passing_grade: passing_grade,
    negative_marking: negative_marking,
    instant_check: instant_check,
    retake_count: retake_count,
    questions_per_page: questions_per_page,
    page_numbers: page_numbers,
    review_questions: review_questions,
    support_options: support_options,
    duration: duration,
    total_time: total_time,
  );

  QuizModel.fromJson(Map<String, dynamic> json) {
    if (json["questions"] is List) {
      List<QuestionModel> questionsTemp = [];
      json["questions"].forEach((element) {
        QuestionModel temp = QuestionModel.fromJson(element);
        questionsTemp.add(temp);
      });
      questions = questionsTemp;
    }
    results = json["results"];
  }

  @override
  String toString() {
    return 'QuizModel: {status: ${status}, passing_grade: ${passing_grade},negative_marking: ${negative_marking},instant_check: ${instant_check},passing_grade: ${passing_grade},retake_count: ${retake_count},questions_per_page: ${questions_per_page},page_numbers: ${page_numbers},review_questions: ${review_questions},support_options: ${support_options},duration: ${duration},total_time: ${total_time},questions:${questions})})';
  }
}

class QuizResults {
  List<String>? question_ids;
  List<QuestionModel>? questions;
  int? total_time;
  dynamic answered;
  int? duration;
  String? status;
  int? retaken;
  int? user_item_id;
  List<AttemptModel>? attempts;

  QuizResults({this.question_ids,
    this.questions,
    this.total_time,
    this.answered,
    this.duration,
    this.status,
    this.retaken,
    this.user_item_id,
    this.attempts});

  QuizResults.fromJson(Map<String, dynamic> json) {
    if (json['duration'] != null) {
      duration = int.tryParse(json['duration']?.toString() ?? '') ?? 0;
    }
    if (json['retaken'] != null) {
      retaken = int.tryParse(json['retaken']?.toString() ?? '') ?? 0;
    }
    if (json['user_item_id'] != null) {
      user_item_id = int.tryParse(json['user_item_id']?.toString() ?? '') ?? 0;
    }
    if (json['total_time'] != null) {
      total_time = int.tryParse(json['total_time']?.toString() ?? '') ?? 0;
    }
    status = json['status'];
    answered = json['answered'];
    if (json["question_ids"] is List) {
      List<String> rawIds = [];
      json["question_ids"].forEach((id) {
        rawIds.add(id);
      });
      question_ids = rawIds;
    }
    if (json["questions"] is List) {
      List<QuestionModel> questionsModel = [];
      json["questions"].forEach((question) {
        QuestionModel temp = QuestionModel.fromJson(question);
        questionsModel.add(temp);
      });
      questions = questionsModel;
    }
  }
}

class AttemptModel {
  int? mark;
  int? user_mark;
  int? minus_point;
  int? question_count;
  int? question_empty;
  int? question_answered;
  int? question_wrong;
  int? question_correct;
  String? status;
  int? result;
  String? time_spend;
  String? passing_grade;
  int? pass;
}

class LessonsAssignment {
  String? id;
  String? name;
  String? slug;
  String? permalink;
  String? date_created;
  String? date_created_gmt;
  String? date_modified;
  String? date_modified_gmt;
  String? status;
  String? content;
  String? excerpt;
  dynamic assigned;
  int? retake_count;
  int? retaken;
  AssignmentDuration? duration;
  String? introdution;
  String? passing_grade;
  String? allow_file_type;
  int? files_amount;
  dynamic attachment;
  dynamic results;
  AssignmentAnswer? assignment_answer;
  bool? can_finish_course;

  LessonsAssignment({
    this.id,
    this.name,
    this.slug,
    this.permalink,
    this.date_created,
    this.date_created_gmt,
    this.date_modified,
    this.date_modified_gmt,
    this.status,
    this.content,
    this.excerpt,
    this.assigned,
    this.retake_count,
    this.retaken,
    this.duration,
    this.introdution,
    this.passing_grade,
    this.allow_file_type,
    this.attachment,
    this.results,
    this.files_amount,
    this.can_finish_course
});
  LessonsAssignment.fromJson(Map<String, dynamic> json){
    id = json['id']?.toString();
    name = json['name'];
    slug = json['slug'];
    permalink = json['permalink'];
    date_created = json['date_created'];
    date_created_gmt = json['date_created_gmt'];
    date_modified = json['date_modified'];
    date_modified_gmt = json['date_modified_gmt'];
    status = json['status'];
    content = json['content'];
    excerpt = json['excerpt'];
    assigned =json['assigned'];
    passing_grade =json['passing_grade'];
    allow_file_type =json['allow_file_type'];
    introdution =json['introdution'];
    attachment =json['attachment'];
    can_finish_course =json['can_finish_course'];
    if (json['retake_count'] != null) {
      retake_count = int.tryParse(json['retake_count']?.toString() ?? '') ?? 0;
    }
    if (json['retaken'] != null) {
      retaken = int.tryParse(json['retaken']?.toString() ?? '') ?? 0;
    }
    if (json['files_amount'] != null) {
      files_amount = int.tryParse(json['files_amount']?.toString() ?? '') ?? 0;
    }

    if(json['duration'] != null){
      duration = AssignmentDuration.fromJson(json['duration']);
    }
    if(json['results'] != null){
      results = json['results'];
    }


    if (json['assignment_answer'] != null && json['assignment_answer'] is Map && (json['assignment_answer'] as Map).isNotEmpty) {
      assignment_answer = AssignmentAnswer.fromJson(json['assignment_answer']);
    }
  }

}

class AssignmentDuration {
  String? format;
  int? time;
  int? time_remaining;

  AssignmentDuration(this.format, this.time, this.time_remaining);

  AssignmentDuration.fromJson(Map<String, dynamic> json) {
    if (json['time'] != null) {
      time = int.tryParse(json['time']?.toString() ?? '') ?? 0;
    }
    if (json['time_remaining'] != null) {
      time_remaining = int.tryParse(json['time_remaining']?.toString() ?? '') ?? 0;
    }
    format = json['format'];
  }
}

class AssignmentResults {
  String? status;
  String? start_time;
  String? expiration_time;
  bool? end_time;

  AssignmentResults.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    start_time = json['start_time']?.toString();
    expiration_time = json['expiration_time'];
    end_time = json['end_time'];
  }

  AssignmentResults(this.status, this.start_time, this.expiration_time,
      this.end_time);
}

class AssignmentAnswer{
  String? note;
  List<Map<String, dynamic>>? file;

  AssignmentAnswer(this.note, this.file);
  AssignmentAnswer.fromJson(Map<String, dynamic> data){
    note = data['note'];
    if (data['file'] != null && data['file'] is Map && (data['file'] as Map).isNotEmpty) {
      Map<String, dynamic> jsonDataMap = data['file'];
      List<Map<String, dynamic>> dataList = [];
      jsonDataMap.forEach((key, value) {
        Map<String, dynamic> item = {};
        item[key]=value;
        dataList.add(item);
      });
      file = dataList;
    }
  }
}

class AnswerDataCheck{
  String? explanation;
  String? message;
  AnswerDataResult? result;
  List<OptionQuestion>? options;

  AnswerDataCheck(this.explanation, this.message, this.result, this.options);
  AnswerDataCheck.fromJson(Map<String, dynamic> data){
    explanation = data['explanation'];
    message = data['message'];
    if(data['result'] != null){
      result = AnswerDataResult.fromJson(data['result']);
    }
    if(data['options'] is List){
      List<OptionQuestion> dataOptions = [];
      data["options"].forEach((item) {
        dataOptions.add(OptionQuestion.fromJson(item));
        });
      options = dataOptions;
    }
  }
}

class AnswerDataResult{
  dynamic answered;
  bool? correct;
  String? mark;
  AnswerDataResult(this.answered, this.correct, this.mark);
  AnswerDataResult.fromJson(Map<String, dynamic> data){
    answered = data['answered'];
    correct = data['correct'];
    mark = data['mark']?.toString();
  }
}