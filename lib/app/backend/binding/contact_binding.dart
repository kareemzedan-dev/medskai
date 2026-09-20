import 'package:get/get.dart';
import '../../controller/contact_controller.dart';

class ContactBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ContactController(parser: Get.find()), fenix: true);
  }
}
