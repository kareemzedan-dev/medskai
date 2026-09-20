import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/backend/models/instructor-model.dart';
import 'package:flutter_app/app/backend/parse/instructor_detail_parse.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../l10n/locale_keys.g.dart';
import 'package:flutter_app/app/util/toast.dart';

class InstructorDetailController extends GetxController {
  final InstructorDetailParser parser;
  InstructorDetailController({required this.parser});

  final List<CourseModel> _courses = <CourseModel>[];
  List<CourseModel> get coursesList => _courses;

  late ScrollController scrollController;
  bool isLoading = false;
  bool isLoadingMore = true;
  bool isInitialLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int _page = 1;
  UserInstructorModel? _instructor;
  UserInstructorModel? get instructor => _instructor;

  final int _pageSize = 10;
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is List && args.isNotEmpty) {
      _instructor = args[0];
    } else {
      return;
    }
    getData();

    if(_instructor?.instructor_data == null){
      String? userId = _instructor?.id.toString();
      getInstructor(userId);
    }

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }
  getInstructor(userId) async {
    UserInstructorModel userInstructorModel = UserInstructorModel();
    try {
      final response = await parser.getInstructor(userId);

      if (response.statusCode == 200 && response.body is Map) {
        userInstructorModel = UserInstructorModel.fromJson(response.body);
        
        // PRESERVE the original avatar_url and name from LearnPress API!
        // WP REST API often returns default gravatars or missing avatars.
        if (_instructor?.avatar_url != null && _instructor!.avatar_url!.isNotEmpty) {
           userInstructorModel.avatar_url = _instructor!.avatar_url;
        }
        if (_instructor?.name != null && _instructor!.name!.isNotEmpty) {
           userInstructorModel.name = _instructor!.name;
        }
        
        _instructor = userInstructorModel;
        update();
        refresh();
      } else {
        hasError = true;
        errorMessage = response.statusText ?? tr(LocaleKeys.errorMessages_loadInstructor);
      }
    } catch (e) {
      debugPrint('getInstructor error: $e');
      hasError = true;
      errorMessage = tr(LocaleKeys.errorMessages_loadInstructor);
      update();
    }
    return userInstructorModel;
  }
  Future<void> refreshData() async {
    hasError = false;
    errorMessage = '';
    _page = 1;
    isLoadingMore = true;
    _courses.clear();
    await getData();
  }

  void retryLoadData() {
    hasError = false;
    errorMessage = '';
    isInitialLoading = true;
    update();
    if (_instructor?.instructor_data == null) {
      String? userId = _instructor?.id.toString();
      getInstructor(userId);
    }
    getData();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore) return;
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    _page = _page + 1;
    getData();
  }

  // function to fetch courses from API
  Future<void> getData() async {
    if (!isLoading) {
      isLoading = true;
      var body = {
        "page": _page.toString(),
        "per_page": _pageSize.toString(),
        "optimize": "true",
        "user": _instructor?.id.toString(),
      };

      try {
        final response = await parser.getCourse(body);
        if (response.statusCode == 200 && response.body is List) {
          // String temp = jsonEncode(response.body);
          // dynamic data = jsonDecode(temp);
          // ResponseV2 resV2 = ResponseV2.fromJson(data);
          List<CourseModel> lstTemp = [];
          response.body.forEach((item) {
            CourseModel course = CourseModel.fromJson(item);
            lstTemp.add(course);
          });
          if (lstTemp.length < _pageSize) {
            isLoadingMore = false;
          }
          _courses.addAll(lstTemp);
        } else if (response.statusCode == 401) {
          showToast(tr(LocaleKeys.errors_auth_sessionExpired), isError: true);
          Get.offAllNamed(AppRouter.getLoginRoute());
          return;
        } else {
          hasError = true;
          errorMessage = response.statusText ?? tr(LocaleKeys.errorMessages_loadInstructor);
        }
      } catch (e) {
        debugPrint('getInstructorCourses error: $e');
        hasError = true;
        errorMessage = tr(LocaleKeys.errorMessages_loadInstructor);
      } finally {
        isLoading = false; // hide loading indicator
        isInitialLoading = false; // initial load complete
      }
      refresh();
      update();
    }
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
}
