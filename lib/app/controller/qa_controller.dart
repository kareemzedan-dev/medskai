import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/qa_model.dart';
import 'package:flutter_app/app/backend/parse/qa_parse.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:get/get.dart';

class QaController extends GetxController {
  final QaParser parser;
  final int courseId;

  QaController({required this.parser, required this.courseId});

  bool isLoading = true;
  bool isSubmitLoading = false;
  List<QaQuestionModel> questions = [];

  TextEditingController subjectController = TextEditingController();
  TextEditingController questionController = TextEditingController();
  TextEditingController replyController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getQuestions();
  }

  Future<void> getQuestions() async {
    isLoading = true;
    update();

    var response = await parser.getQuestions(courseId);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body != null && response.body is List) {
        questions = (response.body as List)
            .map((e) => QaQuestionModel.fromJson(e))
            .toList();
      } else if (response.body != null && response.body['data'] is List) {
        questions = (response.body['data'] as List)
            .map((e) => QaQuestionModel.fromJson(e))
            .toList();
      }
    } else {
      debugPrint('Error getting questions');
    }
    isLoading = false;
    update();
  }

  Future<void> submitQuestion() async {
    if (subjectController.text.trim().isEmpty || questionController.text.trim().isEmpty) {
      showToast('Please fill all fields');
      return;
    }

    isSubmitLoading = true;
    update();

    Map<String, dynamic> body = {
      'subject': subjectController.text,
      'question': questionController.text,
    };

    var response = await parser.submitQuestion(courseId, body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      showToast('Question submitted successfully');
      subjectController.clear();
      questionController.clear();
      Get.back(); // close modal
      getQuestions();
    } else {
      showToast('Failed to submit question', isError: true);
    }
    isSubmitLoading = false;
    update();
  }

  Future<void> submitReply(int questionId) async {
    if (replyController.text.trim().isEmpty) {
      showToast('Please enter a reply');
      return;
    }

    isSubmitLoading = true;
    update();

    Map<String, dynamic> body = {
      'answer': replyController.text,
    };

    var response = await parser.submitReply(questionId, body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      showToast('Reply submitted successfully');
      replyController.clear();
      Get.back(); // close modal
      getQuestions();
    } else {
      showToast('Failed to submit reply', isError: true);
    }
    isSubmitLoading = false;
    update();
  }
}
