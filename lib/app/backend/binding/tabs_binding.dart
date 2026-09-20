import 'package:flutter_app/app/controller/courses_controller.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/controller/my_courses_controller.dart';
import 'package:flutter_app/app/controller/my_profile_controller.dart';
import 'package:flutter_app/app/controller/profile_controller.dart';
import 'package:flutter_app/app/controller/wishlist_controller.dart';
import 'package:get/get.dart';

import '../../controller/tabs_controller.dart';

class TabsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TabControllerX(), permanent: true);
    Get.put(HomeController(parser: Get.find()), permanent: true);
    Get.put(CoursesController(parser: Get.find()), permanent: true);
    Get.put(WishlistController(parser: Get.find()), permanent: true);
    Get.put(MyCoursesController(parser: Get.find()), permanent: true);
    Get.put(MyProfileController(parser: Get.find()), permanent: true);
    Get.put(
      ProfileController(
        sessionStore: Get.find(),
        myProfileParser: Get.find(),
      ),
      permanent: true,
    );
  }
}
