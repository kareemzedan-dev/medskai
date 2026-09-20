import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/cate-model.dart';
import 'package:flutter_app/app/backend/models/blog_post_model.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/backend/models/event_model.dart';
import 'package:flutter_app/app/backend/models/testimonial_model.dart';
import 'package:flutter_app/app/backend/models/instructor-model.dart';
import 'package:flutter_app/app/backend/parse/home_parse.dart';
import 'package:flutter_app/app/core/services/connectivity_service.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/core/error/app_error.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/locale_keys.g.dart';
import '../backend/parse/profile_parse.dart';

class HomeController extends GetxController implements GetxService {
  final HomeParser parser;
  List<CourseModel> _topCourses = <CourseModel>[];
  List<CourseModel> get topCoursesList => _topCourses;
  List<CategoryModel> _categoriesList = <CategoryModel>[];

  List<CategoryModel> get cateHomeList => _categoriesList;
  List<CourseModel> _newCourseList = <CourseModel>[];

  List<CourseModel> get newCourseList => _newCourseList;
  List<UserInstructorModel> _instructor = <UserInstructorModel>[];

  List<UserInstructorModel> get instructorList => _instructor;
  List<BlogPostModel> _latestPosts = <BlogPostModel>[];

  List<BlogPostModel> get latestPosts => _latestPosts;
  dynamic _overview;

  dynamic get overview => _overview;
  String token = '';

  // Loading states for skeleton
  bool isLoadingCategories = true;
  bool isLoadingTopCourses = true;
  bool isLoadingNewCourses = true;
  bool isLoadingInstructors = true;
  bool isLoadingOverview = true;
  bool isLoadingPosts = true;

  List<EventModel> _upcomingEvents = <EventModel>[];
  List<EventModel> get upcomingEvents => _upcomingEvents;
  bool isLoadingEvents = true;

  List<TestimonialModel> _testimonials = <TestimonialModel>[];
  List<TestimonialModel> get testimonials => _testimonials;
  PlatformStatsModel _platformStats = PlatformStatsModel(
    studentsEnrolled: 50,
    classesCompleted: 30,
    satisfactionRate: 90,
    topInstructors: 10,
  );
  PlatformStatsModel get platformStats => _platformStats;

  List<Map<String, dynamic>> _blogCategories = [];
  List<Map<String, dynamic>> get blogCategories => _blogCategories;
  int? selectedBlogCategory;

  final sessionStore = locator<SessionStore>();

  final WishlistStore wishlistStore = Get.find<WishlistStore>();

  String title = '';

  /// Single source of truth — delegates to SessionStore
  bool get isLoggedIn => sessionStore.isLoggedIn;

  bool isNewNotification = false;
  bool hasError = false;
  AppError? appError;
  bool _initialLoadDone = false;
  bool isOffline = false;
  bool _isRefreshing = false;

  ConnectivityService? _connectivity;
  StreamSubscription? _connectivitySub;

  HomeController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    token = parser.getToken();

    // Setup connectivity monitoring
    try {
      _connectivity = Get.find<ConnectivityService>();
      isOffline = !_connectivity!.isOnline.value;
      _connectivitySub = _connectivity!.isOnline.listen((online) {
        isOffline = !online;
        update();
        if (online && _initialLoadDone) {
          refreshAllData();
        }
      });
    } catch (_) {
      // ConnectivityService not registered, proceed without offline support
    }

