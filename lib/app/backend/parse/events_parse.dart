import 'dart:convert';

import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/cache/api_cache_service.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class EventsParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;
  final ApiCacheService _cache = ApiCacheService();

  static const String _eventsListKey = 'events_list';
  static const String _homeEventsKey = 'home_upcoming_events';

  EventsParser({required this.apiService, required this.sharedPreferencesManager});

  Future<Response> getEvents({
    int page = 1,
    int perPage = 10,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && page == 1) {
      final cached = await _cache.get(_eventsListKey);
      if (cached != null) {
        final decoded = _cache.decodeCached(cached);
        if (decoded != null) return Response(body: decoded, statusCode: 200);
      }
    }

    var response = await apiService.getPublic(
      ApiEndpoints.events.list,
      {
        'page': '$page',
        'per_page': '$perPage',
        'start_date': 'now',
      },
    );

    if (response.statusCode == 200 && page == 1) {
      await _cache.set(_eventsListKey, jsonEncode(response.body));
    }

    return response;
  }

  Future<Response> getEventDetail(int id) async {
    var response = await apiService.getPublic(
      ApiEndpoints.events.detail(id),
      null,
    );
    return response;
  }

  Future<Response> getUpcomingEvents({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cache.get(_homeEventsKey);
      if (cached != null) {
        final decoded = _cache.decodeCached(cached);
        if (decoded != null) return Response(body: decoded, statusCode: 200);
      }
    }

    var response = await apiService.getPublic(
      ApiEndpoints.events.list,
      {
        'per_page': '5',
        'start_date': 'now',
      },
    );

    if (response.statusCode == 200) {
      await _cache.set(_homeEventsKey, jsonEncode(response.body));
    }

    return response;
  }

  Future<void> clearCache() async {
    await _cache.clear(_eventsListKey);
    await _cache.clear(_homeEventsKey);
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
