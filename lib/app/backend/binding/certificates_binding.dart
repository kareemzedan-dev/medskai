import 'package:get/get.dart';

import '../../controller/certificates_controller.dart';
import '../api/api.dart';
import '../../helper/shared_pref.dart';
import '../parse/certificates_parse.dart';

class CertificatesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => CertificatesController(
        parser: CertificatesParser(
          apiService: Get.find<ApiService>(),
          sharedPreferencesManager: Get.find<SharedPreferencesManager>(),
        ),
      ),
    );
  }
}
