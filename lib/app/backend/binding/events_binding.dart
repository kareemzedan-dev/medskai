import 'package:get/get.dart';
import '../../controller/events_controller.dart';

class EventsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EventsController(parser: Get.find()), fenix: true);
  }
}
