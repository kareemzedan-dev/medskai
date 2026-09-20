import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../backend/models/event_model.dart';
import '../backend/parse/events_parse.dart';

class EventsController extends GetxController implements GetxService {
  final EventsParser parser;

  EventsController({required this.parser});

  List<EventModel> _events = [];
  List<EventModel> get eventsList => _events;

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int _page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents({bool forceRefresh = false}) async {
    isLoading = _events.isEmpty;
    hasError = false;
    _page = 1;
    update();

    try {
      final response = await parser.getEvents(forceRefresh: forceRefresh);
      if (response.statusCode == 200) {
        _events = [];
        final body = response.body;
        final eventsList = body is Map ? (body['events'] ?? []) : body;
        if (eventsList is List) {
          for (var data in eventsList) {
            _events.add(EventModel.fromJson(data));
          }
        }
        hasMore = _events.length >= 10;
      } else {
        if (_events.isEmpty) {
          hasError = true;
          errorMessage = 'Failed to load events';
        }
      }
    } catch (e) {
      if (_events.isEmpty) {
        hasError = true;
        errorMessage = e.toString();
      }
      debugPrint('loadEvents error: $e');
    }

    isLoading = false;
    update();
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    update();

    try {
      _page++;
      final response = await parser.getEvents(page: _page);
      if (response.statusCode == 200) {
        final body = response.body;
        final eventsList = body is Map ? (body['events'] ?? []) : body;
        if (eventsList is List) {
          for (var data in eventsList) {
            _events.add(EventModel.fromJson(data));
          }
          hasMore = eventsList.length >= 10;
        } else {
          hasMore = false;
        }
      } else {
        hasMore = false;
      }
    } catch (e) {
      hasMore = false;
      debugPrint('loadMore events error: $e');
    }

    isLoadingMore = false;
    update();
  }

  Future<void> refresh() async {
    await parser.clearCache();
    await loadEvents(forceRefresh: true);
  }
}
