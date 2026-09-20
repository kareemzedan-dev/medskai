
import 'package:flutter_app/app/backend/parse/finish-learning_parse.dart';
import 'package:get/get.dart';

class FinishLearningController extends GetxController implements GetxService {
  final FinishLearningParser parser;
  int retakeCount = 0;
  int id = 0;
  FinishLearningController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is List && args.length > 2) {
      retakeCount = args[1] ?? 0;
      id = args[2] ?? 0;
    }
  }
}
