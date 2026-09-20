import 'package:flutter_app/app/controller/my_courses_controller.dart';
import 'package:get/get.dart';

class MyCoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => MyCoursesController(parser: Get.find()),
    );
  }
}
