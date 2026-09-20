import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/mobx-store/learning_quiz_store.dart';
import 'package:flutter_app/app/backend/parse/course_detail_parse.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:flutter_app/app/backend/models/learning-lesson-model.dart';
import 'package:flutter_app/app/backend/models/lesson-model.dart';
import 'package:flutter_app/app/backend/parse/learning_parse.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../backend/models/course_model.dart';
import '../core/error/app_error.dart';
import '../core/error/error_handler.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/offline_storage.dart';
import '../helper/dialog_helper.dart';
import '../helper/router.dart';
import '../util/toast.dart';
import '../util/theme.dart';

class LearningController extends GetxController {
  final LearningParser parser;
  final CourseDetailParser courseDetailParser;

  LearningController({required this.parser, required this.courseDetailParser});

  String courseId = "";
  ItemLesson? lesson;
  int? index;
  int? indexLesson;
  int indexCurrentShowLesson = -1;
  bool isCheckCurrentShowLesson = false;
  LearningLessonModel _data = LearningLessonModel();
  final ScrollController scrollController = ScrollController();

  LearningLessonModel get data => _data;
  LessonsAssignment _dataAssignment = LessonsAssignment();
  Map<String, AnswerDataCheck> _answerDataCheck = {};

  Map<String, AnswerDataCheck> get listAnswerDataCheck => _answerDataCheck;

  LessonsAssignment get dataAssignment => _dataAssignment;
  bool isLesson = false;
  bool isQuiz = false;
  bool isStartQuiz = false;
  bool isAssignment = false;
  bool isAssignmentFileUpload = false;
  bool isShowMenu = true;
  List<PlatformFile> assignmentFiles = [];
  bool isLoadingMore = true;
  bool isLoadingLesson = true;
  bool hasError = false;
  String errorMessage = '';
  AppError? appError;
  List<dynamic> listAnswer = [];

  QuizModel _dataQuiz = QuizModel();

  QuizModel get dataQuiz => _dataQuiz;
  QuestionModel? itemQuestion;
  int? pageActive = 0;
  int? id;
  int? sectionId;
  dynamic itemCheck = [];
  final courseStore = locator<CourseStore>();
  final learningQuizStore = locator<LearningQuizStore>();
  CourseModel _courseModel = CourseModel();

  CourseModel get courseModel => _courseModel;
  TextEditingController answerAssignment = TextEditingController();
  Map<String, TextEditingController> listTextFieldQuiz = {};

  // ── Progress & Navigation helpers (T002-T006) ──

  /// Flat ordered list of all lesson items across all sections
  List<ItemLesson> get flatLessonList {
    if (_courseModel.sections == null) return [];
    final List<ItemLesson> flat = [];
    for (final section in _courseModel.sections!) {
      if (section.items != null) {
        flat.addAll(section.items!);
      }
    }
    return flat;
  }

  /// Progress tracking
  int get completedCount =>
      flatLessonList.where((i) => i.status == 'completed').length;
  int get totalCount => flatLessonList.length;
  double get progressPercent =>
      totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

  /// Current lesson index in flat list
  int get currentFlatIndex {
    if (lesson?.id == null) return -1;
    return flatLessonList.indexWhere((i) => i.id == lesson!.id);
  }

  /// Previous / Next lesson items
  ItemLesson? get previousLesson {
    final idx = currentFlatIndex;
    return (idx > 0) ? flatLessonList[idx - 1] : null;
  }

  ItemLesson? get nextLesson {
    final idx = currentFlatIndex;
    return (idx >= 0 && idx < flatLessonList.length - 1)
        ? flatLessonList[idx + 1]
        : null;
  }

  /// Find the sectionId for a given item
  int? _sectionIdForItem(ItemLesson item) {
    if (_courseModel.sections == null) return null;
    for (final section in _courseModel.sections!) {
      if (section.items?.any((i) => i.id == item.id) == true) {
        return section.id;
      }
    }
    return null;
  }

  /// Find the section index for a given item
  int _sectionIndexForItem(ItemLesson item) {
    if (_courseModel.sections == null) return 0;
    for (int i = 0; i < _courseModel.sections!.length; i++) {
      if (_courseModel.sections![i].items?.any((x) => x.id == item.id) ==
          true) {
        return i;
      }
    }
    return 0;
  }

