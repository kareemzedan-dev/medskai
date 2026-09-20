import 'package:get/get.dart';
import '../../controller/cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CartController(parser: Get.find()), fenix: true);
  }
}
