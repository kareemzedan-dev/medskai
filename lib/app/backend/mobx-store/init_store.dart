import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/learning_quiz_store.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<CourseStore>(CourseStore());
  locator.registerSingleton<LearningQuizStore>(LearningQuizStore());
  locator.registerSingleton<SessionStore>(SessionStore());
  // locator.registerSingleton<WishlistStore>(WishlistStore());
}

