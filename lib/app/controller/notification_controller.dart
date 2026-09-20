import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_app/app/backend/models/notification_model.dart';
import 'package:flutter_app/app/backend/parse/notification_parse.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:get/get.dart';

import '../helper/dialog_helper.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationParser parser;
  List<NotificationModel> _notification = <NotificationModel>[];

  List<NotificationModel> get notificationList => _notification;
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  bool isLoadingMore = true;
  bool isInitialLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int _page = 1;
  final int _pageSize = 10;
  NotificationController({required this.parser}) {}

  @override
  void onInit() {
    super.onInit();
    _initData();
    scrollController.addListener(_onScroll);
  }

  Future<void> _initData() async {
    await refreshData();
  }

  checkUpdateNotification(homeController) {
    if (homeController.isNewNotification) {
      homeController.updateShowNotification(false);
    }
  }

  Future<void> refreshData() async {
    _page = 1;
    hasError = false;
    errorMessage = '';
    isLoadingMore = true;
    _notification.clear();
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
    await getData();
  }

  // function to fetch notifications from API
  Future<void> getData() async {
    // Don't attempt to load if user is not logged in
    if (parser.getToken() == '') {
      isLoading = false;
      isInitialLoading = false;
      update();
      return;
    }

    if (!isLoading) {
      isLoading = true;

      try {
        final response = await parser.getNotification(body: {
          "page": _page.toString(),
          "per_page": _pageSize.toString(),
        });
        if (response.statusCode == 200) {
          List<NotificationModel> lstTemp = [];

          (response.body?["data"]?["notifications"] as List?)?.forEach((item) {
            NotificationModel temp = NotificationModel.fromJson(item);
            lstTemp.add(temp);
          });
          if (lstTemp.length < _pageSize) {
            isLoadingMore = false;
          }
          _notification.addAll(lstTemp);
          update();
          refresh();
        } else if (response.statusCode == 401) {
          showToast(tr(LocaleKeys.errors_auth_sessionExpired), isError: true);
          Get.offAllNamed(AppRouter.getLoginRoute());
          return;
        } else {
          if (parser.getToken() != "") {
            hasError = true;
            errorMessage = response.statusText ??
                tr(LocaleKeys.errorMessages_loadNotifications);
          }
        }
      } catch (e) {
        hasError = true;
        errorMessage = tr(LocaleKeys.errorMessages_loadNotifications);
        debugPrint('getNotifications error: $e');
      } finally {
        isLoading = false; // hide loading indicator
        isInitialLoading = false; // initial load complete
        update();
        refresh();
      }
    }
  }

  Future<void> registerFCMToken(String fcmToken) async {
    try {
      final response = await parser.registerFCMToken(fcmToken,
          defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');
      if (response.statusCode == 200) {
        debugPrint('Success register FCMToken $fcmToken');
      } else {
        debugPrint(
            'Failed to register FCMToken: ${response.statusCode} - ${response.statusText}');
        throw Exception('Failed to register FCMToken');
      }
    } catch (e) {
      debugPrint('Error in registerFCMToken: $e');
    }
  }

  Future<void> deleteFCMToken(String fcmToken) async {
    try {
      final response = await parser.deleteFCMToken(fcmToken);
      if (response.statusCode == 200) {
        debugPrint('Success delete FCMToken $fcmToken');
      } else {
        throw Exception('Failed to delete FCMToken');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }
}
