import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';

/// Centralized form validators for the app.
class AppValidators {
  AppValidators._();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final _phoneRegex = RegExp(r'^\+?[0-9\s\-()]{7,20}$');

  /// Required field — returns error if empty/null.
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName ${tr(LocaleKeys.validation_required)}'
          : tr(LocaleKeys.validation_required);
    }
    return null;
  }

  /// Valid email format.
  static String? email(String? value) {
    final req = required(value, tr(LocaleKeys.validation_email));
    if (req != null) return req;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return tr(LocaleKeys.validation_invalidEmail);
    }
    return null;
  }

  /// Password with minimum length.
  static String? password(String? value, {int minLength = 6}) {
    final req = required(value, tr(LocaleKeys.validation_password));
    if (req != null) return req;
    if (value!.length < minLength) {
      return tr(LocaleKeys.validation_passwordMinLength,
          namedArgs: {'count': minLength.toString()});
    }
    return null;
  }

  /// Confirm password matches original.
  static String? confirmPassword(String? value, String original) {
    final req = required(value);
    if (req != null) return req;
    if (value != original) {
      return tr(LocaleKeys.validation_passwordMismatch);
    }
    return null;
  }

  /// Phone number format.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (!_phoneRegex.hasMatch(value.trim())) {
      return tr(LocaleKeys.validation_invalidPhone);
    }
    return null;
  }

  /// Phone number required.
  static String? phoneRequired(String? value) {
    final req = required(value, tr(LocaleKeys.validation_phone));
    if (req != null) return req;
    return phone(value);
  }

  /// Minimum length for any text.
  static String? minLength(String? value, int min, [String? fieldName]) {
    final req = required(value, fieldName);
    if (req != null) return req;
    if (value!.trim().length < min) {
      return '${fieldName ?? tr(LocaleKeys.validation_field)} ${tr(LocaleKeys.validation_minLength, namedArgs: {'count': min.toString()})}';
    }
    return null;
  }

  /// Maximum length for any text.
  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value != null && value.length > max) {
      return '${fieldName ?? tr(LocaleKeys.validation_field)} ${tr(LocaleKeys.validation_maxLength, namedArgs: {'count': max.toString()})}';
    }
    return null;
  }

  /// Username — no spaces, min 3 chars.
  static String? username(String? value) {
    final req = required(value, tr(LocaleKeys.validation_username));
    if (req != null) return req;
    if (value!.trim().length < 3) {
      return tr(LocaleKeys.validation_usernameMinLength);
    }
    if (value.trim().contains(' ')) {
      return tr(LocaleKeys.validation_usernameNoSpaces);
    }
    return null;
  }
}
