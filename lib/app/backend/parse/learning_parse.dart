import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class LearningParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  LearningParser(
      {required this.apiService, required this.sharedPreferencesManager});

  Future<Response> getLessonsList(var params) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.lessons.list, token, params);
      return response;
    } catch (e) {
      debugPrint('getLessonsList error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> getQuizzesList(var params) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.quiz.list, token, params);
      return response;
    } catch (e) {
      debugPrint('getQuizzesList error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> getAssignmentsList(var params) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.assignment.list, token, params);
      return response;
    } catch (e) {
      debugPrint('getAssignmentsList error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> getLesson(String id) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.lessons.detail(int.parse(id)), token, null);
      return response;
    } catch (e) {
      debugPrint('getLesson error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> getQuiz(String id) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.quiz.detail(int.parse(id)), token, null);
      return response;
    } catch (e) {
      debugPrint('getQuiz error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> getAssignment(String id) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.assignment.detail(int.parse(id)), token, null);
      return response;
    } catch (e) {
      debugPrint('getAssignment error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> quizStart(int id) async {
    try {
      var param = {"id": id};
      String token = getToken();
      var response =
          await apiService.postPrivate(ApiEndpoints.quiz.start, param, token);
      return response;
    } catch (e) {
      debugPrint('quizStart error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> finishQuiz(String id, dynamic itemTemp) async {
    try {
      var param = {
        "id": id,
        "answered": itemTemp,
      };
      String token = getToken();
      var response =
          await apiService.postPrivate(ApiEndpoints.quiz.finish, param, token);
      return response;
    } catch (e) {
      debugPrint('finishQuiz error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> completeLesson(String id) async {
    try {
      var param = {"id": int.parse(id)};
      String token = getToken();
      var response =
          await apiService.postPrivate(ApiEndpoints.lessons.finish, param, token);
      return response;
    } catch (e) {
      debugPrint('completeLesson error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> finish(String id) async {
    try {
      var param = {"id": int.parse(id)};
      String token = getToken();
      var response =
          await apiService.postPrivate(ApiEndpoints.courses.finish, param, token);
      return response;
    } catch (e) {
      debugPrint('finish error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> checkQuestion(param) async {
    try {
      String token = getToken();
      var response =
          await apiService.postPrivate(ApiEndpoints.quiz.checkAnswer, param, token);
      return response;
    } catch (e) {
      debugPrint('checkQuestion error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> retakeAssignment(id) async {
    try {
      String token = getToken();
      var param = {"id": int.parse(id)};
      var response =
          await apiService.postPrivate(ApiEndpoints.assignment.retake, param, token);
      return response;
    } catch (e) {
      debugPrint('retakeAssignment error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> startAssignment(id) async {
    try {
      String token = getToken();
      var param = {"id": int.parse(id)};
      var response =
          await apiService.postPrivate(ApiEndpoints.assignment.start, param, token);
      return response;
    } catch (e) {
      debugPrint('startAssignment error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> deleteFileAssignment(id, fileId) async {
    try {
      String token = getToken();
      var param = {
        "id": int.parse(id),
        "fileId": fileId,
      };
      var response =
          await apiService.postPrivate(ApiEndpoints.assignment.deleteFile, param, token);
      return response;
    } catch (e) {
      debugPrint('deleteFileAssignment error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> saveOrSendAssignment(Map<String, dynamic> param) async {
    try {
      String token = getToken();
      var body = {
        "id": int.parse(param['id']),
        "note": param['note'].toString(),
        "action": param['action'] ?? "send",
        "files": param['files']
      };
      var response =
          await apiService.uploadFilesAssignment(ApiEndpoints.assignment.submit, body, token);
      return response;
    } catch (e) {
      debugPrint('saveOrSendAssignment error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> checkAnswer(String lessonId, String question_id, answered) async {
    try {
      String token = getToken();
      var param = {
        "id": int.parse(lessonId),
        "question_id": int.parse(question_id),
        "answered": answered,
      };
      var response =
          await apiService.postPrivate(ApiEndpoints.quiz.checkAnswer, param, token);
      return response;
    } catch (e) {
      debugPrint('checkAnswer error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
