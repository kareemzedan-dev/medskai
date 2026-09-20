import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/core/error/app_error.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

/// Track last shown toast for deduplication
String? _lastToastMessage;
DateTime? _lastToastTime;
const _toastDeduplicationWindow = Duration(seconds: 2);

String sanitizeToastMessage(String message) {
  return message
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

void showToast(String message, {bool isError = true}) {
  final sanitizedMessage = sanitizeToastMessage(message);

  // Deduplicate: skip if same message was shown within the window
  final now = DateTime.now();
  if (_lastToastMessage == sanitizedMessage &&
      _lastToastTime != null &&
      now.difference(_lastToastTime!) < _toastDeduplicationWindow) {
    return;
  }
  _lastToastMessage = sanitizedMessage;
  _lastToastTime = now;

  HapticFeedback.lightImpact();
  Get.showSnackbar(GetSnackBar(
    backgroundColor: isError ? MedsKaiColors.error : MedsKaiColors.textPrimary,
    message: sanitizedMessage,
    duration: const Duration(seconds: 3),
    snackStyle: SnackStyle.FLOATING,
    margin: const EdgeInsets.all(10),
    borderRadius: 10,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
  ));
}

void successToast(String message) {
  final sanitizedMessage = sanitizeToastMessage(message);

  HapticFeedback.lightImpact();
  Get.showSnackbar(GetSnackBar(
    backgroundColor: MedsKaiColors.success,
    message: sanitizedMessage,
    duration: const Duration(seconds: 3),
    snackStyle: SnackStyle.FLOATING,
    margin: const EdgeInsets.all(10),
    borderRadius: 10,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
  ));
}

/// Show an AppError as a snackbar toast
void showAppError(AppError error) {
  showToast(error.title, isError: true);
}

Future<bool> clearCartAlert() async {
  HapticFeedback.lightImpact();
  bool clean = false;
  await Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
            title: Text(tr(LocaleKeys.alert_ok)),
            content: Text(tr(LocaleKeys.cart_empty)),
            actions: [
              TextButton(
                onPressed: () {
                  clean = false;
                },
                child: Text(
                  tr(LocaleKeys.alert_cancel),
                  style: const TextStyle(
                      color: MedsKaiColors.textPrimary,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () {
                  clean = true;
                },
                child: Text(
                  tr(LocaleKeys.cart_removeItem),
                  style: const TextStyle(
                      color: MedsKaiColors.primary,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700),
                ),
              )
            ],
          ));
  return clean;
}
