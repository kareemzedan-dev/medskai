import 'package:flutter_app/app/controller/wishlist_controller.dart';
import 'package:get/get.dart';

class WishlishBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => WishlistController(parser: Get.find()),
    );
  }
}
