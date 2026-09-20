import 'package:flutter_app/app/backend/models/learning-lesson-model.dart';
import 'package:mobx/mobx.dart';

part 'learning_quiz_store.g.dart';

class LearningQuizStore = _LearningQuizStore with _$LearningQuizStore;

abstract class _LearningQuizStore with Store {
  @observable
  QuizModel? dataQuiz;
  @observable
  QuestionModel? itemQuestion;
  @observable
  dynamic itemCheck;


  @action
  void setData(value) {
    dataQuiz = value;
  }

  @action
  void setQuestion(value) {
    itemQuestion = value;
  }

  @action
  void setItemCheckuestion(value) {
    itemCheck = value;
  }
}
