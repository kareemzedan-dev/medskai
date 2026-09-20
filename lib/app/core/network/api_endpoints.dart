/// LearnPress REST API Endpoints
///
/// Based on official LearnPress API Documentation.
/// Host: https://medskai.com
///
/// Usage:
/// ```dart
/// final loginUrl = ApiEndpoints.auth.login;
/// final coursesUrl = ApiEndpoints.courses.list;
/// ```
library api_endpoints;

/// API Endpoints Manager
class ApiEndpoints {
  ApiEndpoints._();

  static const String _base = 'wp-json/learnpress/v1';
  static const String _baseMobile = 'wp-json/lp/v1/mobile-app';
  static const String _baseNotify = 'wp-json/learnpress';

  /// Authentication endpoints
  static final AuthEndpoints auth = AuthEndpoints._();

  /// User endpoints
  static final UserEndpoints user = UserEndpoints._();

  /// Course endpoints
  static final CourseEndpoints courses = CourseEndpoints._();

  /// Lesson endpoints
  static final LessonEndpoints lessons = LessonEndpoints._();

  /// Quiz endpoints
  static final QuizEndpoints quiz = QuizEndpoints._();

  /// Assignment endpoints
  static final AssignmentEndpoints assignment =
      AssignmentEndpoints._();

  /// Review endpoints
  static final ReviewEndpoints review = ReviewEndpoints._();

  /// Wishlist endpoints
  static final WishlistEndpoints wishlist =
      WishlistEndpoints._();

  /// Course Category endpoints
  static final CategoryEndpoints categories =
      CategoryEndpoints._();

  /// Notification endpoints
  static final NotificationEndpoints notification =
      NotificationEndpoints._();

  /// Social Login endpoints
  static final SocialLoginEndpoints socialLogin =
      SocialLoginEndpoints._();

  /// Payment endpoints
  static final PaymentEndpoints payment =
      PaymentEndpoints._();

  /// Certificate endpoints
  static final CertificateEndpoints certificates =
      CertificateEndpoints._();

  /// Blog/Posts endpoints
  static final BlogEndpoints blog = BlogEndpoints._();

  /// Events endpoints (The Events Calendar plugin)
  static final EventEndpoints events = EventEndpoints._();

  /// WooCommerce Cart endpoints (Store API)
  static final CartEndpoints cart = CartEndpoints._();

  /// Contact Form endpoints (CF7)
  static final ContactEndpoints contact = ContactEndpoints._();

  /// Job Listings endpoints
  static final JobEndpoints jobs = JobEndpoints._();

  /// Blog Categories endpoints (WordPress)
  static final BlogCategoryEndpoints blogCategories =
      BlogCategoryEndpoints._();

  /// QA Ask Instructor endpoints
  static final QaEndpoints qa = QaEndpoints._();
}

// ============================================================
// Authentication
// ============================================================

class AuthEndpoints {
  AuthEndpoints._();

  /// Get Token (Login)
  /// POST - params: username, password
  String get login => '${ApiEndpoints._base}/token';

  /// Validate Token
  String get validateToken =>
      '${ApiEndpoints._base}/token/validate';

  /// Register
  /// POST - params: username, email, password, confirm_password
  String get register =>
      '${ApiEndpoints._base}/token/register';

  /// Reset Password
  /// POST - params: user_login (username or email)
  String get resetPassword =>
      '${ApiEndpoints._base}/users/reset-password';
}

// ============================================================
// Users
// ============================================================

class UserEndpoints {
  UserEndpoints._();

  /// Get users list
  /// GET - params: exclude, include, offset, order, orderby,
  ///   slug, roles, who
  String get list => '${ApiEndpoints._base}/users';

  /// Get specific user by ID
  String detail(int id) => '${ApiEndpoints._base}/users/$id';
}

// ============================================================
// Courses
// ============================================================

class CourseEndpoints {
  CourseEndpoints._();

  /// Get all courses
  /// GET - params: context, page, per_page, search, after,
  ///   before, exclude, include, offset, order, orderby,
  ///   category, tag
  String get list => '${ApiEndpoints._base}/courses';

  /// Get specific course
  String detail(int id) =>
      '${ApiEndpoints._base}/courses/$id';

  /// Get my courses (enrolled)
  /// GET - params: context, page, per_page, search,
  ///   course_filter (in-progress, passed, failed)
  String get myCourses =>
      '${ApiEndpoints._base}/courses/?learned=true';

