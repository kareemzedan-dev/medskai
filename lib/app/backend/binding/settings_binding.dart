import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/controller/settings_controller.dart';
import 'package:get/get.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    final sessionStore = locator<SessionStore>();
    Get.lazyPut(
      () => SettingsController(sessionStore: sessionStore, parser: Get.find()),
      fenix: true,
    );
  }
}
