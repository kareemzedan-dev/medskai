import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/backend/models/response_v2.dart';
import 'package:flutter_app/app/env.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_app/app/core/security/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'wishlist_store.g.dart';

class WishlistStore = _WishlistStore with _$WishlistStore;

abstract class _WishlistStore with Store {
  ApiService apiService = ApiService(appBaseUrl: Environments.apiBaseURL);

  _WishlistStore();

  @observable
  ObservableList<CourseModel> data = ObservableList<CourseModel>.of([]);

  @observable
  ObservableSet<int> courseIdSet = ObservableSet<int>();

  String token = "";

  // Pagination state
  int _currentPage = 1;
  static const int _perPage = 20;

  @observable
  bool hasMore = true;

  @observable
  bool isLoadingMore = false;

  bool isInWishlist(int courseId) => courseIdSet.contains(courseId);

  void _rebuildIdSet() {
    courseIdSet.clear();
    courseIdSet.addAll(data.map((c) => c.id).whereType<int>());
  }

  @action
  Future<void> getWishlist() async {
    data.clear();
    _currentPage = 1;
    hasMore = true;
    await _fetchPage(_currentPage, clear: true);
  }

  @action
  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    _currentPage++;
    await _fetchPage(_currentPage, clear: false);
    isLoadingMore = false;
  }

  Future<void> _fetchPage(int page, {required bool clear}) async {
    try {
      String token = await getToken();
      if (token.isEmpty) {
        hasMore = false;
        return;
      }
      var body = {
        "page": "$page",
        "per_page": "$_perPage",
        "optimize": "true",
      };
      var response =
          await apiService.getPrivate(ApiEndpoints.wishlist.list, token, body);
      if (response.statusCode == 200 && response.body != null) {
        List<CourseModel> lstTemp = [];

        // Handle multiple response formats
        List? items;
        if (response.body is List) {
          items = response.body;
        } else if (response.body is Map) {
          final bodyMap = response.body as Map<String, dynamic>;
          final dynamic dataField = bodyMap['data'];
          if (dataField is List) {
            items = dataField;
          } else if (dataField is Map) {
            items = dataField['items'];
          }
          // Fallback: try items directly on body
          items ??= bodyMap['items'];
        }

        if (items is List) {
          for (var item in items) {
            try {
              lstTemp.add(CourseModel.fromJson(item));
            } catch (e) {
              debugPrint('wishlist parse item error: $e');
            }
          }
        }

        if (clear) data.clear();
        data.addAll(lstTemp);
        _rebuildIdSet();
        hasMore = lstTemp.length >= _perPage;
      } else {
        hasMore = false;
      }
    } catch (e) {
      debugPrint('_fetchPage wishlist error: $e');
      hasMore = false;
    }
  }

  @action
  void setWishlist(List<CourseModel> items) {
    data.clear();
    data.addAll(items);
    _rebuildIdSet();
  }

  /// Optimistic toggle: يحدّث القائمة فورًا ثم يبعت الـ request في الخلفية.
  /// لو الـ request فشل بيرجّع الحالة الأصلية ويرجع false.
  Future<bool> optimisticToggle(CourseModel item) async {
    final alreadyIn = data.any((e) => e.id == item.id);

    // تحديث فوري optimistic
    if (alreadyIn) {
      data.removeWhere((e) => e.id == item.id);
    } else {
      data.add(item);
    }
    _rebuildIdSet();

    // الـ request في الخلفية
    try {
      var param = {"id": item.id};
      String token = await getToken();
      if (token.isEmpty) {
        // No token — revert and signal failure
        _revert(alreadyIn, item);
        return false;
      }
      var response = await apiService.postPrivate(
          ApiEndpoints.wishlist.toggle, param, token);
      if (response.statusCode == 200) {
        return true;
      } else {
        _revert(alreadyIn, item);
        return false;
      }
    } catch (e) {
      debugPrint('optimisticToggle error: $e');
      _revert(alreadyIn, item);
      return false;
    }
  }

  void _revert(bool wasIn, CourseModel item) {
    if (wasIn) {
      if (!data.any((e) => e.id == item.id)) data.add(item);
    } else {
      data.removeWhere((e) => e.id == item.id);
    }
    _rebuildIdSet();
  }

  Future<String> getToken() async {
    // Read from secure storage first (token migrates there from SharedPrefs)
    try {
      final secureToken = await SecureStorage.instance.getToken();
      if (secureToken.isNotEmpty) return secureToken;
    } catch (_) {}
    // Fallback to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? "";
  }
}
