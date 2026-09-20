import 'package:get/get.dart';
import '../../controller/community_controller.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommunityController(parser: Get.find()), fenix: true);
  }
}
