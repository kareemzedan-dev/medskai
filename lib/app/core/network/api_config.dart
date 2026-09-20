/// API Configuration
///
/// Centralized configuration for API base URLs and settings.
/// Supports easy switching between different backends.
///
/// Usage:
/// ```dart
/// // Get current base URL
/// final baseUrl = ApiConfig.baseUrl;
///
/// // Switch backend
/// ApiConfig.setBackend(ApiBackend.staging);
/// ```
library api_config;

import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/env.dart';

/// Available backend environments
enum ApiBackend {
  /// LearnPress backend (current)
  learnpress,

  /// Laravel backend
  laravel,

  /// Local development server
  local,

  /// Staging server for testing
  staging,
}

/// API Configuration Manager
class ApiConfig {
  ApiConfig._();

  // ============================================================
  // Backend URLs
  // ============================================================

  /// LearnPress backend (from Environments)
  static String get _learnpressUrl => Environments.learnpressBaseURL;

  /// New Laravel backend (from Environments)
  static String get _laravelUrl => Environments.laravelBaseURL;

  /// Local development server (from Environments)
  static String get _localUrl => Environments.localBaseURL;

  /// Staging server (from Environments)
  static String get _stagingUrl => Environments.stagingBaseURL;

  // ============================================================
  // Current Backend
  // ============================================================

  /// Current active backend
  static ApiBackend _currentBackend = ApiBackend.learnpress;

  /// Get current backend
  static ApiBackend get currentBackend => _currentBackend;

  /// Set current backend
  static void setBackend(ApiBackend backend) {
    _currentBackend = backend;
  }

  // ============================================================
  // Base URL
  // ============================================================

  /// Get current base URL based on active backend
  static String get baseUrl {
    switch (_currentBackend) {
      case ApiBackend.learnpress:
        return _learnpressUrl;
      case ApiBackend.laravel:
        return _laravelUrl;
      case ApiBackend.local:
        return _localUrl;
      case ApiBackend.staging:
        return _stagingUrl;
    }
  }

  /// Check if using LearnPress backend
  static bool get isLearnPress => _currentBackend == ApiBackend.learnpress;

  /// Check if using Laravel backend
  static bool get isLaravel => _currentBackend == ApiBackend.laravel;

  // ============================================================
  // API Settings
  // ============================================================

  /// Request timeout in seconds
  static const int timeoutSeconds = 30;

  /// Platform identifier header
  static const String platformHeader = 'flutter';

  /// Content type for JSON requests
  static const String contentTypeJson = 'application/json';

  // ============================================================
  // Headers
  // ============================================================

  /// Get default headers for public requests
  static Map<String, String> get publicHeaders => {
        'Content-Type': contentTypeJson,
        'Accept': contentTypeJson,
        'x-platform': platformHeader,
      };

  /// Get headers for authenticated requests
  static Map<String, String> authHeaders(String token) => {
        'Content-Type': contentTypeJson,
        'Accept': contentTypeJson,
        'x-platform': platformHeader,
        'Authorization': 'Bearer $token',
      };

  // ============================================================
  // Debug
  // ============================================================

  /// Enable/disable API logging
  static bool enableLogging = true;

  /// Log API request (only in debug mode)
  static void logRequest(String method, String url) {
    if (enableLogging) {
      debugPrint('[$method] $url');
    }
  }

  /// Log API response (only in debug mode)
  static void logResponse(int statusCode, String url) {
    if (enableLogging) {
      debugPrint('[$statusCode] $url');
    }
  }
}