  /// Navigate to previous lesson
  Future<void> onPrevious() async {
    final prev = previousLesson;
    if (prev == null) return;
    sectionId = _sectionIdForItem(prev);
    indexLesson = _sectionIndexForItem(prev);
    onNavigateLearning(prev);
    if (scrollController.hasClients) {
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // ── End Progress & Navigation helpers ──

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args == null || args is! List || args.length < 4 || args[0] == null) {
      hasError = true;
      isLoadingLesson = false;
      errorMessage = tr(LocaleKeys.errorMessages_loadLesson);
      update();
      return;
    }
    lesson = args[0];
    index = args[1];
    courseId = args[2].toString();
    sectionId = args[3];
    getCourseDetail();
    getLesson();
    scrollController.addListener(_onScroll);
  }

  handleResetFileAssignment() {
    isAssignmentFileUpload = false;
    assignmentFiles = [];
  }

  handleOnInitAnswered() async {
    final response = await parser.getQuiz(lesson!.id.toString());
    Map<String, AnswerDataCheck> data = {};
    if (response.statusCode == 200) {
      LearningLessonModel lessonModel =
          LearningLessonModel.fromJson(response.body);
      if (lessonModel.results?.answered?.isNotEmpty == true) {
        lessonModel.results?.answered?.forEach((questionId, value) {
          if (value['answered'] != '') {
            var question = lessonModel.questions?.firstWhereOrNull(
                (element) => element.id.toString() == questionId.toString());
            data[questionId.toString()] = AnswerDataCheck(
                question?.explanation,
                '',
                AnswerDataResult(value['answered'], value['correct'],
                    value['mark'].toString()),
                question?.options);
          }
        });
        _answerDataCheck = data;
        update();
      }
    }
  }

  getIndexLesion() {
    if (courseModel.sections == null) return 0;
    ItemLesson? itemRedirect = ItemLesson();
    int i = 0;
    for (var item in courseModel.sections!) {
      itemRedirect = item.items?.firstWhere(
        (x) => x.status != 'completed',
        orElse: () => ItemLesson(),
      );
      if (itemRedirect?.id != null) {
        if (item.items != null &&
            item.items!.isNotEmpty &&
            item.items!.last.id == itemRedirect?.id) {
          i++;
        }
        break;
      }
      i++;
    }
    return i;
  }

  getCourseDetail() async {
    try {
      final response = await courseDetailParser.getDetailCourse(courseId);
      if (response.statusCode == 200) {
        _courseModel = CourseModel.fromJson(response.body);
        courseStore.setDetail(_courseModel);
        update();
      }
    } catch (e) {
      debugPrint('getCourseDetail error: $e');
    }
  }

  Future<void> refreshData() async {
    getCourseDetail();
    getLesson();
  }

  Future<void> callBackFinishQuiz() async {
    onFinish();
  }

  Future<void> onFinish() async {
    final itemTemp = <String, dynamic>{};
    learningQuizStore.dataQuiz?.questions?.forEach((question) {
      if (itemCheck.length != 0 &&
          itemCheck.firstWhere(
                (y) => y.id == question.id,
                orElse: () => null,
              ) ==
              null) {
        return;
      }
      if (question.type == 'sorting_choice') {
        itemTemp[question.id.toString()] =
            question.options?.map((item) => item.value).toList();
      } else if (question.answer != null) {
        if (question.type == 'true_or_false') {
          var answers = question.answer;
          if (answers is List && answers.isNotEmpty) {
            itemTemp[question.id.toString()] = answers[0].value;
          }
        } else if (question.type == 'fill_in_blanks') {
          itemTemp[question.id.toString()] = question.answer;
        } else if (question.type == 'multi_choice') {
          itemTemp[question.id.toString()] =
              question.answer.map((item) => item.value).toList();
        } else {
          itemTemp[question.id.toString()] =
              question.answer.map((item) => item.value).toList();
        }
      }
    });
    final response = await parser.finishQuiz(lesson!.id.toString(), itemTemp);
    if (response.body is Map && response.body["status"] == "success") {
      reloadFinish();
    } else {
      final context = Get.context;
      if (context == null) return;
      String errorMsg = sanitizeToastMessage(
          response.body?["message"]?.toString() ??
              tr(LocaleKeys.learningErrors_quizSubmissionFailed));
      Alert(context: context, title: tr(LocaleKeys.error), desc: errorMsg)
          .show();
    }
  }

