/// API Handler - Legacy File
///
/// This file maintains backwards compatibility.
/// New code should use:
/// ```dart
/// import 'package:flutter_app/app/core/error/error_handler.dart';
/// ```
library handler;

import 'package:get/get.dart';
import 'package:flutter_app/app/core/error/error_handler.dart';

// Re-export from core for new imports
export '../../core/network/api_response.dart';

/// @Deprecated('Use ErrorHandler.handleResponse() instead')
class ApiChecker {
  static void checkApi(Response response) {
    ErrorHandler.handleResponse(response);
  }
}
