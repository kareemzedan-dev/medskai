import 'package:flutter_app/app/controller/finish_learning_controller.dart';
import 'package:flutter_app/app/controller/learning_controller.dart';
import 'package:get/get.dart';

class FinishLearningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => LearningController(
        parser: Get.find(),
        courseDetailParser: Get.find(),
      ),
    );
    Get.lazyPut(
      () => FinishLearningController(parser: Get.find()),
      fenix: true,
    );
  }
}
