import 'dart:convert';

import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/backend/models/event_model.dart';
import 'package:flutter_app/app/backend/models/testimonial_model.dart';
import 'package:flutter_app/app/backend/models/user_info_model.dart';
import 'package:flutter_app/app/core/cache/api_cache_service.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/core/network/request_deduplicator.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class HomeParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;
  final ApiCacheService _cache = ApiCacheService();

  // Cache keys for home endpoints
  static const String _topCoursesKey = 'home_top_courses';
  static const String _newCoursesKey = 'home_new_courses';
  static const String _categoriesKey = 'home_categories';
  static const String _instructorsKey = 'home_instructors';
  static const String _overviewKey = 'home_overview';
  static const String _latestPostsKey = 'home_latest_posts';
  static const String _upcomingEventsKey = 'home_upcoming_events';
  static const String _blogCategoriesKey = 'home_blog_categories';

  static const List<String> allCacheKeys = [
    _topCoursesKey,
    _newCoursesKey,
    _categoriesKey,
    _instructorsKey,
    _overviewKey,
    _latestPostsKey,
    _upcomingEventsKey,
    _blogCategoriesKey,
  ];

  HomeParser(
      {required this.apiService, required this.sharedPreferencesManager});

  /// Check if all home data caches are fresh
  bool isAllDataFresh() {
    return allCacheKeys.every((key) => _cache.isFresh(key));
  }

  /// Clear all home caches (for pull-to-refresh)
  Future<void> clearAllCaches() async {
    for (final key in allCacheKeys) {
      await _cache.clear(key);
    }
  }

  Future<Response> getTopCourses({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cache.get(_topCoursesKey);
      if (cached != null) {
        final decoded = _cache.decodeCached(cached);
        if (decoded != null) return Response(body: decoded, statusCode: 200);
      }
    }
    var response = await apiService.getPublic(
        ApiEndpoints.courses.list, {"popular": "true", "per_page": "50"});
    if (response.statusCode == 200) {
      await _cache.set(_topCoursesKey, jsonEncode(response.body));
    }
    return response;
  }

  Future<Response> getNewCourses({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cache.get(_newCoursesKey);
      if (cached != null) {
        final decoded = _cache.decodeCached(cached);
        if (decoded != null) return Response(body: decoded, statusCode: 200);
      }
    }
    var response = await apiService.getPublic(
        ApiEndpoints.courses.list, {"order": "desc", "per_page": "50"});
    if (response.statusCode == 200) {
      await _cache.set(_newCoursesKey, jsonEncode(response.body));
    }
    return response;
  }

  Future<Response> getIntructor({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cache.get(_instructorsKey);
      if (cached != null) {
        final decoded = _cache.decodeCached(cached);
        if (decoded != null) return Response(body: decoded, statusCode: 200);
      }
    }
    var param = {
      "roles": 'lp_teacher',
      "per_page": '100',
    };
    var response = await apiService.getPublic(ApiEndpoints.user.list, param);
    if (response.statusCode == 200) {
      await _cache.set(_instructorsKey, jsonEncode(response.body));
    }
    return response;
  }

  Future<Response> getCategoryHome({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cache.get(_categoriesKey);
      if (cached != null) {
        final decoded = _cache.decodeCached(cached);
        if (decoded != null) return Response(body: decoded, statusCode: 200);
      }
    }
    var response = await apiService.getPublic(
        ApiEndpoints.categories.list, {"orderby": "count", "order": "desc"});
    if (response.statusCode == 200) {
      await _cache.set(_categoriesKey, jsonEncode(response.body));
    }
    return response;
  }

  Future<Response> getLatestPosts({int page = 1, int perPage = 10, bool forceRefresh = false}) async {
    if (!forceRefresh && page == 1) {
      final cached = await _cache.get(_latestPostsKey);
      if (cached != null) {
        final decoded = _cache.decodeCached(cached);
        if (decoded != null) return Response(body: decoded, statusCode: 200);
      }
    }
    var response = await apiService.getPublic(
        ApiEndpoints.blog.list, {"per_page": "$perPage", "page": "$page", "_embed": "true", "orderby": "date", "order": "desc"});
    if (response.statusCode == 200 && page == 1) {
      await _cache.set(_latestPostsKey, jsonEncode(response.body));
    }
    return response;
  }

  Future<Response> getUpcomingEvents({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cache.get(_upcomingEventsKey);
      if (cached != null) {
        final decoded = _cache.decodeCached(cached);
        if (decoded != null) return Response(body: decoded, statusCode: 200);
      }
    }
    var response = await apiService.getPublic(
        ApiEndpoints.events.list, {"per_page": "5", "start_date": "now"});
    if (response.statusCode == 200) {
      await _cache.set(_upcomingEventsKey, jsonEncode(response.body));
    }
    return response;
  }

  Future<Response> getBlogCategories({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cache.get(_blogCategoriesKey);
      if (cached != null) {
        final decoded = _cache.decodeCached(cached);
        if (decoded != null) return Response(body: decoded, statusCode: 200);
      }
    }
    var response = await apiService.getPublic(
        ApiEndpoints.blogCategories.list, null);
    if (response.statusCode == 200) {
      await _cache.set(_blogCategoriesKey, jsonEncode(response.body));
    }
    return response;
  }

  Future<Response> getOverview({bool forceRefresh = false}) async {
    String token = getToken();
    String overviewId = getOverviewId();
    if (overviewId == "") {
      return const Response(statusCode: 500);
    }
    if (!forceRefresh) {
      final cached = await _cache.get(_overviewKey);
      if (cached != null) {
        final decoded = _cache.decodeCached(cached);
        if (decoded != null) return Response(body: decoded, statusCode: 200);
      }
    }
    var response = await apiService.getPrivate(
        ApiEndpoints.courses.detail(int.parse(overviewId)), token, null);
    if (response.statusCode == 200) {
      await _cache.set(_overviewKey, jsonEncode(response.body));
    }
    return response;
  }

  /// Get cached data regardless of TTL (for offline use)
  Future<dynamic> getCachedData(String cacheKey) async {
    final cached = await _cache.getIgnoringTtl(cacheKey);
    return _cache.decodeCached(cached);
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }

  String getAvatar() {
    return sharedPreferencesManager.getString('avatar') ?? "";
  }

  UserInfoModel getUserInfo() {
    String temp = sharedPreferencesManager.getString('user_info') ?? "";

    UserInfoModel json = UserInfoModel();
    if (temp != "")
      json = UserInfoModel.fromJson(jsonDecode(temp) as Map<String, dynamic>);
    return json;
  }

  Future<Response> getUser(String id) async {
    String token = getToken();
    if (token.isNotEmpty) {
      var response = await apiService.getPrivate(
          ApiEndpoints.user.detail(int.parse(id)), token, null);
      return response;
    } else {
      return Response(statusCode: 400);
    }
  }

  String getOverviewId() {
    return sharedPreferencesManager.getString('overview') ?? "";
  }

  setOverviewId(value) {
    return sharedPreferencesManager.putString('overview', value);
  }
}
