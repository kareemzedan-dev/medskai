import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/parse/search_course_parse.dart';
import 'package:flutter_app/app/controller/courses_controller.dart';
import 'package:flutter_app/app/controller/tabs_controller.dart';
import 'package:get/get.dart';

class SearchCourseController extends GetxController {
  final SearchCourseParser parser;

  TextEditingController keywordController = TextEditingController();

  SearchCourseController({required this.parser});
  CoursesController? courseController;
  List<String> listRecentSearch = [];
  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<CoursesController>()) {
      courseController = Get.find<CoursesController>();
    }
    final args = Get.arguments;
    if (args != null && args is List && args.isNotEmpty) {
      keywordController.text = args[0]?.toString() ?? "";
    }
    getRecentSearch();
  }

  @override
  void onClose() {
    keywordController.dispose();
    super.onClose();
  }

  Future<void> onSearch(String? value) async {
    final searchText = value ?? keywordController.text;
    if (searchText.isEmpty) return;

    final courses = courseController ??
        (Get.isRegistered<CoursesController>()
            ? Get.find<CoursesController>()
            : null);
    if (courses == null || !Get.isRegistered<TabControllerX>()) {
      return;
    }
    courses.setKeywordSearch(searchText);
    if (value == null) {
      parser.saveRecentSearch(keywordController.text);
    }

    // Go back and navigate to courses tab to show results
    Get.back();
    Get.find<TabControllerX>().goToCourses();
  }

  void onBack() {
    Get.back();
  }

  Future<void> getRecentSearch() async {
    listRecentSearch = parser.getRecentSearch();
    update();
  }
}
