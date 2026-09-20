import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';

/// Error type classification
enum ErrorType {
  network,
  authentication,
  validation,
  server,
  unexpected,
}

/// How the error should be presented to the user
enum ErrorPresentation {
  /// Full-page error state with icon, message, retry button
  inlinePage,

  /// Inline text below form field
  fieldLevel,

  /// Brief non-blocking notification (GetSnackBar)
  snackbar,

  /// Modal dialog requiring acknowledgment
  dialog,
}

/// Centralized error model for user-facing errors
class AppError {
  final ErrorType type;
  final String title;
  final String? description;
  final String? actionHint;
  final bool isRetryable;
  final dynamic originalException;
  final int? statusCode;

  const AppError({
    required this.type,
    required this.title,
    this.description,
    this.actionHint,
    this.isRetryable = false,
    this.originalException,
    this.statusCode,
  });

  /// Default presentation for this error type
  ErrorPresentation get defaultPresentation {
    switch (type) {
      case ErrorType.network:
      case ErrorType.server:
        return ErrorPresentation.inlinePage;
      case ErrorType.authentication:
        return ErrorPresentation.dialog;
      case ErrorType.validation:
        return ErrorPresentation.fieldLevel;
      case ErrorType.unexpected:
        return ErrorPresentation.snackbar;
    }
  }

  /// User-facing message combining title + description
  String get message {
    if (description != null && description!.isNotEmpty) {
      return '$title\n$description';
    }
    return title;
  }

  // ============================================================
  // Factory constructors for common error types
  // ============================================================

  factory AppError.network({dynamic originalException, int? statusCode}) {
    return AppError(
      type: ErrorType.network,
      title: tr(LocaleKeys.errors_network_title),
      description: tr(LocaleKeys.errors_network_description),
      actionHint: tr(LocaleKeys.errors_network_action),
      isRetryable: true,
      originalException: originalException,
      statusCode: statusCode ?? 1,
    );
  }

  factory AppError.server({dynamic originalException, int? statusCode}) {
    return AppError(
      type: ErrorType.server,
      title: tr(LocaleKeys.errors_server_title),
      description: tr(LocaleKeys.errors_server_description),
      actionHint: tr(LocaleKeys.errors_server_action),
      isRetryable: true,
      originalException: originalException,
      statusCode: statusCode,
    );
  }

  factory AppError.authentication({
    bool isSessionExpired = true,
    dynamic originalException,
    int? statusCode,
  }) {
    return AppError(
      type: ErrorType.authentication,
      title: isSessionExpired
          ? tr(LocaleKeys.errors_auth_sessionExpired)
          : tr(LocaleKeys.errors_auth_unauthorized),
      actionHint: tr(LocaleKeys.errors_auth_action),
      isRetryable: false,
      originalException: originalException,
      statusCode: statusCode,
    );
  }

  factory AppError.validation({
    String? message,
    dynamic originalException,
  }) {
    return AppError(
      type: ErrorType.validation,
      title: message ?? tr(LocaleKeys.errors_validation_generic),
      isRetryable: false,
      originalException: originalException,
      statusCode: 422,
    );
  }

  factory AppError.unexpected({dynamic originalException}) {
    return AppError(
      type: ErrorType.unexpected,
      title: tr(LocaleKeys.errors_unexpected_title),
      description: tr(LocaleKeys.errors_unexpected_description),
      actionHint: tr(LocaleKeys.errors_unexpected_action),
      isRetryable: true,
      originalException: originalException,
    );
  }

  @override
  String toString() => 'AppError($type: $title)';
}