  Future<void> reloadFinish() async {
    isShowMenu = false;
    pageActive = 0;
    _data = LearningLessonModel();
    final response = await parser.getQuiz(lesson!.id.toString());

    if (response.statusCode == 200) {
      LearningLessonModel temp = LearningLessonModel.fromJson(response.body);
      _data = temp;
      isQuiz = true;
      isStartQuiz = false;
      _dataQuiz = QuizModel(
          questions: temp.questions,
          status: temp.results?.status,
          passing_grade: temp.results?.passing_grade,
          negative_marking: temp.results?.negative_marking,
          instant_check: temp.results?.instant_check,
          retake_count: temp.results?.retake_count,
          questions_per_page: temp.results?.questions_per_page,
          page_numbers: temp.results?.page_numbers,
          review_questions: temp.results?.review_questions,
          support_options: temp.results?.support_options,
          duration: temp.results?.duration,
          results: temp.results);
      learningQuizStore.setData(_dataQuiz);
      update();
    }
  }

  Future<void> onStartQuiz() async {
    final responseStart = await parser.quizStart(id!);
    final response = await parser.getQuiz(id.toString());
    final context = Get.context;
    if (context == null) return;
    if (response.statusCode == 200) {
      if (responseStart.body?["status"] == "success") {
        listAnswer = [];
        isStartQuiz = true;
        LearningLessonModel temp = LearningLessonModel.fromJson(response.body);
        _dataQuiz = QuizModel(
            questions: temp.questions,
            status: temp.results?.status,
            passing_grade: temp.results?.passing_grade,
            negative_marking: temp.results?.negative_marking,
            instant_check: temp.results?.instant_check,
            retake_count: temp.results?.retake_count,
            questions_per_page: temp.results?.questions_per_page,
            page_numbers: temp.results?.page_numbers,
            review_questions: temp.results?.review_questions,
            support_options: temp.results?.support_options,
            duration: temp.results?.duration,
            total_time: temp.results?.total_time,
            results: temp.results);
        learningQuizStore.setData(_dataQuiz);
        if (temp.questions != null && temp.questions!.isNotEmpty) {
          itemQuestion = temp.questions![0];
          learningQuizStore.setQuestion(itemQuestion);
          update();
        }
      } else {
        String msg = sanitizeToastMessage(
            responseStart.body?["message"]?.toString() ??
                tr(LocaleKeys.learningErrors_quizStartFailed));
        Alert(context: context, title: tr(LocaleKeys.error), desc: msg).show();
      }
    } else {
      String msg = sanitizeToastMessage(response.body?["message"]?.toString() ??
          tr(LocaleKeys.learningErrors_quizLoadFailed));
      Alert(context: context, title: tr(LocaleKeys.error), desc: msg).show();
    }
  }

  List<LessonModel> dataLesson() {
    List<LessonModel> dataTemp = [];
    _courseModel.sections?.forEach((obj) => dataTemp.add(obj));
    return dataTemp;
  }

  void onNavigateLearning(value) {
    lesson = value;
    List<LessonModel> dataTemp = dataLesson();
    if (dataTemp.isEmpty) return;
    index = dataTemp.indexWhere((x) => x.id == sectionId);
    getLesson();
  }

  void retryLoadData() {
    hasError = false;
    errorMessage = '';
    appError = null;
    isLoadingLesson = true;
    update();
    getCourseDetail();
    getLesson();
  }

