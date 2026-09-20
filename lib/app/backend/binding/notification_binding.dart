import 'package:flutter_app/app/controller/notification_controller.dart';
import 'package:get/get.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => NotificationController(parser: Get.find()),
    );
  }
}
