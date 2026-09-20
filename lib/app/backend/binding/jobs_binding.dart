import 'package:get/get.dart';
import '../../controller/jobs_controller.dart';

class JobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => JobsController(parser: Get.find()), fenix: true);
  }
}