  Future<void> getLesson() async {
    isLoadingLesson = true;
    hasError = false;
    update();
    try {
      // Check offline storage for lessons when offline
      final offlineStorage = Get.find<OfflineStorage>();
      final connectivity = Get.find<ConnectivityService>();

      if (lesson?.type == 'lp_lesson') {
        // Try offline content first when offline
        if (!connectivity.isOnline.value &&
            offlineStorage.isAvailable(lesson!.id.toString())) {
          final offlineData = offlineStorage.getLesson(lesson!.id.toString());
          if (offlineData != null) {
            LearningLessonModel temp =
                LearningLessonModel.fromJson(offlineData);
            _data = temp;
            isLesson = true;
            isQuiz = false;
            isAssignment = false;
            id = lesson?.id;
            isLoadingLesson = false;
            update();
            return;
          }
        }

        final response = await parser.getLesson(lesson!.id.toString());
        if (response.statusCode == 200) {
          LearningLessonModel temp =
              LearningLessonModel.fromJson(response.body);
          _data = temp;
          isLesson = true;
          isQuiz = false;
          isAssignment = false;
          // Save lesson content for offline access
          await offlineStorage.saveLesson(lesson!.id.toString(), response.body);
        }
      }
      if (lesson?.type == 'lp_quiz') {
        final quizKey = 'quiz_${lesson!.id}';

        // Try offline content first when offline
        if (!connectivity.isOnline.value &&
            offlineStorage.isAvailable(quizKey)) {
          final offlineData = offlineStorage.getLesson(quizKey);
          if (offlineData != null) {
            _parseQuizData(offlineData);
            id = lesson?.id;
            isLoadingLesson = false;
            update();
            return;
          }
        }

        final response = await parser.getQuiz(lesson!.id.toString());
        if (response.statusCode == 200) {
          await offlineStorage.saveLesson(quizKey, response.body);
          _parseQuizData(response.body);
        }
      }
      if (lesson?.type == 'lp_assignment') {
        final assignKey = 'assignment_${lesson!.id}';

        // Try offline content first when offline
        if (!connectivity.isOnline.value &&
            offlineStorage.isAvailable(assignKey)) {
          final offlineData = offlineStorage.getLesson(assignKey);
          if (offlineData != null) {
            isAssignment = true;
            isLesson = false;
            isQuiz = false;
            LessonsAssignment temp = LessonsAssignment.fromJson(offlineData);
            _dataAssignment = temp;
            answerAssignment.text =
                _dataAssignment.assignment_answer?.note ?? "";
            id = lesson?.id;
            isLoadingLesson = false;
            update();
            return;
          }
        }

        isAssignment = true;
        isLesson = false;
        isQuiz = false;
        final response = await parser.getAssignment(lesson!.id.toString());
        if (response.statusCode == 200) {
          await offlineStorage.saveLesson(assignKey, response.body);
          LessonsAssignment temp = LessonsAssignment.fromJson(response.body);
          _dataAssignment = temp;
          answerAssignment.text = _dataAssignment.assignment_answer?.note ?? "";
        }
      }
      //current lesson id
      id = lesson?.id;
    } catch (e) {
      hasError = true;
      bool isOffline = false;
      try {
        isOffline = !(Get.find<ConnectivityService>().isOnline.value);
      } catch (_) {}
      if (isOffline) {
        errorMessage =
            'This content is not available offline. Open it once while online to save it.';
      } else {
        appError = ErrorHandler.fromException(e);
        errorMessage = appError!.title;
      }
      debugPrint('getLesson error: $e');
    }
    isLoadingLesson = false;
    update();
  }

