import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../backend/api/api.dart';
import '../../core/network/api_cache_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/offline_storage.dart';
import '../../backend/mobx-store/session_store.dart';
import '../../backend/mobx-store/wishlist_store.dart';
import '../../backend/mobx-store/course_store.dart';
import '../../backend/mobx-store/learning_quiz_store.dart';
import '../../helper/shared_pref.dart';
import '../../env.dart';

// Import Parsers
import '../../backend/parse/splash_parse.dart';
import '../../backend/parse/intro_parse.dart';
import '../../backend/parse/tabs_parse.dart';
import '../../backend/parse/home_parse.dart';
import '../../backend/parse/courses_parse.dart';
import '../../backend/parse/my_courses_parse.dart';
import '../../backend/parse/wishlist_parse.dart';
import '../../backend/parse/search_course_parse.dart';
import '../../backend/parse/my_profile_parse.dart';
import '../../backend/parse/course_detail_parse.dart';
import '../../backend/parse/payment_parse.dart';
import '../../backend/parse/login_parse.dart';
import '../../backend/parse/forgot_password_parse.dart';
import '../../backend/parse/register_parse.dart';
import '../../backend/parse/learning_parse.dart';
import '../../backend/parse/finish-learning_parse.dart';
import '../../backend/parse/instructor_detail_parse.dart';
import '../../backend/parse/notification_parse.dart';
import '../../backend/parse/settings_parse.dart';
import '../../backend/parse/review_parse.dart';
import '../../backend/parse/profile_parse.dart';
import '../../backend/parse/social_login_parse.dart';
import '../../backend/parse/events_parse.dart';
import '../../backend/parse/cart_parse.dart';
import '../../backend/parse/contact_parse.dart';
import '../../backend/parse/community_parse.dart';
import '../../backend/parse/jobs_parse.dart';
import '../../backend/parse/discussion_parse.dart';

// Import Controllers
import '../../controller/notification_controller.dart';
import '../../controller/language_controller.dart';
import '../../controller/tabs_controller.dart';
import '../../controller/social_login_controller.dart';
import '../../controller/theme_controller.dart';

/// GetIt Service Locator instance
final getIt = GetIt.instance;

/// Dependency Injection Manager
///
/// Handles registration of all app dependencies using GetX and GetIt
class DependencyInjection {
  DependencyInjection._();

  /// Initialize all dependencies
  ///
  /// Call this in main.dart before runApp()
  static Future<void> init() async {
    // Phase 1: Core Services
    await _initCoreServices();

    // Phase 2: API Services
    _initApiServices();

    // Phase 3: Parsers (Data Access Layer)
    _initParsers();

    // Phase 4: State Stores (MobX)
    _initStores();

    // Phase 5: Controllers
    _initControllers();
  }

  /// Initialize core services (SharedPreferences, etc.)
  static Future<void> _initCoreServices() async {
    final sharedPref = await SharedPreferences.getInstance();

    // Register SharedPreferencesManager as permanent singleton (single instance)
    final sharedPrefsManager = SharedPreferencesManager(sharedPreferences: sharedPref);
    await sharedPrefsManager.initSecureToken();
    Get.put(sharedPrefsManager, permanent: true);

    // Also register same instance in GetIt for MobX stores
    getIt.registerSingleton<SharedPreferencesManager>(sharedPrefsManager);

    // Initialize API Cache Service
    final cacheService = ApiCacheService(sharedPref);
    await cacheService.init();
    Get.put<ApiCacheService>(cacheService, permanent: true);

    // Initialize Offline Storage Service
    Get.put(OfflineStorage(sharedPref), permanent: true);

    // Initialize Connectivity Service
    final connectivityService = ConnectivityService();
    await connectivityService.init();
    Get.put<ConnectivityService>(connectivityService, permanent: true);
  }

  /// Initialize API services
  static void _initApiServices() {
    Get.lazyPut(
      () => ApiService(appBaseUrl: Environments.apiBaseURL),
    );
  }

  /// Initialize all Parsers (Data Access Layer)
  static void _initParsers() {
    // Auth Parsers
    Get.lazyPut(
      () => SplashParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => IntroParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => LoginParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => RegisterParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => ForgotPasswordParse(apiService: Get.find()),
      fenix: true,
    );

    Get.lazyPut(
      () => SocialLoginParse(
        sharedPreferencesManager: Get.find(),
        apiService: Get.find(),
      ),
      fenix: true,
    );

    // Navigation Parsers
    Get.lazyPut(
      () => TabsParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    // Home & Courses Parsers
    Get.lazyPut(
      () => HomeParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => CoursesParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => MyCoursesParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => CourseDetailParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => SearchCourseParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    // Learning Parsers
    Get.lazyPut(
      () => LearningParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => FinishLearningParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    // User Parsers
    Get.lazyPut(
      () => WishlistParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => MyProfileParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => ProfileParser(),
      fenix: true,
    );

    Get.lazyPut(
      () => SettingsParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
        sessionStore: Get.find(),
      ),
      fenix: true,
    );

    // Instructor & Review Parsers
    Get.lazyPut(
      () => InstructorDetailParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => ReviewParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    // Payment & Notification Parsers
    Get.lazyPut(
      () => PaymentParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => NotificationParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    // New Feature Parsers (005-web-app-parity)
    Get.lazyPut(
      () => EventsParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => CartParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => ContactParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => CommunityParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => JobsParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => DiscussionParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ),
      fenix: true,
    );
  }

  /// Initialize MobX Stores
  static void _initStores() {
    final sharedPref = Get.find<SharedPreferencesManager>();
    final apiService = Get.find<ApiService>();

    final sessionStore = SessionStore();
    sessionStore.initStore(sharedPref, apiService);

    final wishlistStore = WishlistStore();

    // Register in GetIt for dependency lookup
    getIt.registerSingleton<CourseStore>(CourseStore());
    getIt.registerSingleton<LearningQuizStore>(LearningQuizStore());
    getIt.registerSingleton<SessionStore>(sessionStore);
    getIt.registerSingleton<WishlistStore>(wishlistStore);

    // Also register in GetX for controller access
    Get.put<SessionStore>(sessionStore, permanent: true);
    Get.put<WishlistStore>(wishlistStore, permanent: true);
  }

  /// Initialize Controllers
  static void _initControllers() {
    Get.lazyPut(
      () => NotificationController(parser: Get.find()),
      fenix: true,
    );

    Get.lazyPut(
      () => LanguageController(sharedPreferencesManager: Get.find()),
      fenix: true,
    );

    Get.lazyPut(
      () => TabControllerX(),
      fenix: true,
    );

    Get.lazyPut(
      () => SocialLoginController(),
      fenix: true,
    );

    Get.lazyPut(
      () => ThemeController(prefs: Get.find()),
      fenix: true,
    );
  }

  /// Reset all dependencies (useful for testing)
  static Future<void> reset() async {
    await getIt.reset();
    Get.reset();
  }
}

/// Legacy MainBinding for backwards compatibility
@Deprecated('Use DependencyInjection.init() instead')
class MainBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    await DependencyInjection.init();
  }
}
