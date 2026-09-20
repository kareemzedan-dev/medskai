import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/core/error/app_error.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

class DialogHelper {
  static Timer? _autoHideTimer;

  //show error dialog
  static void showErrorDialog(
      {String? title,
      String? description}) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title ?? tr(LocaleKeys.error),
                style: Get.textTheme.headlineMedium,
              ),
              Text(
                description ?? tr(LocaleKeys.errors_unexpected_title),
                style: Get.textTheme.titleLarge,
              ),
              ElevatedButton(
                onPressed: () {
                  if (Get.isDialogOpen == true) Get.back();
                },
                child: Text(tr(LocaleKeys.common_ok)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show an AppError as a dialog
  static void showAppErrorDialog(AppError error) {
    showErrorDialog(
      title: error.title,
      description: error.description,
    );
  }

  //show loading with auto-dismiss after 30 seconds
  static void showLoading([String? message]) {
    _autoHideTimer?.cancel();
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(message ?? tr(LocaleKeys.loading)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    // Auto-dismiss after 30 seconds to prevent stuck loading
    _autoHideTimer = Timer(const Duration(seconds: 30), () {
      hideLoading();
    });
  }

  //hide loading
  static void hideLoading() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
    if (Get.isDialogOpen == true) Get.back();
  }
}
