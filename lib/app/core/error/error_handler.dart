import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/core/error/app_error.dart';
import 'package:flutter_app/app/core/network/api_response.dart';
import 'package:flutter_app/app/helper/dialog_helper.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

/// Centralized error handler
///
/// Classifies errors from API responses and routes them to the
/// appropriate UI presentation (snackbar, dialog, etc.).
class ErrorHandler {
  ErrorHandler._();

  /// Track last shown error to deduplicate concurrent identical errors
  static String? _lastErrorMessage;
  static DateTime? _lastErrorTime;
  static const _deduplicationWindow = Duration(seconds: 2);

  // ============================================================
  // Classification
  // ============================================================

  /// Create an AppError from a GetX Response
  static AppError fromResponse(Response response) {
    final statusCode = response.statusCode;

    if (statusCode == HttpStatus.connectionFailed || statusCode == 0) {
      return AppError.network(
        originalException: response.statusText,
        statusCode: statusCode,
      );
    }

    if (statusCode == HttpStatus.unauthorized) {
      return AppError.authentication(
        isSessionExpired: true,
        originalException: response.statusText,
        statusCode: statusCode,
      );
    }

    if (statusCode == HttpStatus.forbidden) {
      return AppError.authentication(
        isSessionExpired: false,
        originalException: response.statusText,
        statusCode: statusCode,
      );
    }

    if (statusCode == HttpStatus.validationError) {
      final message = ApiResponse.getErrorMessage(response);
      return AppError.validation(
        message: message,
        originalException: response.statusText,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return AppError.server(
        originalException: response.statusText,
        statusCode: statusCode,
      );
    }

    // Fallback: try to extract a message from the response
    final message = ApiResponse.getErrorMessage(response);
    if (message != null && message.isNotEmpty) {
      return AppError(
        type: ErrorType.unexpected,
        title: message,
        isRetryable: true,
        originalException: response.statusText,
        statusCode: statusCode,
      );
    }

    return AppError.unexpected(originalException: response.statusText);
  }

  /// Create an AppError from a caught exception
  static AppError fromException(Object error) {
    return AppError.network(originalException: error);
  }

  // ============================================================
  // Presentation
  // ============================================================

  /// Show error using its default presentation
  static void show(AppError error, {ErrorPresentation? presentation}) {
    final mode = presentation ?? error.defaultPresentation;

    // Deduplicate: skip if same message was shown within the window
    if (_isDuplicate(error.title)) return;
    _recordShown(error.title);

    switch (mode) {
      case ErrorPresentation.snackbar:
        showToast(error.title, isError: true);
        break;
      case ErrorPresentation.dialog:
        DialogHelper.showErrorDialog(
          title: error.title,
          description: error.description,
        );
        break;
      case ErrorPresentation.inlinePage:
        // Inline errors are handled by controllers setting error state
        // Just log — the controller should set hasError/appError
        debugPrint('ErrorHandler: inline error — ${error.title}');
        break;
      case ErrorPresentation.fieldLevel:
        // Field-level errors are handled by form validation UI
        debugPrint('ErrorHandler: field error — ${error.title}');
        break;
    }
  }

  /// Show error as a snackbar (always, regardless of type)
  static void showAsSnackbar(AppError error) {
    show(error, presentation: ErrorPresentation.snackbar);
  }

  /// Handle an API response error — classify and show
  static AppError handleResponse(Response response) {
    final error = fromResponse(response);

    if (error.type == ErrorType.authentication) {
      showToast(error.title, isError: true);
      _handleSessionExpired();
    } else if (error.defaultPresentation == ErrorPresentation.snackbar ||
        error.defaultPresentation == ErrorPresentation.dialog) {
      show(error);
    }
    // For inlinePage/fieldLevel, the caller handles display

    return error;
  }

  // ============================================================
  // Helpers
  // ============================================================

  static void _handleSessionExpired() {
    Get.offAllNamed('/login');
  }

  static bool _isDuplicate(String message) {
    if (_lastErrorMessage == message && _lastErrorTime != null) {
      return DateTime.now().difference(_lastErrorTime!) < _deduplicationWindow;
    }
    return false;
  }

  static void _recordShown(String message) {
    _lastErrorMessage = message;
    _lastErrorTime = DateTime.now();
  }
}
