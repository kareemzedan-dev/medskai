import 'package:get/get.dart';

import '../../controller/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
          () => PaymentController(parser: Get.find()),
    );
  }
}