    _initialLoad();
  }

  Future<void> _initialLoad() async {
    // Only fetch wishlist and check user if logged in
    if (token.isNotEmpty) {
      try {
        wishlistStore.getWishlist();
      } catch (_) {}
      final userId = parser.getUserInfo().id;
      if (userId != null) {
        handleCheckoutUser(userId.toString());
      }
    }
    // Clear stale cache, then load fresh data
    await parser.clearAllCaches();
    await _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    token = parser.getToken();
    hasError = false;
    appError = null;
    update();

    // Fire all requests in parallel — each updates its own section
    await Future.wait([
      _loadSection(
          'categories',
          (r) {
            final list = _extractList(r.body);
            if (list != null)
              _categoriesList =
                  list.map((d) => CategoryModel.fromJson(d)).toList();
          },
          () => parser.getCategoryHome(forceRefresh: true),
          (v) {
            isLoadingCategories = v;
          }),
      _loadSection(
          'topCourses',
          (r) {
            final list = _extractList(r.body);
            if (list != null)
              _topCourses = list.map((d) => CourseModel.fromJson(d)).toList();
          },
          () => parser.getTopCourses(forceRefresh: true),
          (v) {
            isLoadingTopCourses = v;
          }),
      _loadSection(
          'newCourses',
          (r) {
            final list = _extractList(r.body);
            if (list != null)
              _newCourseList =
                  list.map((d) => CourseModel.fromJson(d)).toList();
          },
          () => parser.getNewCourses(forceRefresh: true),
          (v) {
            isLoadingNewCourses = v;
          }),
      _loadSection(
          'instructors',
          (r) {
            final list = _extractList(r.body);
            if (list != null) {
              _instructor = [];
              for (var data in list) {
                UserInstructorModel m = UserInstructorModel.fromJson(data);
                final name = m.name?.toLowerCase() ?? '';
                final totalCourses = int.tryParse((m.instructor_data is Map
                            ? m.instructor_data["total_courses"]?.toString()
                            : null) ??
                        '0') ??
                    0;
                if (name != 'system' && name != 'testapi') {
                  _instructor.add(m);
                }
              }
            }
          },
          () => parser.getIntructor(forceRefresh: true),
          (v) {
            isLoadingInstructors = v;
          }),
      _loadSection('overview', (r) {
        _overview = r.body;
      }, () async {
        if (token.isEmpty) return const Response(statusCode: 204);
        return parser.getOverview(forceRefresh: true);
      }, (v) {
        isLoadingOverview = v;
      }),
      _loadSection(
          'latestPosts',
          (r) {
            final list = _extractList(r.body);
            if (list != null) {
              _latestPosts =
                  list.map((d) => BlogPostModel.fromJson(d)).toList();
              hasMorePosts = list.length >= 10;
            }
          },
          () => parser.getLatestPosts(forceRefresh: true),
          (v) {
            isLoadingPosts = v;
          }),
      _loadSection(
          'events',
          (r) {
            final body = r.body;
            final eventsList = body is Map ? (body['events'] ?? []) : body;
            if (eventsList is List) {
              _upcomingEvents =
                  eventsList.map((d) => EventModel.fromJson(d)).toList();
            }
          },
          () => parser.getUpcomingEvents(forceRefresh: true),
          (v) {
            isLoadingEvents = v;
          }),
    ]);

    _initialLoadDone = true;
    _isRefreshing = false;
    update();
  }

  /// Load a section: fetch API, parse data, always set loading=false.
  Future<void> _loadSection(
    String id,
    void Function(Response r) parseData,
    Future<Response> Function() fetcher,
    void Function(bool) setLoading,
  ) async {
    setLoading(true);
    update([id]);
    try {
      final response = await fetcher();
      if (response.statusCode == 200) {
        try {
          parseData(response);
        } catch (parseError) {
          debugPrint('Home parse error [$id]: $parseError');
        }
      }
    } catch (e) {
      debugPrint('Home fetch error [$id]: $e');
    } finally {
      // ALWAYS stop loading, even if parsing failed
      setLoading(false);
      update([id]);
    }
  }

  updateShowNotification(status) {
    isNewNotification = status == 'true' ? true : false;
    update();
  }

  void refreshScreen() {
    update();
  }

  /// Force refresh — clears cache then re-fetches all.
  /// Debounced: ignores concurrent calls while one is in progress.
  /// Force refresh — clears cache then re-fetches all.
  /// Debounced: ignores concurrent calls while one is in progress.
  Future<void> refreshAllData() async {
    await parser.clearAllCaches();
    await _loadAllData();
  }

  /// Extract a List from an API response body (handles both List and Map).
  List? _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      final result = body['data'] ?? body['items'] ?? body['results'];
      if (result is List) return result;
      debugPrint(
          '_extractList: Map keys: ${body.keys.toList()}, no list found');
    }
    return null;
  }

  /// Private fetch — mutates state without calling update().
  Future<void> _fetchTopCourses({bool forceRefresh = false}) async {
    if (_topCourses.isNotEmpty && !forceRefresh) {
      isLoadingTopCourses = false;
      return;
    }
    isLoadingTopCourses = true;
    try {
      Response response =
          await parser.getTopCourses(forceRefresh: forceRefresh);
      if (response.statusCode == 200) {
        final list = _extractList(response.body);
        if (list != null) {
          _topCourses = list.map((data) => CourseModel.fromJson(data)).toList();
        }
      }
    } catch (e) {
      debugPrint('getTopCourses error: $e');
    }
    isLoadingTopCourses = false;
  }

  /// Public — fetches then triggers a single rebuild.
  Future<void> getTopCourses({bool forceRefresh = false}) async {
    isLoadingTopCourses = _topCourses.isEmpty || forceRefresh;
    update(['topCourses']);
    await _fetchTopCourses(forceRefresh: forceRefresh);
    update(['topCourses']);
  }

  Future<void> _fetchNewCourses({bool forceRefresh = false}) async {
    if (_newCourseList.isNotEmpty && !forceRefresh) {
      isLoadingNewCourses = false;
      return;
    }
    isLoadingNewCourses = true;
    try {
      Response response =
          await parser.getNewCourses(forceRefresh: forceRefresh);
      if (response.statusCode == 200) {
        final list = _extractList(response.body);
        if (list != null) {
          _newCourseList =
              list.map((data) => CourseModel.fromJson(data)).toList();
        }
      }
    } catch (e) {
      debugPrint('getNewCourses error: $e');
    }
    isLoadingNewCourses = false;
  }

  Future<void> getNewCourses({bool forceRefresh = false}) async {
    isLoadingNewCourses = _newCourseList.isEmpty || forceRefresh;
    update(['newCourses']);
    await _fetchNewCourses(forceRefresh: forceRefresh);
    update(['newCourses']);
  }

  Future<void> _fetchInstructor({bool forceRefresh = false}) async {
    if (_instructor.isNotEmpty && !forceRefresh) {
      isLoadingInstructors = false;
      return;
    }
    isLoadingInstructors = true;
    try {
      Response response = await parser.getIntructor(forceRefresh: forceRefresh);
      if (response.statusCode == 200) {
        final list = _extractList(response.body);
        if (list != null) {
          _instructor = [];
          for (var data in list) {
            UserInstructorModel intructor = UserInstructorModel.fromJson(data);
            final name = intructor.name?.toLowerCase() ?? '';
            final totalCourses = int.tryParse((intructor.instructor_data is Map
                        ? intructor.instructor_data["total_courses"]?.toString()
                        : null) ??
                    '0') ??
                0;
            if (name != 'system' && name != 'testapi') {
              _instructor.add(intructor);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('getIntructor error: $e');
    }
    isLoadingInstructors = false;
  }

  Future<void> getIntructor({bool forceRefresh = false}) async {
    isLoadingInstructors = _instructor.isEmpty || forceRefresh;
    update(['instructors']);
    await _fetchInstructor(forceRefresh: forceRefresh);
    update(['instructors']);
  }

  Future<void> _fetchCategoryHome({bool forceRefresh = false}) async {
    if (_categoriesList.isNotEmpty && !forceRefresh) {
      isLoadingCategories = false;
      return;
    }
    isLoadingCategories = true;
    try {
      Response response =
          await parser.getCategoryHome(forceRefresh: forceRefresh);
      if (response.statusCode == 200) {
        final list = _extractList(response.body);
        if (list != null) {
          _categoriesList =
              list.map((data) => CategoryModel.fromJson(data)).toList();
        }
      }
    } catch (e) {
      debugPrint('getCategoryHome error: $e');
    }
    isLoadingCategories = false;
  }

  Future<void> getCategoryHome({bool forceRefresh = false}) async {
    isLoadingCategories = _categoriesList.isEmpty || forceRefresh;
    update(['categories']);
    await _fetchCategoryHome(forceRefresh: forceRefresh);
    update(['categories']);
  }

  Future<void> _fetchOverview({bool forceRefresh = false}) async {
    // Overview requires authentication — skip if not logged in
    if (token.isEmpty) {
      isLoadingOverview = false;
      return;
    }
    isLoadingOverview = true;
    try {
      Response response = await parser.getOverview(forceRefresh: forceRefresh);
      if (response.statusCode == 200) {
        _overview = response.body;
      }
    } catch (e) {
      debugPrint('getOverview error: $e');
    }
    isLoadingOverview = false;
  }

  Future<void> getOverview({bool forceRefresh = false}) async {
    isLoadingOverview = true;
    update(['overview']);
    await _fetchOverview(forceRefresh: forceRefresh);
    update(['overview']);
  }

  int _postsPage = 1;
  bool hasMorePosts = true;
  bool isLoadingMorePosts = false;

  Future<void> _fetchLatestPosts({bool forceRefresh = false}) async {
    if (_latestPosts.isNotEmpty && !forceRefresh) {
      isLoadingPosts = false;
      return;
    }
    isLoadingPosts = true;
    _postsPage = 1;
    hasMorePosts = true;
    try {
      Response response =
          await parser.getLatestPosts(page: 1, forceRefresh: forceRefresh);
      if (response.statusCode == 200) {
        final list = _extractList(response.body);
        if (list != null) {
          _latestPosts =
              list.map((data) => BlogPostModel.fromJson(data)).toList();
          hasMorePosts = list.length >= 10;
        }
      }
    } catch (e) {
      debugPrint('getLatestPosts error: $e');
    }
    isLoadingPosts = false;
  }

  Future<void> getLatestPosts({bool forceRefresh = false}) async {
    isLoadingPosts = _latestPosts.isEmpty || forceRefresh;
    update(['latestPosts']);
    await _fetchLatestPosts(forceRefresh: forceRefresh);
    update(['latestPosts']);
  }

  Future<void> loadMorePosts() async {
    if (isLoadingMorePosts || !hasMorePosts) return;
    isLoadingMorePosts = true;
    update();
    try {
      _postsPage++;
      Response response = await parser.getLatestPosts(page: _postsPage);
      if (response.statusCode == 200) {
        final list = _extractList(response.body);
        if (list != null) {
          for (var data in list) {
            _latestPosts.add(BlogPostModel.fromJson(data));
          }
          hasMorePosts = list.length >= 10;
        } else {
          hasMorePosts = false;
        }
      } else {
        hasMorePosts = false;
      }
    } catch (e) {
      debugPrint('loadMorePosts error: $e');
      hasMorePosts = false;
    }
    isLoadingMorePosts = false;
    update(['latestPosts']);
  }

  Future<void> _fetchUpcomingEvents({bool forceRefresh = false}) async {
    if (_upcomingEvents.isNotEmpty && !forceRefresh) {
      isLoadingEvents = false;
      return;
    }
    isLoadingEvents = true;
    try {
      Response response =
          await parser.getUpcomingEvents(forceRefresh: forceRefresh);
      if (response.statusCode == 200) {
        _upcomingEvents = [];
        final body = response.body;
        final eventsList = body is Map ? (body['events'] ?? []) : body;
        if (eventsList is List) {
          for (var data in eventsList) {
            _upcomingEvents.add(EventModel.fromJson(data));
          }
        }
      }
    } catch (e) {
      debugPrint('getUpcomingEvents error: $e');
    }
    isLoadingEvents = false;
  }

  Future<void> getUpcomingEvents({bool forceRefresh = false}) async {
    isLoadingEvents = _upcomingEvents.isEmpty || forceRefresh;
    update(['events']);
    await _fetchUpcomingEvents(forceRefresh: forceRefresh);
    update(['events']);
  }

  Future<void> getBlogCategories({bool forceRefresh = false}) async {
    try {
      Response response =
          await parser.getBlogCategories(forceRefresh: forceRefresh);
      if (response.statusCode == 200) {
        final list = _extractList(response.body);
        if (list != null) {
          _blogCategories =
              list.map((data) => Map<String, dynamic>.from(data)).toList();
        }
      }
    } catch (e) {
      debugPrint('getBlogCategories error: $e');
    }
    update();
  }

  void selectBlogCategory(int? categoryId) {
    selectedBlogCategory = categoryId;
    update();
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
    final success = await wishlistStore.optimisticToggle(item);
    if (!success) {
      showToast(tr(LocaleKeys.errorMessages_loadWishlist), isError: true);
    }
    update();
  }

  setOverviewId(value) {
    parser.setOverviewId(value);
  }

  handleCheckoutUser(id) async {
    try {
      Response response = await parser.getUser(id);
      if (response.statusCode != 200 &&
          response.body != null &&
          response.body is Map &&
          response.body['code'] == 'rest_user_invalid_id') {
        final profileParser = ProfileParser();
        profileParser.clearAccount();
        sessionStore.token = "";
        update();
      }
    } catch (e) {
      debugPrint('handleCheckoutUser error: $e');
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

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }
}
