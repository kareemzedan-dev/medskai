import 'package:flutter_app/app/backend/binding/course_detail_binding.dart';
import 'package:flutter_app/app/backend/binding/finish_learning_binding.dart';
import 'package:flutter_app/app/backend/binding/home_binding.dart';
import 'package:flutter_app/app/backend/binding/learning_binding.dart';
import 'package:flutter_app/app/backend/binding/login_binding.dart';
import 'package:flutter_app/app/backend/binding/notification_binding.dart';
import 'package:flutter_app/app/backend/binding/register_binding.dart';
import 'package:flutter_app/app/backend/binding/review_binding.dart';
import 'package:flutter_app/app/backend/binding/search_course_binding.dart';
import 'package:flutter_app/app/backend/binding/splash_binding.dart';
import 'package:flutter_app/app/backend/binding/tabs_binding.dart';
import 'package:flutter_app/app/view/course_detail.dart';
import 'package:flutter_app/app/view/finish_learning.dart';
import 'package:flutter_app/app/view/forgot_password.dart';
import 'package:flutter_app/app/view/home.dart';
import 'package:flutter_app/app/view/instructor_detail.dart';
import 'package:flutter_app/app/view/learning.dart';
import 'package:flutter_app/app/view/login.dart';
import 'package:flutter_app/app/view/notification.dart';
import 'package:flutter_app/app/view/register.dart';
import 'package:flutter_app/app/view/review.dart';
import 'package:flutter_app/app/view/search-course.dart';
import 'package:flutter_app/app/view/splash.dart';
import 'package:flutter_app/app/view/tabs.dart';
import 'package:get/get.dart';

import '../../app/core/navigation/auth_middleware.dart';
import '../backend/binding/certificates_binding.dart';
import '../backend/binding/settings_binding.dart';
import '../backend/binding/forgot_password_binding.dart';
import '../backend/binding/intructor_detail_binding.dart';
import '../backend/binding/language_binding.dart';
import '../view/components/profile/settings/delete-account.dart';
import '../view/components/profile/settings/general.dart';
import '../view/components/profile/settings/language.dart';
import '../view/components/profile/settings/password.dart';
import '../view/membership.dart';
import '../view/certificates.dart';
import '../view/about_us.dart';
import '../view/instructors_list.dart';
import '../view/blog.dart';
import '../view/privacy_policy.dart';
import '../view/terms_conditions.dart';
import '../view/events.dart';
import '../view/event_detail.dart';
import '../view/cart.dart';
import '../view/checkout.dart';
import '../view/contact.dart';
import '../view/become_instructor.dart';
import '../view/jobs.dart';
import '../view/add_job.dart';
import '../view/team.dart';
import '../backend/binding/events_binding.dart';
import '../backend/binding/cart_binding.dart';
import '../backend/binding/contact_binding.dart';
import '../backend/binding/jobs_binding.dart';
import '../view/community_screen.dart';
import '../view/discussions_screen.dart';
import '../backend/binding/community_binding.dart';
import '../backend/binding/discussions_binding.dart';
import '../view/certificate_webview.dart';
class AppRouter {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String tabsBarRoutes = '/tabs';
  static const String home = '/home';
  static const String login = '/login';
  static const String forgotPassword = '/forgotPassword';
  static const String register = '/register';
  static const String courseDetail = '/course_detail';
  static const String learning = '/learning';
  static const String finishLearning = '/finishLearning';
  static const String searchCourse = '/searchCourse';
  static const String instructorDetail = '/instructorDetail';
  static const String notification = '/notification';
  static const String review = '/review';
  static const String language = '/language';
  static const String general = '/general';
  static const String password = '/password';
  static const String delete = '/delete';
  static const String membership = '/membership';
  static const String certificates = '/certificates';
  static const String aboutUs = '/aboutUs';
  static const String instructorsList = '/instructorsList';
  static const String blog = '/blog';
  static const String privacyPolicy = '/privacyPolicy';
  static const String termsConditions = '/termsConditions';
  static const String events = '/events';
  static const String eventDetail = '/eventDetail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String contact = '/contact';
  static const String becomeInstructor = '/becomeInstructor';
  static const String jobs = '/jobs';
  static const String jobDetail = '/job-detail';
  static const String addJob = '/add-job';
  static const String team = '/team';
  static const String community = '/community';
  static const String discussions = '/discussions';
  static const String certificateWebView = '/certificate-webview';

