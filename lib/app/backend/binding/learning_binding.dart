import 'package:flutter_app/app/controller/learning_controller.dart';
import 'package:get/get.dart';

class LearningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => LearningController(parser: Get.find(), courseDetailParser: Get.find()),
    );
  }
}
