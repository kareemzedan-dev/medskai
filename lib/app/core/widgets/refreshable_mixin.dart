import 'package:get/get.dart';

/// Mixin for controllers that support pull-to-refresh
///
/// Usage:
/// ```dart
/// class MyController extends GetxController with RefreshableMixin {
///   @override
///   Future<void> onRefresh() async {
///     // Implement refresh logic
///     await loadData();
///   }
/// }
/// ```
mixin RefreshableMixin on GetxController {
  /// Whether the controller is currently refreshing
  final RxBool isRefreshing = false.obs;

  /// Error message if refresh failed
  final RxString refreshError = ''.obs;

  /// Last refresh timestamp
  DateTime? lastRefreshTime;

  /// Minimum time between refreshes (debounce)
  Duration get refreshDebounce => const Duration(seconds: 2);

  /// Perform refresh operation
  ///
  /// Returns true if refresh was successful
  Future<bool> refresh() async {
    // Debounce rapid refresh requests
    if (lastRefreshTime != null) {
      final timeSinceLastRefresh = DateTime.now().difference(lastRefreshTime!);
      if (timeSinceLastRefresh < refreshDebounce) {
        return false;
      }
    }

    // Prevent concurrent refreshes
    if (isRefreshing.value) return false;

    isRefreshing.value = true;
    refreshError.value = '';

    try {
      await onRefresh();
      lastRefreshTime = DateTime.now();
      return true;
    } catch (e) {
      refreshError.value = e.toString();
      return false;
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Override this method to implement refresh logic
  Future<void> onRefresh();

  /// Clear refresh error
  void clearRefreshError() {
    refreshError.value = '';
  }

  /// Check if should show refresh error
  bool get hasRefreshError => refreshError.value.isNotEmpty;
}

/// Extended mixin with pagination support
mixin PaginatedRefreshableMixin on GetxController {
  /// Whether the controller is currently refreshing
  final RxBool isRefreshing = false.obs;

  /// Whether the controller is loading more data
  final RxBool isLoadingMore = false.obs;

  /// Whether there are more pages to load
  final RxBool hasMorePages = true.obs;

  /// Current page number
  final RxInt currentPage = 1.obs;

  /// Items per page
  int get itemsPerPage => 10;

  /// Refresh (reload from first page)
  Future<void> refresh() async {
    if (isRefreshing.value) return;

    isRefreshing.value = true;
    currentPage.value = 1;
    hasMorePages.value = true;

    try {
      await onRefresh();
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Load next page
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMorePages.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    try {
      final hasMore = await onLoadMore();
      hasMorePages.value = hasMore;
    } catch (e) {
      // Revert page number on error
      currentPage.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Override to implement refresh logic
  Future<void> onRefresh();

  /// Override to implement load more logic
  /// Returns true if there are more pages
  Future<bool> onLoadMore();
}
