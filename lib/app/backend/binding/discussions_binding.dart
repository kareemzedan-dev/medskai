import 'package:get/get.dart';
import '../../controller/discussions_controller.dart';

class DiscussionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DiscussionsController(parser: Get.find()), fenix: true);
  }
}
