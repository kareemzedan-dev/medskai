/// API Response Handler
///
/// Utilities for handling API responses and errors.
///
/// Usage:
/// ```dart
/// // Check if response is successful
/// if (ApiResponse.isSuccess(response)) {
///   // Handle success
/// } else {
///   final error = ErrorHandler.handleResponse(response);
/// }
/// ```
library api_response;

import 'package:get/get.dart';

/// HTTP Status Codes
class HttpStatus {
  HttpStatus._();

  static const int ok = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int validationError = 422;
  static const int serverError = 500;
  static const int connectionFailed = 1;
}

/// API Response Handler
class ApiResponse {
  ApiResponse._();

  // ============================================================
  // Success Checks
  // ============================================================

  /// Check if response is successful (200-299)
  static bool isSuccess(Response response) {
    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
  }

  /// Check if status code indicates success
  static bool isSuccessCode(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  // ============================================================
  // Error Checks
  // ============================================================

  /// Check if response is unauthorized (401)
  static bool isUnauthorized(Response response) {
    return response.statusCode == HttpStatus.unauthorized;
  }

  /// Check if response is forbidden (403)
  static bool isForbidden(Response response) {
    return response.statusCode == HttpStatus.forbidden;
  }

  /// Check if response is not found (404)
  static bool isNotFound(Response response) {
    return response.statusCode == HttpStatus.notFound;
  }

  /// Check if response is server error (500+)
  static bool isServerError(Response response) {
    return response.statusCode != null && response.statusCode! >= 500;
  }

  /// Check if connection failed
  static bool isConnectionError(Response response) {
    return response.statusCode == HttpStatus.connectionFailed;
  }

  // ============================================================
  // Error Handling (Legacy)
  // ============================================================

  /// Handle API error — use ErrorHandler.handleResponse() instead for
  /// the new AppError-based flow.
  @Deprecated('Use ErrorHandler.handleResponse() instead')
  static void handleError(Response response) {
    // Import at call site to avoid circular dependency
    // ignore: avoid_dynamic_calls
    _legacyHandleError(response);
  }

  static void _legacyHandleError(Response response) {
    // Legacy callers should migrate to ErrorHandler.handleResponse()
    // For now, just log
    final message = getErrorMessage(response) ?? 'Unknown error';
    // ignore: avoid_print
    print('API Error (legacy handler): $message');
  }

  // ============================================================
  // Message Extraction
  // ============================================================

  /// Extract error message from response
  static String? getErrorMessage(Response response) {
    if (response.body is Map) {
      final body = response.body as Map;
      if (body.containsKey('message')) {
        return body['message']?.toString();
      }
      if (body.containsKey('error')) {
        return body['error']?.toString();
      }
      if (body.containsKey('errors')) {
        final errors = body['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.first['message']?.toString();
        }
      }
    }
    return response.statusText;
  }

  /// Extract data from successful response
  static dynamic getData(Response response) {
    if (response.body is Map) {
      final body = response.body as Map;
      if (body.containsKey('data')) {
        return body['data'];
      }
    }
    return response.body;
  }
}

/// Legacy API Checker for backwards compatibility
@Deprecated('Use ErrorHandler.handleResponse() instead')
class ApiChecker {
  static void checkApi(Response response) {
    // ignore: deprecated_member_use_from_same_package
    ApiResponse.handleError(response);
  }
}
