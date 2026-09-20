import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => HomeController(parser: Get.find()),
      fenix: true
    );
  }
}
