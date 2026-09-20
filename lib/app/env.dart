/// App Environments Configuration
///
/// Configure app settings and API endpoints here.
/// To switch backends, change [currentBackend] value.
class Environments {
  Environments._();

  // ============================================================
  // App Info
  // ============================================================

  static const String appName = 'MedsKai';
  static const String companyName = 'MedsKai';
  static const String appVersion = '1.2.0';
  static const String appBuild = '10100';

  // ============================================================
  // Backend Selection
  // ============================================================

  /// Current backend to use
  /// Options: 'learnpress', 'laravel', 'local', 'staging'
  static const String currentBackend = 'learnpress';

  // ============================================================
  // API URLs
  // ============================================================

  /// LearnPress backend (current)
  static const String learnpressBaseURL = 'https://medskai.com/';

  /// New Laravel backend (AlMadrash)
  static const String laravelBaseURL = 'https://api.almadrash.com/';

  /// Local development server
  static const String localBaseURL = 'http://localhost:8000/';

  /// Staging server
  static const String stagingBaseURL = 'https://staging.almadrash.com/';

  /// Get current API base URL based on selected backend
  static String get apiBaseURL {
    switch (currentBackend) {
      case 'laravel':
        return laravelBaseURL;
      case 'local':
        return localBaseURL;
      case 'staging':
        return stagingBaseURL;
      case 'learnpress':
      default:
        return learnpressBaseURL;
    }
  }

  /// Website URL
  static const String websiteURL = 'https://medskai.com/';

  // ============================================================
  // Social Login
  // ============================================================

  static const String googleClientId = '378405534930-m7d4m9kavm85jkg1b1b7tcdv2s245jqb.apps.googleusercontent.com';
  static const String googleServerClientId = '378405534930-ls0e11ptboa3s84a5rp5vu87e246j4mm.apps.googleusercontent.com';
  static const String facebookClientId = '';
  static const String facebookClientSecret = '';

  // ============================================================
  // Feature Flags
  // ============================================================

  /// Enable API logging in debug mode only
  static const bool enableApiLogging = false;

  /// Use new endpoint structure (for Laravel backend)
  static bool get useNewEndpoints => currentBackend == 'laravel';
}
