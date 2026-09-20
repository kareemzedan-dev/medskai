import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/backend/parse/wishlist_parse.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/locale_keys.g.dart';
import '../helper/router.dart';
import '../util/theme.dart';
import '../util/toast.dart';

class WishlistController extends GetxController implements GetxService {
  final WishlistParser parser;

  final List<CourseModel> _courses = <CourseModel>[];
  List<CourseModel> get coursesList => _courses;

  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  bool isInitialLoading = true;
  bool hasError = false;
  String errorMessage = '';
  final WishlistStore wishlistStore = Get.find<WishlistStore>();
  WishlistController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  Future<void> refreshData() async {
    hasError = false;
    errorMessage = '';

    // Show what we have immediately from the store
    _courses.clear();
    _courses.addAll(wishlistStore.data);
    isInitialLoading = false;
    update();

    // Then fetch fresh data from API in background
    try {
      await wishlistStore.getWishlist();
      _courses.clear();
      _courses.addAll(wishlistStore.data);
    } catch (e) {
      debugPrint('refreshData wishlist error: $e');
      // Keep showing whatever we already have — don't clear
    }
    update();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // Sync courses list from the MobX store, then refresh from API
  Future<void> getData() async {
    try {
      // Show what we have immediately
      _courses.clear();
      _courses.addAll(wishlistStore.data);
      isInitialLoading = _courses.isEmpty;
      update();

      // Fetch fresh data from API
      await wishlistStore.getWishlist();
      _courses.clear();
      _courses.addAll(wishlistStore.data);
    } catch (e) {
      debugPrint('getData wishlist error: $e');
    }
    isLoading = false;
    isInitialLoading = false;
    hasError = false;
    update();
  }

  /// Called when the wishlist tab becomes visible — sync from store
  void syncFromStore() {
    _courses.clear();
    _courses.addAll(wishlistStore.data);
    update();
  }

  void retryLoadData() {
    hasError = false;
    errorMessage = '';
    isInitialLoading = true;
    update();
    getData();
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
            child: Text(
              tr(LocaleKeys.alert_cancel),
              style: TextStyle(color: MedsKaiColors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          DialogButton(
            child: Text(
              tr(LocaleKeys.alert_btnLogin),
              style: TextStyle(color: MedsKaiColors.white),
            ),
            onPressed: () {
              Navigator.pop(context);
              Get.offAllNamed(AppRouter.getLoginRoute());
            },
          ),
        ],
      ).show();
      return;
    }

    // ── Optimistic Update ──────────────────────────────────────────────
    final alreadyIn = _courses.any((e) => e.id == item.id);

    // 1) تحديث _courses فورًا
    if (alreadyIn) {
      _courses.removeWhere((e) => e.id == item.id);
    } else {
      _courses.add(item);
    }
    update(); // إعادة رسم الـ UI لحظيًا

    // 2) إرسال الـ request في الخلفية عبر wishlistStore
    final success = await wishlistStore.optimisticToggle(item);

    if (!success) {
      // 3) Revert لو فشل
      if (alreadyIn) {
        _courses.add(item);
      } else {
        _courses.removeWhere((e) => e.id == item.id);
      }
      showToast(tr(LocaleKeys.errorMessages_loadWishlist), isError: true);
      update();
    }
  }

  Future<void> launchInBrowser(String link) async {
    try {
      final url = Uri.parse(link);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('launchInBrowser error: $e');
    }
  }
}