  /// Enroll in course
  /// POST - params: id (course_id)
  String get enroll =>
      '${ApiEndpoints._base}/courses/enroll';

  /// Finish course
  /// POST - params: id (course_id)
  String get finish =>
      '${ApiEndpoints._base}/courses/finish';

  /// Retake course
  /// POST - params: id (course_id)
  String get retake =>
      '${ApiEndpoints._base}/courses/retake';
}

// ============================================================
// Lessons
// ============================================================

class LessonEndpoints {
  LessonEndpoints._();

  /// Get all lessons
  /// GET - params: context, page, per_page, search, after,
  ///   before, exclude, include, offset, order, orderby
  String get list => '${ApiEndpoints._base}/lessons';

  /// Get specific lesson
  String detail(int id) =>
      '${ApiEndpoints._base}/lessons/$id';

  /// Finish lesson
  /// POST - params: id (lesson_id)
  String get finish =>
      '${ApiEndpoints._base}/lessons/finish';
}

// ============================================================
// Quizzes
// ============================================================

class QuizEndpoints {
  QuizEndpoints._();

  /// Get all quizzes
  /// GET - params: context, page, per_page, search, after,
  ///   before, exclude, include, offset, order, orderby
  String get list => '${ApiEndpoints._base}/quiz';

  /// Get specific quiz
  String detail(int id) =>
      '${ApiEndpoints._base}/quiz/$id';

  /// Start quiz
  /// POST - params: id (quiz_id)
  String get start => '${ApiEndpoints._base}/quiz/start';

  /// Check answer
  /// POST - params: id (quiz_id), answered (string)
  String get checkAnswer =>
      '${ApiEndpoints._base}/quiz/check_answer';

  /// Finish quiz
  /// POST - params: id (quiz_id), answered (object)
  String get finish => '${ApiEndpoints._base}/quiz/finish';
}

// ============================================================
// Assignments
// ============================================================

class AssignmentEndpoints {
  AssignmentEndpoints._();

  /// Get all assignments
  /// GET - params: context, page, per_page, search, after,
  ///   before, exclude, include, offset, order, orderby
  String get list => '${ApiEndpoints._base}/assignments';

  /// Get specific assignment
  String detail(int id) =>
      '${ApiEndpoints._base}/assignments/$id';

  /// Start assignment
  /// POST - params: id (assignment_id)
  String get start =>
      '${ApiEndpoints._base}/assignments/start';

  /// Retake assignment
  /// POST - params: id (assignment_id)
  String get retake =>
      '${ApiEndpoints._base}/assignments/retake';

  /// Submit assignment
  /// POST multipart/form-data
  /// params: action (submit/save), id, note, file[]
  String get submit =>
      '${ApiEndpoints._base}/assignments/submit';

  /// Delete submitted file
  /// POST - params: fileId, id (assignment_id)
  String get deleteFile =>
      '${ApiEndpoints._base}/assignments/delete-submit-file';
}

// ============================================================
// Reviews
// ============================================================

class ReviewEndpoints {
  ReviewEndpoints._();

  /// Get course reviews
  /// GET - params: page, per_page
  String course(int id) =>
      '${ApiEndpoints._base}/review/course/$id';

  /// Submit review
  /// POST - params: id (course_id), rate (1-5), title,
  ///   content
  String get submit =>
      '${ApiEndpoints._base}/review/submit';
}

// ============================================================
// Wishlist
// ============================================================

class WishlistEndpoints {
  WishlistEndpoints._();

  /// Get user wishlist
  /// GET - params: page, per_page, optimize
  String get list => '${ApiEndpoints._base}/wishlist';

  /// Get wishlist for course
  String course(int id) =>
      '${ApiEndpoints._base}/wishlist/course/$id';

  /// Toggle wishlist (add/remove)
  /// POST - params: id (course_id)
  String get toggle =>
      '${ApiEndpoints._base}/wishlist/toggle';
}

// ============================================================
// Course Categories
// ============================================================

class CategoryEndpoints {
  CategoryEndpoints._();

  /// Get all course categories
  String get list => 'wp-json/wp/v2/course_category';
}

// ============================================================
// Notifications
// ============================================================

class NotificationEndpoints {
  NotificationEndpoints._();