  static String getInitialRoute() => initial;
  static String getSplashRoute() => splash;
  static String getTabsBarRoute() => tabsBarRoutes;
  static String getHomeRoute() => home;
  static String getLoginRoute() => login;
  static String getRegisterRoute() => register;
  static String getCourseDetailRoute() => courseDetail;
  static String getLearningRoute() => learning;
  static String getFinishLearningRoute() => finishLearning;
  static String getSearchCourseRoute() => searchCourse;
  static String getInstructorDetailRoute() => instructorDetail;
  static String getNotificationRoute() => notification;
  static String getReview() => review;
  static String getForgotPassword() => forgotPassword;
  static String getLanguage() => language;
  static String getGeneral() => general;
  static String getPassword() => password;
  static String getDelete() => delete;
  static String getMembership() => membership;
  static String getCertificates() => certificates;
  static String getAboutUs() => aboutUs;
  static String getInstructorsList() => instructorsList;
  static String getBlog() => blog;
  static String getPrivacyPolicy() => privacyPolicy;
  static String getTermsConditions() => termsConditions;
  static String getEvents() => events;
  static String getEventDetail() => eventDetail;
  static String getCart() => cart;
  static String getCheckout() => checkout;
  static String getContact() => contact;
  static String getBecomeInstructor() => becomeInstructor;
  static String getJobs() => jobs;
  static String getTeam() => team;
  static String getCommunityRoute() => community;
  static String getDiscussionsRoute() => discussions;
  static String getCertificateWebView() => certificateWebView;

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => SplashScreen(), binding: SplashBinding()),
    GetPage(
        name: tabsBarRoutes, page: () => TabScreen(), binding: TabsBinding()),
    GetPage(name: home, page: () => HomeScreen(), binding: HomeBinding()),
    GetPage(name: login, page: () => LoginScreen(), binding: LoginBinding()),
    GetPage(
        name: forgotPassword,
        page: () => ForgotPasswordScreen(),
        binding: ForgotPasswordBinding()),
    GetPage(
        name: courseDetail,
        page: () => CourseDetailScreen(),
        binding: CourseDetailBinding(),
        preventDuplicates: false),
    GetPage(
      name: language,
      page: () => MultiLanguage(),
      binding: LanguageBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: general,
      page: () => GeneralAccount(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: password,
      page: () => Password(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: delete,
      page: () => DeleteAccount(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
        name: register,
        page: () => const RegisterScreen(),
        binding: RegisterBinding()),
    GetPage(
        name: learning,
        page: () => LearningScreen(),
        binding: LearningBinding(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: searchCourse,
        page: () => SearchCourseScreen(),
        binding: SearchCourseBinding()),
    GetPage(
        name: finishLearning,
        page: () => FinishLearningScreen(),
        binding: FinishLearningBinding()),
    GetPage(
      name: instructorDetail,
      page: () => InstructorDetailScreen(),
      binding: InstructorDetailBinding(),
    ),
    GetPage(
        name: notification,
        page: () => NotificationScreen(),
        binding: NotificationBinding(),
        middlewares: [AuthMiddleware()]),
    GetPage(name: review, page: () => ReviewScreen(), binding: ReviewBinding()),
    GetPage(
      name: membership,
      page: () => const MembershipScreen(),
    ),
    GetPage(
      name: certificates,
      page: () => const CertificatesScreen(),
      binding: CertificatesBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: aboutUs,
      page: () => const AboutUsScreen(),
    ),
    GetPage(
      name: instructorsList,
      page: () => const InstructorsListScreen(),
    ),
    GetPage(
      name: blog,
      page: () => const BlogScreen(),
    ),
    GetPage(
      name: privacyPolicy,
      page: () => PrivacyPolicyScreen(),
    ),
    GetPage(
      name: termsConditions,
      page: () => TermsConditionsScreen(),
    ),
    GetPage(
      name: events,
      page: () => const EventsScreen(),
      binding: EventsBinding(),
    ),
    GetPage(
      name: eventDetail,
      page: () => const EventDetailScreen(),
    ),
    GetPage(
      name: cart,
      page: () => const CartScreen(),
      binding: CartBinding(),
    ),
    GetPage(
      name: checkout,
      page: () => const CheckoutScreen(),
      binding: CartBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: contact,
      page: () => const ContactScreen(),
      binding: ContactBinding(),
    ),
    GetPage(
      name: becomeInstructor,
      page: () => const BecomeInstructorScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: jobs,
      page: () => const JobsScreen(),
      binding: JobsBinding(),
    ),
    GetPage(
      name: addJob,
      page: () => const AddJobScreen(),
      binding: JobsBinding(),
    ),
    GetPage(
      name: team,
      page: () => const TeamScreen(),
    ),
    GetPage(
      name: community,
      page: () => const CommunityScreen(),
      binding: CommunityBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: discussions,
      page: () => const DiscussionsScreen(),
      binding: DiscussionsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: certificateWebView,
      page: () => const CertificateWebViewScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
