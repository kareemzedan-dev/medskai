import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/backend/parse/review_parse.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_app/app/util/toast.dart';
// import 'package:flutter_app/app/helper/router.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ReviewController extends GetxController {
  final ReviewParser parser;
  ReviewController({required this.parser});

  final List<dynamic> reviews = <dynamic>[];
  List<dynamic> get reviewList => reviews;

  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  bool isLoadingMore = true;
  bool isInitialLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int _page = 1;
  String courseId = "";

  final int _pageSize = 15;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args == null || args is! List || args.isEmpty || args[0] == null) {
      hasError = true;
      isInitialLoading = false;
      errorMessage = tr(LocaleKeys.errorMessages_loadReviews);
      update();
      return;
    }
    courseId = args[0].toString();
    getData();
    scrollController.addListener(_onScroll);
  }

  Future<void> refreshData() async {
    _page = 1;
    isLoadingMore = true;
    reviews.clear();
    hasError = false;
    errorMessage = '';
    await getData();
  }

  void retryLoadData() {
    hasError = false;
    errorMessage = '';
    isInitialLoading = true;
    update();
    getData();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
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
      };

      try {
        final response = await parser.getReview(courseId, body);
        if (response.statusCode == 200 && response.body is Map) {
          List<dynamic> lstTemp = [];
          if (response.body["status"] == "success") {
            (response.body["data"]?["reviews"]?["reviews"] as List?)
                ?.forEach((item) {
              lstTemp.add(item);
            });
            if (lstTemp.length < _pageSize) {
              isLoadingMore = false;
            }
            reviews.addAll(lstTemp);
          }
        } else if (response.statusCode == 401) {
          showToast(tr(LocaleKeys.errors_auth_sessionExpired), isError: true);
          Get.offAllNamed(AppRouter.getLoginRoute());
          return;
        } else {
          hasError = true;
          errorMessage =
              response.statusText ?? tr(LocaleKeys.errorMessages_loadReviews);
        }
      } catch (e) {
        hasError = true;
        errorMessage = tr(LocaleKeys.errorMessages_loadReviews);
        debugPrint('getReview error: $e');
      } finally {
        isLoading = false;
        isInitialLoading = false;
      }
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