  /// Get notifications
  String get list =>
      '${ApiEndpoints._baseNotify}/notifications/v1/notifications';

  /// Register FCM device token
  String get registerDevice =>
      '${ApiEndpoints._base}/push-notifications/register-device';

  /// Delete FCM device token
  String get deleteDevice =>
      '${ApiEndpoints._base}/push-notifications/delete-device';
}

// ============================================================
// Social Login
// ============================================================

class SocialLoginEndpoints {
  SocialLoginEndpoints._();

  /// Verify Google login
  String get verifyGoogle =>
      '${ApiEndpoints._baseMobile}/verify-google';

  /// Verify Facebook login
  String get verifyFacebook =>
      '${ApiEndpoints._baseMobile}/verify-facebook';

  /// Check if social login is enabled
  String get enableSocial =>
      '${ApiEndpoints._baseMobile}/enable-social';
}

// ============================================================
// Payment
// ============================================================

class PaymentEndpoints {
  PaymentEndpoints._();

  /// Verify receipt
  String get verifyReceipt =>
      '${ApiEndpoints._base}/courses/verify-receipt';
}

// ============================================================
// Certificates
// ============================================================

class CertificateEndpoints {
  CertificateEndpoints._();

  /// Get user certificates (medskai custom endpoint)
  String get myCertificates => 'wp-json/medskai/v1/certificates/me';
}

// ============================================================
// Blog / Posts
// ============================================================

class BlogEndpoints {
  BlogEndpoints._();

  /// Get blog posts (WordPress standard)
  /// GET - params: per_page, page, _embed, orderby, order, categories, tags
  String get list => 'wp-json/wp/v2/posts';
}

// ============================================================
// Events (The Events Calendar)
// ============================================================

class EventEndpoints {
  EventEndpoints._();

  static const String _baseEvents = 'wp-json/tribe/events/v1';

  /// Get upcoming events
  /// GET - params: page, per_page, start_date, end_date, search, categories
  String get list => '$_baseEvents/events';

  /// Get specific event
  String detail(int id) => '$_baseEvents/events/$id';
}

// ============================================================
// WooCommerce Cart (Store API)
// ============================================================

class CartEndpoints {
  CartEndpoints._();

  static const String _baseStore = 'wp-json/wc/store/v1';

  /// Get cart contents
  String get get => '$_baseStore/cart';

  /// Add item to cart
  /// POST - params: id, quantity
  String get addItem => '$_baseStore/cart/add-item';

  /// Remove item from cart
  /// POST - params: key
  String get removeItem => '$_baseStore/cart/remove-item';

  /// Apply coupon
  /// POST - params: code
  String get applyCoupon => '$_baseStore/cart/apply-coupon';

  /// Remove coupon
  /// POST - params: code
  String get removeCoupon => '$_baseStore/cart/remove-coupon';

  /// Checkout
  /// POST - params: billing_address, payment_method, payment_data
  String get checkout => '$_baseStore/checkout';
}

// ============================================================
// Contact Form (CF7)
// ============================================================

class ContactEndpoints {
  ContactEndpoints._();

  /// Submit contact form
  /// POST - params: your-name, your-email, your-subject, your-message
  /// Note: Replace {formId} with actual CF7 form ID from WordPress admin
  String feedback(int formId) =>
      'wp-json/contact-form-7/v1/contact-forms/$formId/feedback';
}

// ============================================================
// Job Listings (WP Job Manager)
// ============================================================

class JobEndpoints {
  JobEndpoints._();

  /// Get job listings
  /// GET - standard WP REST params: page, per_page, search, orderby, order
  String get list => 'wp-json/wp/v2/job-listings';
}

// ============================================================
// Blog Categories (WordPress)
// ============================================================

class BlogCategoryEndpoints {
  BlogCategoryEndpoints._();

  /// Get blog categories with post counts
  String get list => 'wp-json/wp/v2/categories';

  /// Get blog tags
  String get tags => 'wp-json/wp/v2/tags';
}

// ============================================================
// QA / Ask Instructor
// ============================================================

class QaEndpoints {
  QaEndpoints._();

  static const String _baseAsk = 'wp-json/medskai-ask/v1';

  /// Get course questions or Ask a question (POST)
  String courseQuestions(int id) => '$_baseAsk/course/$id/questions';

  /// Reply to a question (POST)
  String replyQuestion(int id) => '$_baseAsk/questions/$id/reply';
}