  Future<void> onNext() async {
    final next = nextLesson;
    if (next == null) return;
    sectionId = _sectionIdForItem(next);
    indexLesson = _sectionIndexForItem(next);
    onNavigateLearning(next);
    if (scrollController.hasClients) {
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> onActiveQuiz(item, index) async {
    learningQuizStore.setQuestion(item);
    pageActive = index;
    update();
  }

  Future<void> onPrevQuiz() async {
    if (dataQuiz.questions == null || pageActive == null || pageActive! <= 0) {
      return;
    }
    learningQuizStore.setQuestion(dataQuiz.questions![pageActive! - 1]);
    pageActive = pageActive! - 1;
    update();
  }

  Future<void> onNextQuiz() async {
    final context = Get.context;
    if (context == null) return;
    if (dataQuiz.questions == null || pageActive == null) return;
    if (dataQuiz.questions!.length <= pageActive! + 1) {
      Alert(
              context: context,
              title: "",
              desc: tr(LocaleKeys.learningScreen_quiz_nextQuestion))
          .show();
      return;
    }
    learningQuizStore.setQuestion(dataQuiz.questions![pageActive! + 1]);
    pageActive = pageActive! + 1;
    update();
  }

  Future<void> onCompleteLesson() async {
    DialogHelper.showLoading();
    try {
      final response = await parser.completeLesson(id.toString());
      if (isClosed) {
        DialogHelper.hideLoading();
        return;
      }
      DialogHelper.hideLoading();

      final body = response.body;
      if (response.statusCode == 200 &&
          body is Map &&
          body["status"] == 'success') {
        successToast(
            tr(LocaleKeys.learningScreen_lesson_notificationLessonSuccess));
        await getCourseDetail();
        onNext();
      } else {
        showToast(sanitizeToastMessage(
            response.body?["message"]?.toString() ?? tr(LocaleKeys.error)));
      }
    } catch (e) {
      DialogHelper.hideLoading();
      debugPrint('onCompleteLesson error: $e');
    }
  }

  Future<void> onFinishCourse() async {
    final context = Get.context;
    if (context == null) return;
    Alert(
      context: context,
      title: tr(LocaleKeys.learningScreen_finishCourseAlert_title),
      desc: tr(LocaleKeys.learningScreen_finishCourseAlert_description),
      buttons: [
        DialogButton(
          color: MedsKaiColors.error,
          child: Text(
            tr(LocaleKeys.learningScreen_finishCourseAlert_cancel),
            style: const TextStyle(color: MedsKaiColors.white),
          ),
          onPressed: () => {Navigator.pop(context)},
        ),
        DialogButton(
          child: Text(
            tr(LocaleKeys.learningScreen_finishCourseAlert_ok),
            style: const TextStyle(color: MedsKaiColors.white),
          ),
          onPressed: () => {Navigator.pop(context), onFinishAPI()},
        ),
      ],
    ).show();
  }

  Future<void> onFinishAPI() async {
    final response = await parser.finish(courseId.toString());
    if (response.statusCode == 200) {
      Get.toNamed(AppRouter.getCourseDetailRoute(),
          arguments: [courseId, "reloadPage"], preventDuplicates: false);
    }
  }

  Future<void> selectQuestion(item) async {
    try {
      if (learningQuizStore.itemQuestion?.type == 'single_choice') {
        learningQuizStore.itemQuestion?.answer = [item];
      }
      if (learningQuizStore.itemQuestion?.type == 'true_or_false') {
        learningQuizStore.itemQuestion?.answer = [item];
      }
      if (learningQuizStore.itemQuestion?.type == 'multi_choice') {
        if (learningQuizStore.itemQuestion?.answer != null &&
            learningQuizStore.itemQuestion?.answer.isNotEmpty) {
          dynamic temp = learningQuizStore.itemQuestion?.answer?.firstWhere(
            (x) => x.value == item.value,
            orElse: () => null,
          );
          if (temp != null) {
            learningQuizStore.itemQuestion?.answer = learningQuizStore
                .itemQuestion?.answer
                .where((x) => x.value != item.value)
                .toList();
          } else {
            learningQuizStore.itemQuestion?.answer = [
              ...learningQuizStore.itemQuestion?.answer,
              item
            ];
          }
        } else {
          learningQuizStore.itemQuestion?.answer = [item];
        }
      }

      if (learningQuizStore.itemQuestion?.type != 'sorting_choice') {
        var index = listAnswer.indexWhere((x) =>
            x['id'].toString() ==
            learningQuizStore.itemQuestion?.id.toString());

        if (index != -1 &&
            learningQuizStore.itemQuestion?.type == 'multi_choice') {
          List<dynamic> currentDataAnswered;
          try {
            currentDataAnswered = json.decode(listAnswer[index]["answered"]);
          } catch (e) {
            debugPrint('json.decode error in selectQuestion: $e');
            currentDataAnswered = [];
          }
          if (currentDataAnswered.contains(item.value.toString())) {
            currentDataAnswered.remove(item.value.toString());
          } else {
            currentDataAnswered.add(item.value.toString());
          }
          listAnswer[index] = {
            "id": learningQuizStore.itemQuestion?.id,
            "answered": json.encode(currentDataAnswered)
          };
        } else if (index != -1 &&
            learningQuizStore.itemQuestion?.type == 'single_choice') {
          listAnswer[index] = {
            "id": learningQuizStore.itemQuestion?.id,
            "answered": item.value.toString()
          };
        } else {
          List data = [];
          if (learningQuizStore.itemQuestion?.type == 'multi_choice') {
            data.add(item.value);
          }
          listAnswer.add({
            "id": learningQuizStore.itemQuestion?.id,
            "answered": learningQuizStore.itemQuestion?.type == 'multi_choice'
                ? json.encode(data)
                : item.value
          });
        }
      }
      update();
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> onChangeFillBlank(id, value) async {
    if (learningQuizStore.itemQuestion?.answer != null) {
      if (learningQuizStore.itemQuestion?.answer[id] == value) {
        learningQuizStore.itemQuestion?.answer[id] = value;
      } else {
        learningQuizStore.itemQuestion?.answer[id] = value;
      }
    } else {
      learningQuizStore.itemQuestion?.answer = {};
      learningQuizStore.itemQuestion?.answer[id] = value;
    }
    //check index question exits
    var index = listAnswer.indexWhere((x) =>
        x['id'].toString() == learningQuizStore.itemQuestion?.id.toString());

    if (index != -1) {
      listAnswer[index]['answered'][id] = value;
    } else {
      var mapValue = {};
      mapValue[id] = value;
      listAnswer.add(
          {"id": learningQuizStore.itemQuestion?.id, "answered": mapValue});
    }
  }

  handleRenderFieldControl(id) {
    if (learningQuizStore.itemQuestion?.answer != null &&
        listTextFieldQuiz.isNotEmpty) {
      var textController = listTextFieldQuiz[id];
      if (learningQuizStore.itemQuestion?.answer[id] != null) {
        textController?.text = learningQuizStore.itemQuestion?.answer[id];
      }
      return textController;
    } else {
      var textController = TextEditingController();
      listTextFieldQuiz[id] = textController;
    }
  }

  Future<void> onCheck() async {
    final context = Get.context;
    if (context == null) return;
    if (learningQuizStore.itemQuestion?.answer == null &&
        learningQuizStore.itemQuestion?.type != 'sorting_choice') {
      Alert(
              context: context,
              title: "",
              desc: tr(LocaleKeys.learningScreen_quiz_checkAlert))
          .show();
      return;
    }
    var itemTemp = {};
    if (learningQuizStore.itemQuestion?.type == 'sorting_choice') {
      itemTemp['value'] =
          learningQuizStore.itemQuestion?.options?.map((y) => y.value).toList();
    } else if (learningQuizStore.itemQuestion?.answer != null) {
      if (learningQuizStore.itemQuestion?.type == 'true_or_false') {
        itemTemp['value'] = learningQuizStore.itemQuestion?.answer.value;
      } else if (learningQuizStore.itemQuestion?.type == 'fill_in_blanks') {
        itemTemp['value'] = learningQuizStore.itemQuestion?.answer;
      } else if (learningQuizStore.itemQuestion?.type == 'multi_choice') {
        itemTemp['value'] =
            learningQuizStore.itemQuestion?.answer.map((y) => y.value).toList();
      } else {
        itemTemp['value'] =
            learningQuizStore.itemQuestion?.answer.map((y) => y.value).toList();
      }
    }
    var param = {
      'id': lesson?.id,
      'question_id': learningQuizStore.itemQuestion?.id,
      'answered': itemTemp['value'],
    };
    final response = await parser.checkQuestion(param);
    final body = response.body;
    if (response.statusCode == 200 &&
        body is Map &&
        (body["code"] == 'cannot_check_answer' || body["status"] == 'error')) {
      Alert(
              context: context,
              title: sanitizeToastMessage(body["message"]?.toString() ?? ''))
          .show();
    }
    var dataTemp = {
      'id': learningQuizStore.itemQuestion?.id,
      'result': body is Map ? body['result'] : null,
      'explanation': body is Map ? body['explanation'] : null,
    };
    if (body is Map && body['options'] != null) {
      learningQuizStore.itemQuestion!.options = body['options'];
    }
    itemCheck.add(dataTemp);
    update();
  }

  Future<void> showHint() async {
    final context = Get.context;
    if (context == null) return;
    if (learningQuizStore.itemQuestion?.hint != null) {
      Alert(
        context: context,
        title: tr(LocaleKeys.learningScreen_quiz_hint),
        desc: learningQuizStore.itemQuestion?.hint,
        buttons: [
          DialogButton(
            child: Text(
              tr(LocaleKeys.learningScreen_finishCourseAlert_cancel),
              style: const TextStyle(color: MedsKaiColors.white),
            ),
            onPressed: () => {Navigator.pop(context)},
          ),
        ],
      ).show();
    } else {
      Alert(
        context: context,
        title: tr(LocaleKeys.learningScreen_quiz_hintEmpty),
        buttons: [
          DialogButton(
            child: Text(
              tr(LocaleKeys.learningScreen_finishCourseAlert_cancel),
              style: const TextStyle(color: MedsKaiColors.white),
            ),
            onPressed: () => {Navigator.pop(context)},
          ),
        ],
      ).show();
    }
  }

  bool isDisable() {
    if (itemCheck.length != 0 &&
        itemCheck?.firstWhere(
              (x) => x['id'] == learningQuizStore.itemQuestion?.id,
              orElse: () => null,
            ) !=
            null) {
      return true;
    }
    if (learningQuizStore.dataQuiz?.checked_questions != null &&
        learningQuizStore.dataQuiz?.checked_questions?.firstWhere(
              (x) => x == learningQuizStore.itemQuestion?.id,
              orElse: () => null,
            ) !=
            null) {
      return true;
    }
    return false;
  }

  Future<void> onUploadFiles() async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: dataAssignment.files_amount! > 1,
      allowedExtensions: dataAssignment.allow_file_type != null
          ? dataAssignment.allow_file_type?.split(',')
          : ['jpg', 'pdf', 'txt', 'zip', 'docx', 'doc', 'ppt'],
    );
    if (result != null) {
      for (var element in result.files) {
        var file = assignmentFiles
            .firstWhereOrNull((file) => file.name == element.name);
        if (file == null) {
          assignmentFiles.add(element);
        }
      }
      isAssignmentFileUpload = true;
      update();
    }
  }

  onActionDeleteFileAssignmentChoose(PlatformFile platformFile) {
    if (assignmentFiles != []) {
      for (int i = 0; i < assignmentFiles.length; i++) {
        if (assignmentFiles[i].name == platformFile.name) {
          assignmentFiles.removeAt(i);
        }
      }
    }
    if (assignmentFiles.isEmpty) {
      isAssignmentFileUpload = false;
    }
    update();
  }

  Future<void> onRetakeAssignment(id) async {
    try {
      final response = await parser.retakeAssignment(id);
      if (response.statusCode == 200) {
        getLesson();
      } else {
        // throw Exception('Failed to load courses');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> onStartAssignment(id) async {
    try {
      final response = await parser.startAssignment(id);

      if (response.statusCode == 200) {
        getLesson();
      } else {
        // throw Exception('Failed to load courses');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> onSaveOrSendAssignment(id, action) async {
    try {
      final context = Get.context;
      if (context == null) return;
      DialogHelper.showLoading();
      Map<String, dynamic> param = {};
      param['id'] = id;
      param['note'] = answerAssignment.text;
      param['action'] = action;

      if (assignmentFiles.isNotEmpty) {
        List<dynamic> files = [];

        for (var element in assignmentFiles) {
          files.add(element);
        }
        param['files'] = files;
      }

      final response = await parser.saveOrSendAssignment(param);
      if (response.statusCode == 200) {
        DialogHelper.hideLoading();
        Alert(
          context: context,
          title: tr(LocaleKeys.learningScreen_assignment_title),
          desc: action == 'save'
              ? tr(LocaleKeys.learningScreen_assignment_messageSaveAssignment)
              : tr(LocaleKeys.learningScreen_assignment_notificationSuccess),
          buttons: [
            DialogButton(
              child: Text(
                tr(LocaleKeys.learningScreen_finishCourseAlert_ok),
                style: const TextStyle(color: MedsKaiColors.white),
              ),
              onPressed: () => {Navigator.pop(context), getLesson()},
            ),
          ],
        ).show();
      } else {
        DialogHelper.hideLoading();
        final errorBody = response.body;
        final errorMessage = sanitizeToastMessage(errorBody is Map
            ? errorBody['message']?.toString() ?? tr(LocaleKeys.error)
            : tr(LocaleKeys.error));
        Alert(
                context: context,
                title: tr(LocaleKeys.learningScreen_assignment_title),
                desc: errorMessage)
            .show();
      }
    } catch (e) {
      DialogHelper.hideLoading();
      debugPrint('onSaveOrSendAssignment error: $e');
    }
  }

  Future<void> onDeleteFileAssignment(id, fileId) async {
    try {
      final response = await parser.deleteFileAssignment(id, fileId);
      if (response.statusCode == 200) {
        isAssignmentFileUpload = false;
        final context = Get.context;
        if (context == null) return;
        Alert(
          context: context,
          desc:
              tr(LocaleKeys.learningScreen_assignment_deleteFileSuccessMessage),
          buttons: [
            DialogButton(
              child: Text(
                tr(LocaleKeys.learningScreen_finishCourseAlert_ok),
                style: const TextStyle(color: MedsKaiColors.white),
              ),
              onPressed: () => {Navigator.pop(context), getLesson()},
            ),
          ],
        ).show();
      } else {
        // throw Exception('Failed to load courses');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  checkAnswer(itemQuestion) async {
    var item = listAnswer.firstWhereOrNull((x) => x['id'] == itemQuestion.id);

    if (item != null) {
      final response = await parser.checkAnswer(
          lesson!.id.toString(), item['id'].toString(), item['answered']);
      final checkBody = response.body;
      if (response.statusCode == 200 &&
          checkBody is Map &&
          checkBody['status'] == "success") {
        _answerDataCheck[itemQuestion.id.toString()] =
            AnswerDataCheck.fromJson(response.body);
      }
      update();
    } else {
      final context = Get.context;
      if (context == null) return;
      Alert(
        context: context,
        title: tr(LocaleKeys.learningScreen_quiz_checkAlert),
        buttons: [
          DialogButton(
            child: Text(
              tr(LocaleKeys.learningScreen_finishCourseAlert_ok),
              style: const TextStyle(color: MedsKaiColors.white),
            ),
            onPressed: () => {Navigator.pop(context)},
          ),
        ],
      ).show();
    }
  }

  onHandleSortingChoice(answered) {
    var index = listAnswer.indexWhere((x) =>
        x['id'].toString() == learningQuizStore.itemQuestion?.id.toString());
    if (index != -1) {
      listAnswer[index] = {
        "id": learningQuizStore.itemQuestion?.id,
        "answered": answered
      };
    } else {
      listAnswer.add(
          {"id": learningQuizStore.itemQuestion?.id, "answered": answered});
    }
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      if (!isLoadingMore) return;
    }
  }

  /// Parse quiz data from JSON (used for both online and offline)
  void _parseQuizData(dynamic body) {
    LearningLessonModel temp = LearningLessonModel.fromJson(body);
    _data = temp;
    isLesson = false;
    isQuiz = true;
    isAssignment = false;
    isStartQuiz = temp.results?.status == "started";
    pageActive = 0;
    if (temp.results != null) {
      _dataQuiz = QuizModel(
        questions: temp.questions,
        status: temp.results?.status,
        passing_grade: temp.results?.passing_grade,
        negative_marking: temp.results?.negative_marking,
        instant_check: temp.results?.instant_check,
        retake_count: temp.results?.retake_count,
        questions_per_page: temp.results?.questions_per_page,
        page_numbers: temp.results?.page_numbers,
        review_questions: temp.results?.review_questions,
        support_options: temp.results?.support_options,
        duration: temp.results?.duration,
        total_time: temp.results?.total_time,
      );
      learningQuizStore.setData(_dataQuiz);
      if (temp.questions != null && temp.questions!.isNotEmpty) {
        itemQuestion = temp.questions![0];
        learningQuizStore.setQuestion(itemQuestion);
      }
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    answerAssignment.dispose();
    for (var controller in listTextFieldQuiz.values) {
      controller.dispose();
    }
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isLoadingMore) return;
    }
  }

  handleCheckCurrentShowLesson(index) {
    isCheckCurrentShowLesson = true;
    indexCurrentShowLesson = index;
    update();
  }
}
