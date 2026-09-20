import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/backend/models/lesson-model.dart';
import 'package:flutter_app/app/backend/parse/course_detail_parse.dart';
import 'package:flutter_app/app/helper/dialog_helper.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/core/error/app_error.dart';
import 'package:flutter_app/app/core/error/error_handler.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CourseDetailController extends GetxController {
  final CourseDetailParser parser;
  final courseStore = locator<CourseStore>();
  String courseId = "";
  bool apiCalled = false;

  bool haveData = false;

  String title = '';
  bool isLoading = false;
  bool isInitialLoading = true;
  bool hasError = false;
  String errorMessage = '';
  AppError? appError;
  CourseModel _course = CourseModel();
  CourseModel get course => _course;
  bool isProcessingAction = false;
  CourseDetailController({required this.parser});
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  double rating = 5;
  dynamic review;
  String reviewMessage = "";
  int sectionId = 0;
  bool callAgainRoute = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args == null || args is! List || args.isEmpty || args[0] == null) {
      hasError = true;
      isInitialLoading = false;
      errorMessage = tr(LocaleKeys.errorMessages_loadCourseDetails);
      return;
    }
    courseId = args[0].toString();
    getData();
  }

  handleGetIndexLesson() {
    if (course.sections == null) return 0;
    ItemLesson? itemRedirect = ItemLesson();
    int i = 0;
    for (var item in course.sections!) {
      itemRedirect = item.items?.firstWhere(
        (x) => x.status != 'completed',
        orElse: () => ItemLesson(),
      );
      if (itemRedirect?.id != null) {
        break;
      }
      i++;
    }
    return i;
  }

  void onBack() {
    final context = Get.context;
    if (context == null) return;
    Navigator.of(context).pop(true);
  }

  void start() {
    try {
      if (_course.sections != null &&
          _course.sections!.isNotEmpty &&
          _course.sections![0].items != null &&
          _course.sections![0].items!.isNotEmpty) {
        ItemLesson? itemRedirect;
        for (var item in _course.sections!) {
          itemRedirect = item.items?.firstWhere(
            (x) => x.status != 'completed',
            orElse: () => ItemLesson(),
          );
          sectionId = item.id!;
          if (itemRedirect?.id != null) {
            break;
          }
        }
        onNavigateLearning(
            itemRedirect?.id != null
                ? itemRedirect
                : _course.sections![0].items![0],
            0);
      } else {
        showToast(tr(LocaleKeys.singleCourse_noLessons));
      }
    } catch (e) {
      debugPrint('start error: $e');
    }
  }

  void onNavigateLearning(item, index) {
    Get.toNamed(AppRouter.getLearningRoute(),
        arguments: [item, index, courseId, sectionId]);
  }

  Future<void> onStartContinue() async {
    if (isProcessingAction) return;
    isProcessingAction = true;
    update();
    try {
      if (_course.sections == null ||
          _course.sections!.isEmpty ||
          _course.sections![0].items == null) {
        return;
      }
      List<ItemLesson> incompleteItems = [];
      for (var section in _course.sections!) {
        if (section.items != null && section.items!.isNotEmpty) {
          var incomplete =
              section.items!.where((x) => x.status != 'completed').toList();
          incompleteItems.addAll(incomplete);
        }
      }

      if (incompleteItems.isEmpty &&
          (_course.sections![0].items?.isEmpty ?? true)) {
        return;
      }
      final item = incompleteItems.isNotEmpty
          ? incompleteItems[0]
          : _course.sections![0].items![0];
      onNavigateLearning(item, 0);
    } finally {
      isProcessingAction = false;
      update();
    }
  }

  Future<void> onStartCourse() async {
    if (isProcessingAction) return;
    isProcessingAction = true;
    update();
    try {
      final response = await parser.enroll(courseId);
      if (response.statusCode == 200) {
        start();
      } else {
        // throw Exception('Failed to load courses');
      }
    } catch (e) {
      debugPrint('$e');
    } finally {
      isLoading = false; // hide loading indicator
      isProcessingAction = false;
      update();
    }
  }

  Future<void> onRetake() async {
    try {
      DialogHelper.showLoading();
      final response = await parser.retake(courseId);
      DialogHelper.hideLoading();
      if (response.statusCode == 200) {
        getData();
        start();
      }
    } catch (e) {
      DialogHelper.hideLoading();
      debugPrint('onRetake error: $e');
    } finally {
      isLoading = false; // hide loading indicator
    }
  }

  Future<void> onEnroll() async {
    try {
      final context = Get.context;
      if (context == null) return;
      if (parser.getToken() == "") {
        Alert(
          context: context,
          title: tr(LocaleKeys.alert_notLoggedIn),
          desc: tr(LocaleKeys.alert_loggedIn),
          buttons: [
            DialogButton(
              color: MedsKaiColors.error,
              child: Text(
                tr(LocaleKeys.alert_cancel),
                style: TextStyle(
                  color: MedsKaiColors.white,
                ),
              ),
              onPressed: () => {Navigator.pop(context)},
            ),
            DialogButton(
              child: Text(
                tr(LocaleKeys.alert_btnLogin),
                style: TextStyle(
                  color: MedsKaiColors.white,
                ),
              ),
              onPressed: () => {
                Navigator.pop(context),
                Get.offAllNamed(AppRouter.getLoginRoute())
              },
            ),
          ],
        ).show();
      } else {
        isLoading = true;
        update();
        final response = await parser.enroll(courseId);
        if (response.statusCode == 200) {
          start();
        } else if (response.statusCode == 401) {
          // Token expired - ask user to login again
          Alert(
            context: context,
            title: tr(LocaleKeys.alert_notLoggedIn),
            desc: tr(LocaleKeys.alert_loggedIn),
            buttons: [
              DialogButton(
                color: MedsKaiColors.error,
                child: Text(tr(LocaleKeys.alert_cancel),
                    style: const TextStyle(color: MedsKaiColors.white)),
                onPressed: () => Navigator.pop(context),
              ),
              DialogButton(
                child: Text(tr(LocaleKeys.alert_btnLogin),
                    style: const TextStyle(color: MedsKaiColors.white)),
                onPressed: () {
                  Navigator.pop(context);
                  Get.offAllNamed(AppRouter.getLoginRoute());
                },
              ),
            ],
          ).show();
        } else {
          showToast(
              response.statusText ??
                  tr(LocaleKeys.errorMessages_loadCourseDetails),
              isError: true);
        }
      }
    } catch (e) {
      debugPrint('$e');
    } finally {
      isLoading = false; // hide loading indicator
    }
  }

  Future<void> refreshData() async {
    await getData();
  }

  // function to fetch courses from API
  void retryLoadData() {
    hasError = false;
    errorMessage = '';
    appError = null;
    isInitialLoading = true;
    update();
    getData();
  }

  Future<void> getData() async {
    isLoading = true;
    hasError = false;
    try {
      parser.setOverview(courseId);
      final response = await parser.getDetailCourse(courseId);
      debugPrint(
          'CourseDetail API: status=${response.statusCode}, statusText=${response.statusText}, bodyType=${response.body?.runtimeType}');
      if (response.statusCode == 200) {
        CourseModel courseTemp = CourseModel.fromJson(response.body);
        _course = courseTemp;
        courseStore.setDetail(courseTemp);
        getRating(3);
      } else if (response.statusCode == 1 || response.statusCode == -1) {
        // Actual network/connection error
        appError = AppError.network();
        hasError = true;
        errorMessage = appError!.title;
      } else if (response.statusCode == 401) {
        // Token expired - show message and redirect to login
        showToast(tr(LocaleKeys.errors_auth_sessionExpired), isError: true);
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(AppRouter.getLoginRoute());
        });
        return;
      } else {
        // API returned an error (404, 500, etc.)
        hasError = true;
        errorMessage = response.statusText ??
            tr(LocaleKeys.errorMessages_loadCourseDetails);
        appError = AppError(
          type: ErrorType.server,
          title: errorMessage,
          isRetryable: true,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      appError = ErrorHandler.fromException(e);
      hasError = true;
      errorMessage = appError!.title;
      debugPrint('getData error: $e');
    } finally {
      isLoading = false;
      isInitialLoading = false;
    }
    refresh();
    update();
  }

  Future<CourseModel> getDetailCourse(courseId) async {
    final response = await parser.getDetailCourse(courseId.toString());
    if (response.statusCode == 200) {
      update();
      refresh();
      return CourseModel.fromJson(response.body);
    }
    return CourseModel();
  }

  Future<void> onToggleWishlist(CourseModel item) async {
    final context = Get.context;
    if (context == null) return;
    if (parser.getToken() == "") {
      Alert(
        context: context,
        title: tr(LocaleKeys.alert_notLoggedIn),
        desc: tr(LocaleKeys.alert_loggedIn),
        buttons: [
          DialogButton(
            color: MedsKaiColors.error,
            child: Text(tr(LocaleKeys.alert_cancel),
                style: TextStyle(color: MedsKaiColors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          DialogButton(
            child: Text(tr(LocaleKeys.alert_btnLogin),
                style: TextStyle(color: MedsKaiColors.white)),
            onPressed: () {
              Navigator.pop(context);
              Get.offAllNamed(AppRouter.getLoginRoute());
            },
          ),
        ],
      ).show();
      return;
    }
    final WishlistStore wishlistStore = Get.find<WishlistStore>();
    final success = await wishlistStore.optimisticToggle(item);
    if (!success) {
      showToast(tr(LocaleKeys.errorMessages_loadWishlist), isError: true);
    }
    update();
  }

  Future<void> getRating(int? per_page) async {
    try {
      final response = await parser.getRating(courseId, per_page);
      if (response.statusCode == 200) {
        review = response.body?["data"];
        reviewMessage = response.body?["message"]?.toString() ?? '';
        update();
      } else {
        debugPrint('getRating: status=${response.statusCode}');
      }
    } catch (e) {
      debugPrint('getRating error: $e');
    }
  }

  Future<void> submitRating() async {
    final context = Get.context;
    if (context == null) return;
    try {
      if (titleController.text == "") {
        Alert(
          context: context,
          title: tr(LocaleKeys.singleCourse_review),
          desc: tr(LocaleKeys.singleCourse_reviewTitleEmpty),
          buttons: [
            DialogButton(
              child: Text(
                tr(LocaleKeys.alert_ok),
              ),
              onPressed: () => {Navigator.pop(context)},
            ),
          ],
        ).show();
        return;
      }
      if (contentController.text == "") {
        Alert(
          context: context,
          title: tr(LocaleKeys.singleCourse_review),
          desc: tr(LocaleKeys.singleCourse_reviewContentEmpty),
          buttons: [
            DialogButton(
              child: Text(
                tr(LocaleKeys.alert_ok),
              ),
              onPressed: () => {Navigator.pop(context)},
            ),
          ],
        ).show();
        return;
      }

      var param = {
        "id": courseId,
        "title": titleController.text,
        "rate": rating.toString(),
        "content": contentController.text,
      };
      context.loaderOverlay.show();
      final response = await parser.createRating(param);
      if (response.statusCode == 200) {
        getRating(3);
        titleController.text = "";
        contentController.text = "";
        showToast(response.body?["message"]?.toString() ?? '');
        refresh();
        update();
      } else {
        showToast(response.body?["message"]?.toString() ?? '', isError: true);
      }
    } catch (e) {
      debugPrint('$e');
    } finally {
      final overlayContext = Get.context;
      if (overlayContext != null && overlayContext.loaderOverlay.visible) {
        overlayContext.loaderOverlay.hide();
      }
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}
